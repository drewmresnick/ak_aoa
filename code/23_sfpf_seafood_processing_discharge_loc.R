#############################################################
### 23. Seafood Processing Discharge Locations,	ak_cs_029 ###
#############################################################


# clear environment
rm(list = ls())

# calculate start time of code (determine how long it takes to complete all code)
start <- Sys.time()

#####################################
#####################################

# Load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(docxtractr,
               dplyr,
               elsa,
               fasterize,
               fs,
               ggplot2,
               janitor,
               ncf,
               paletteer,
               pdftools,
               plyr,
               purrr,
               raster,
               RColorBrewer,
               reshape2,
               # rgdal,
               rgeoda,
               # rgeos,
               rmapshaper,
               rnaturalearth, # use devtools::install_github("ropenscilabs/rnaturalearth") if packages does not install properly
               RSelenium,
               sf,
               shadowr,
               sp,
               stringr,
               terra, # is replacing the raster package
               tidyr,
               tidyverse)

#####################################
#####################################
# Set directories
## Input directories

### Study area directory
#### The hex grids are stored within individual study area directories. Instead of accessing and referencing 
#### multiple directories separately, we can simultaneously access the hex grids from the main study area directory.
study_area_dir <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/study_area"

### Raw data directory
#### This directory contains the data you wish to have processed.
raw_constraints_gpkg <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data/constraints/constraints.gpkg"

##################################### USER INPUT NEEDED
# Set UniqueID
## Input the region. 'ak' stands are Alaska
region <- "ak"

## Input the submodel. 'cs' stands for Constraints
submodel <- "cs"

## Input the unique ID for the raw data
uniqueID <- "ak_cs_029"


#####################################
## To enable looping through and assigning different names to output products, establish a dictionary to iterate through 
## both elements in the "code_dict" dictionary. This way, we can call both dictionary elements simultaneously within the same loop.
code_dict <-list(study_area = c("cordova",
                                "craig",
                                "juneau",
                                "ketchikan",
                                "kodiak",
                                "metlakatla",
                                "petersburg",
                                "seward",
                                "sitka",
                                "valdez",
                                "wrangell"),
                 
                 code = c("co",
                          "cr",
                          "ju",
                          "ke",
                          "ko",
                          "me",
                          "pe",
                          "se",
                          "si",
                          "va",
                          "wr"))


#####################################
#####################################
# This section cleans the data and clips the data to our area of interest. 

## use the length of the code_dict "study_area" element to decide how many iterations are needed 
for(i in 1:length(code_dict$study_area)){
  
  # Error catching
  tryCatch({
    
    # call the study area dictionary for the iteration
    dict_study <- code_dict$study_area[[i]]
    
    # call the corresponding study area code
    dict_code <- code_dict$code[[i]]
    
    # call in the dissolved hex grids
    ## As there are two layers in the geopackage with the study area name,
    ## it's essential to read out the full name to avoid selecting the incorrect one.
    dataset <- paste(dict_study, "fiveacre_dissolve", sep = "_")
    
    ## path to the dissolved hex grids
    hex_path <- paste(study_area_dir, "/", dict_study, "/b_intermediate_data/", dict_study, "_study_area.gpkg", sep = "")
    
    ## for each item in the code_dict list, search the study area geopackage for the dataset layer corresponding to that item
    hex_by_study <- sf::st_read(dsn = hex_path,
                                layer = sf::st_layers(hex_path)[[1]][grep(pattern = dataset,
                                                                          sf::st_layers(dsn = hex_path)[[1]])])
    
    # function to clean data
    clean_data <- function(raw_data){
      data_layer <- raw_data %>%
        # reproject the same coordinate reference system (crs) as the study area
        sf::st_transform("ESRI:102008") %>% # EPSG WKID 102008 (https://epsg.io/102008)
        # obtain data within buffered hexed study area
        rmapshaper::ms_clip(hex_by_study) %>%
        # create field called "layer" and fill with "seafood processing discharge loc" for summary
        dplyr::mutate(layer = "seafood processing discharge loc")
      return(data_layer)
    }
    
    # Load Seafood Processing Discharge Locations and pass it through the cleaning function above
    ## REST Service: https://dec.alaska.gov/arcgis/rest/services/Water/Seafood_Processing/MapServer/3
    ### data
    read_data <- sf::st_read(dsn = raw_constraints_gpkg, layer = uniqueID) %>% clean_data
    
    
    # name split by the "_"
    id <- strsplit(uniqueID, "_(?!.*_)", perl=TRUE)[[1]]
    
    # create a new unique code that's specific to the study area, not just the region
    out_code <- paste(region, dict_code, submodel, id[2], sep="_")
    
    
    # Export data
    ## intermediate geopackage directory
    intermediate_gpkg <- paste(study_area_dir, dict_study, "b_intermediate_data/constraints/constraints.gpkg", sep = "/")
    
    
    ## run the export tool
    sf::st_write(obj = read_data, dsn = intermediate_gpkg, out_code , append = F)
    
    #create the unique hex layer name
    hex_layer <- paste(dict_study, "_fiveacre", sep = "")
    
    #read in the study area hex layer
    region_hex <- sf::st_read(dsn = hex_path,
                              layer = hex_layer)
    
    # turn clipped data into hex grid
    # find where data intersect with hex grids
    region_data_hex_function <- function(region_hex, read_data){
      region_data_hex <- region_hex[read_data, ] %>%
        # spatially join  values to study area hex cells
        sf::st_join(x = .,
                    y = read_data,
                    join = st_intersects) %>%
        # select fields of importance
        dplyr::select(GRID_ID)
      
      return(region_data_hex)
    }
    
    # run the function
    hex_read_data <- region_data_hex_function(region_hex, read_data)
    
    # submodel geopackage directory
    submodel_gpkg <- paste(study_area_dir, dict_study, "c_submodel_data/constraints/constraints.gpkg", sep = "/")
    
    # run the export tool
    sf::st_write(obj = hex_read_data, dsn = submodel_gpkg, out_code , append = F)
    
    # Error catching  
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}


#####################################
#####################################
# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
############################
### 2. Study Area        ###
############################


# clear environment
rm(list = ls())

# calculate start time of code (determine how long it takes to complete all code)
start <- Sys.time()

#####################################
#####################################

# load packages
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
               RSQLite,
               sf,
               sp,
               stringr,
               terra, # is replacing the raster package
               tidyr)

#####################################
#####################################
# Set directories
## Define data directory 

### Input directories
#### raw data directory
data_dir <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data"

# hex grid area geopackage
ak_aoa_study_area <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data/ak_study_areas.gpkg"


### Output directories
#### Study area root directory
study_area_dir <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/study_area"

#####################################

# list of the datasets within the study area geopackage
data_codes <- c("ketchikan_fiveacre",
                "cordova_fiveacre",
                "craig_fiveacre",
                "juneau_fiveacre",
                "kodiak_fiveacre",
                "metlakatla_fiveacre",
                "petersburg_fiveacre",
                "seward_fiveacre",
                "sitka_fiveacre",
                "valdez_fiveacre",
                "wrangell_fiveacre")


#####################################
# Load merged hex data
for(i in data_codes){
  # loop through the data_codes list
  dataset <- i

  # for every element in the data_codes list, search through the geopackage and look for the layers with specific names
  hex_by_study <- sf::st_read(dsn = paste(data_dir, "ak_study_areas.gpkg", sep = "/"),
                              layer = sf::st_layers(paste(data_dir, "ak_study_areas.gpkg", sep = "/"))[[1]][grep(pattern = dataset,
                                                                                                                 sf::st_layers(dsn = paste(data_dir, "ak_study_areas.gpkg", sep = "/"))[[1]])])
  
  
  # grab just the name of the study area (everything before the "_")
  study_area_name <- gsub('_[^_]*$', '', dataset)
  
  # dissolve individual study area hexes into single feature
  hex_dissolve <- hex_by_study %>%
    # create field called the study area name (i.e. "kodiak")
    dplyr::mutate(study_area = study_area_name) %>%
    # group all rows by the different elements with the study area name (i.e. "kodiak") field -- this will create a row for the grouped data
    dplyr::group_by(study_area) %>%
    # summarise all those grouped elements together -- in effect this will create a single feature
    dplyr::summarise()
  
  
  # export data
  ## Get the file path that will write to your study area's (i.e. kodiak) b_intermediate_data folder. 
  file <- paste(study_area_name, "_study_area.gpkg", sep = "")

  ## geopackage
  dissolved_gpkg <- file.path(study_area_dir, study_area_name, "b_intermediate_data", file)

  ## dissolved study area
  sf::st_write(obj = hex_dissolve, dsn = dissolved_gpkg, layer = paste(dataset, "dissolve", sep = "_"), append = F)
  
  ## undissolved study area
  sf::st_write(obj = hex_by_study, dsn = dissolved_gpkg, layer = paste(dataset), append = F)
  
}


#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
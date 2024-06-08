##################################################
### 11. Alaska Marine Highway,	ak_cs_009      ###
##################################################


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
### study area geopackage
study_area_gpkg <- "C:/Users/Breanna.Xiong/Documents/R Scripts/Alaska Aquaculture/data/b_intermediate_data/aoa_study_area/ak_aoa_study_area.gpkg"

### raw data directory
raw_constraints_gpkg <- "C:/Users/Breanna.Xiong/Documents/R Scripts/Alaska Aquaculture/data/a_raw_data/constraints/constraints.gpkg"


## Output directories
### intermediate geopackage
intermediate_gpkg <- "C:/Users/Breanna.Xiong/Documents/R Scripts/Alaska Aquaculture/data/b_intermediate_data/constraints/constraints.gpkg"

### submodel geopackage
submodel_gpkg <- "C:/Users/Breanna.Xiong/Documents/R Scripts/Alaska Aquaculture/data/c_submodel_data/constraints/submodel.gpkg"



#####################################
#####################################

# Load study area (to clip data to only that area)
study_area <- sf::st_read(dsn = study_area_gpkg, layer = "ak_aoa_study_area_dissolved")


#####################################
#####################################

#View layer names within geodatabase to see the geometry type
sf::st_layers(dsn = raw_constraints_gpkg,
              do_count = TRUE)


#####################################
#####################################

# Define the function to clean the data. This includes reprojecting to the same coordinate reference system (crs) as the study area
# which we want to clip the data to.

clean_data <- function(raw_data){
  data_layer <- raw_data %>%
    # reproject the same coordinate reference system (crs) as the study area
    sf::st_transform("ESRI:102008") %>% # EPSG WKID 102008 (https://epsg.io/102008)
    # obtain data within study area
    sf::st_intersection(study_area)
  return(data_layer)
}



#####################################
#####################################

# Load Alaska Marine Highway and pass it through the cleaning function above
## source: https://gs.audubon.axds.co/audubon_2019/wms?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=audubon_2019:alaska_marine_highway
## metadata: https://portal.aoos.org/?portal_id=121#metadata/d87622e4-5735-11e9-84f0-0023aeec7b98/2b010340-6e05-11e9-9316-0023aeec7b98 
### data
read_data <- sf::st_read(dsn = raw_constraints_gpkg, layer = "ak_cs_009") %>% clean_data()


#####################################
#####################################

# Export data
## submodel geopackage
sf::st_write(obj = read_data, dsn = submodel_gpkg, "ak_cs_009", append = F)

## intermediate geopackage
sf::st_write(obj = read_data, dsn = intermediate_gpkg, "ak_cs_009", append = F)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
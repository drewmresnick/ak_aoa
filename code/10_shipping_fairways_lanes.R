##############################################################################
### 10. Shipping Fairways, Lanes, and Zones for US waters, ak_cs_008       ###
##############################################################################


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

# Load Shipping Fairways, Lanes, and Zones for US waters and pass it through the cleaning function above
## source: https://encdirect.noaa.gov/theme_layers/data/shipping_lanes/shippinglanes.zip 
## metadata: https://inport.nmfs.noaa.gov/inport/item/39986
### data
read_data <- sf::st_read(dsn = raw_constraints_gpkg, layer = "ak_cs_008") %>% clean_data()


#####################################
#####################################

# Export data
## submodel geopackage
sf::st_write(obj = read_data, dsn = submodel_gpkg, "ak_cs_008", append = F)

## intermediate geopackage
sf::st_write(obj = read_data, dsn = intermediate_gpkg, "ak_cs_008", append = F)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
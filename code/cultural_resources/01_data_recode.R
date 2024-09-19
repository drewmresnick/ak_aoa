##################################################
### 0. Data Codes -- cultural resources        ###
##################################################

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

# set parameters
region <- "ak"
submodel <- "cr"

#####################################
#####################################

# set directories
## submodel raw data directory
data_dir <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/aa_exploration_data/cultural_resources"

list.files(data_dir)
list.dirs(data_dir, recursive = TRUE)

## constraints submodel geopackage
cultural_geopackage <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/aa_exploration_data/cultural_resources/cultural_resources.gpkg"

#####################################
#####################################


# Historic Lighthouses	ak_cr_001
lighthouse <- sf::st_read(dsn = file.path(data_dir, "HistoricalLighthouse/HistoricLighthouses.gdb"), layer = "HistoricLighthouses")


# Federally recognized Tribes	ak_cr_002
tribes <- sf::st_read(dsn = file.path(data_dir, "federally_recognized_tribes/CDO_Contacts_Federally_Recognized_Tribes.shp"))


# Subsistence harvest non fisheries resources	ak_cr_003
subnonfish <- sf::st_read(dsn = file.path(data_dir, "subsistence_harvest_nonfisheries_resources/subsistence_harvest_nonfisheries_resources.shp"))


# Subsistence Harvest Fisheries Resources	ak_cr_004
subfish <- sf::st_read(dsn = file.path(data_dir, "subsistence_harvest_fisheries_resources/subsistence_harvest_fisheries_resources.shp"))


# Community Culture and History	ak_cr_005
communityhistory <- sf::st_read(dsn = file.path(data_dir, "community_culture_history/General_CultureHistory.shp"))


# Harbors	ak_cr_006
harbors <- sf::st_read(dsn = file.path(data_dir, "harbors/AKDOTPF_Route_Data.shp"))


# Land permit or lease - polygon	ak_cr_007
land_permit <- sf::st_read(dsn = file.path(data_dir, "LandActivity_LandPermitOrLease/LandActivity_LandPermitOrLease.shp"))


# Alaska National Parks, Preserves, Monuments	ak_cr_008
np_pres_monu <- sf::st_read(dsn = file.path(data_dir, "ak_np_preserves_monuments/Sensitive_Areas.shp"))


# Shore Fishery Lease	ak_cr_009
shore_fishery_lease <- sf::st_read(dsn = file.path(data_dir, "shore_fishery_lease/NaturalResource_Aquaculture.shp"))


#####################################
#####################################

# create list of the datasets
data <- list(lighthouse,
             tribes,
             subnonfish,
             subfish,
             communityhistory,
             harbors,
             land_permit,
             np_pres_monu,
             shore_fishery_lease
             )

#####################################
# Sanity check, you above list should have 50 variables
length(data)

#####################################

# create a sequence starting from 1 to the length of the number of the datasets by an increment of 1
data_order <- seq(from = 1,
                  to = length(data),
                  by = 1)

## add extra "0" when needed to make all numbers three digits
for(i in 1:length(data_order)){
  data_order[i] <- ifelse(nchar(data_order[i]) < 2, paste0("00", data_order[i]),
                          ifelse(nchar(data_order[i]) == 2, paste0("0", data_order[i]), data_order[i]))
}

#####################################
#####################################

# create the new codes for the datasets
## create an empty vector for the data codes
data_code <- c()

## loop through the length of datasets and add code index to the region and submodel to have total name
for(i in 1:length(data)){
  data_code[i] <- c(paste(region, submodel, data_order[i], sep = "_"))
}

# Check your code to make sure that it's numbered correctly (001-050)
print(data_code)

#####################################
#####################################

# export all datasets with new codes
for(i in seq_along(data)){
  # grab the dataset
  dataset <- data[[i]]
  
  # export the dataset
  sf::st_write(obj = dataset, dsn = cultural_geopackage, layer = data_code[i], append = F)
}

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate

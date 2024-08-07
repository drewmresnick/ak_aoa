##################################################
### 0. Data Codes -- natural resources         ###
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
submodel <- "nr"

#####################################
#####################################

# set directories
## submodel raw data directory
data_dir <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/aa_exploration_data/natural_resources"

list.files(data_dir)
list.dirs(data_dir, recursive = TRUE)

## constraints submodel geopackage
natural_geopackage <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/aa_exploration_data/natural_resources/natural_resources.gpkg"

#####################################
#####################################


# Deep Sea Coral Habitat Suitability for Soft Corals	ak_nr_002
soft_coral_suit <- sf::st_read(dsn = file.path(data_dir, "DeepSeaSoftCoralHabitatSuitability/DeepSeaSoftCoralHabitatSuitability.gpkg"), layer = "DeepSeaSoftCoralHabitatSuitability")


# Deep Sea Coral Habitat Suitability for Stony Corals	ak_nr_003
stony_coral_suit <- sf::st_read(dsn = file.path(data_dir, "DeepSeaStonyCoralHabitatSuitability/DeepSeaStonyCoralHabitatSuitability.gpkg"), layer = "DeepSeaStonyCoralHabitatSuitability")


# Alaska ecosystems of conservation concern	ak_nr_013
# algae biobands (shoreZone)	
# kelp biobands (shoreZone)	
# sea grass biobands (shoreZone)	
# urchin, mussel, and barnacle biobands (shoreZone)	
# Seabird colonies	ak_nr_185
# Audubon IBA Core Areas in Alaska	ak_nr_028
# Audubon IBAs in Alaska	ak_nr_029
# Audobon IBAs Colony Points	ak_nr_030
# Kachemak Bay: anadromous salmon	ak_nr_171
# NOAA Environmental Sensitivity Index: bald eagle nests	ak_nr_117
# bearded seal range	ak_nr_153
# Polar bear critical habitat areas	ak_nr_163
# ringed seal range	ak_nr_164
# Shore Fishery Lease	ak_nr_228, ak_cr_010
# Land permit or lease - polygon	ak_nr_008, ak_cr_008
# Alaska National Parks, preserves, monuments	ak_nr_044, ak_cr_009

#####################################
#####################################

# create list of the datasets
data <- list(lighthouse,
             tribes,
             subnonfish,
             subfish,
             communityhistory,
             harbors,
             bears,
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

####################################
### 1. Exploration to Raw        ###
####################################


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

## input data 
### exploratory constraints geopackage dire
data_dir <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/aa_exploration_data/cultural_resources"


## output directory
### cultural resources submodel geopackage (raw data)
raw_cultural_geopackage <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data/cultural_resources/cultural_resources.gpkg"

#####################################
#####################################

# Historic Lighthouses	ak_cr_001
lighthouse <- sf::st_read(dsn = paste(data_dir, "cultural_resources.gpkg", sep = "/"), layer = "ak_cr_001")




#####################################
#####################################

# create list of the datasets
data <- list(
  lighthouse
)


#####################################
# Sanity check, you above list should have 34 variables
length(data)


#####################################
#####################################

# list out the corresponding codes so that we can rename them in the geopackage

data_codes <- c("ak_cr_001")



#####################################
# Sanity check, you above list should have 36 variables
length(data_codes)

#####################################
#####################################
# export all datasets with new codes
for(i in seq_along(data)){
  # grab the dataset
  dataset <- data[[i]]
  
  # export the dataset
  sf::st_write(obj = dataset, dsn = raw_cultural_geopackage, layer = data_codes[i], append = F)
}

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate

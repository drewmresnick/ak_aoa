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

# Federally recognized Tribes	ak_cr_002
tribes <- sf::st_read(dsn = paste(data_dir, "cultural_resources.gpkg", sep = "/"), layer = "ak_cr_002")


# Subsistence harvest non fisheries resources	ak_cr_003
subnonfish <- sf::st_read(dsn = paste(data_dir, "cultural_resources.gpkg", sep = "/"), layer = "ak_cr_003")


# Subsistence Harvest Fisheries Resources	ak_cr_004
subfish <- sf::st_read(dsn = paste(data_dir, "cultural_resources.gpkg", sep = "/"), layer = "ak_cr_004")


# Community Culture and History	ak_cr_005
communityhistory <- sf::st_read(dsn = paste(data_dir, "cultural_resources.gpkg", sep = "/"), layer = "ak_cr_005")


# Harbors	ak_cr_006
harbors <- sf::st_read(dsn = paste(data_dir, "cultural_resources.gpkg", sep = "/"), layer = "ak_cr_006")


# Bear concentration areas	ak_cr_007
bears <- sf::st_read(dsn = paste(data_dir, "cultural_resources.gpkg", sep = "/"), layer = "ak_cr_007")


# Land permit or lease - polygon	ak_cr_008
land_permit <- sf::st_read(dsn = paste(data_dir, "cultural_resources.gpkg", sep = "/"), layer = "ak_cr_008")


# Alaska National Parks, Preserves, Monuments	ak_cr_009
np_pres_monu <- sf::st_read(dsn = paste(data_dir, "cultural_resources.gpkg", sep = "/"), layer = "ak_cr_009")


# Shore Fishery Lease	ak_cr_010
shore_fishery_lease <- sf::st_read(dsn = paste(data_dir, "cultural_resources.gpkg", sep = "/"), layer = "ak_cr_010")




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
# Sanity check, you above list should have 10 variables
length(data)


#####################################
#####################################

# list out the corresponding codes so that we can rename them in the geopackage

data_codes <- c("ak_cr_001",
                "ak_cr_002",
                "ak_cr_003",
                "ak_cr_004",
                "ak_cr_005",
                "ak_cr_006",
                "ak_cr_007",
                "ak_cr_008",
                "ak_cr_009",
                "ak_cr_010")



#####################################
# Sanity check, you above list should have 10 variables
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

####################################################################
### 0. Data Codes -- industry, transportation, navigation        ###
####################################################################

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
submodel <- "itn"

#####################################
#####################################

# set directories
## submodel raw data directory
data_dir <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/aa_exploration_data/industry_navigation"

list.files(data_dir)
list.dirs(data_dir, recursive = TRUE)

## constraints submodel geopackage
industry_geopackage <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/aa_exploration_data/industry_navigation/industry_navigation.gpkg"

#####################################
#####################################


# Permitted Log Transfer Facilities Public View	ak_itn_001
log_transfer_facilities <- sf::st_read(dsn = file.path(data_dir, "log_transfer_facilities/Permitted_Log_Transfer_Facilities_Public_View.shp"))


# Alaska planning area outlines	ak_itn_002
planarea <- sf::st_read(dsn = file.path(data_dir, "planarea/AK_PLAN.shp"))


# Alaska Oil and Gas Leases	ak_itn_003
ak_leases <- sf::st_read(dsn = file.path(data_dir, "boem_oil_gas_lease/AK_Leases.gdb"), layer = "AK_Leases")


#####################################
#####################################

# create list of the datasets
data <- list(log_transfer_facilities,
             planarea,
             ak_leases
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
  sf::st_write(obj = dataset, dsn = industry_geopackage, layer = data_code[i], append = F)
}

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate

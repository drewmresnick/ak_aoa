############################################################
### 0. Download Data -- Constraints REST server download ###
############################################################

# clear environment
rm(list = ls())

# calculate start time of code (determine how long it takes to complete all code)
start <- Sys.time()

#####################################
#####################################

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(arcpullr,
               docxtractr,
               dplyr,
               elsa,
               fasterize,
               fs,
               ggplot2,
               httr,
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
               sf,
               sp,
               stringr,
               terra, # is replacing the raster package
               tidyr)

#####################################
#####################################
# exploration data directory for constraints
data_dir <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/aa_exploration_data/natural_resources"


#####################################
#####################################

rest_services_function <- function(url_list, base_url, data_dir){
  # define base URL (the service path)
  base_url <- base_url
  
  # define the unique dataset URL ending
  full_url <- url_list
  
  # combine the base with the dataset URL to create the entire data URL
  data_url <- file.path(base_url, full_url)
  
  # pull the spatial layer from the REST server
  data <- arcpullr::get_spatial_layer(data_url)
  
  # get the unique data name (when applicable)(2nd object is the unique name)
  dir_name <- stringr::str_split(url_list, pattern = "/")[[1]][2]
  
  # create new directory for data
  dir_create <- dir.create(file.path(data_dir, dir_name))
  
  # set the new pathname to export the data
  new_dir <- file.path(data_dir, dir_name)
  
  # export the dataset
  sf::st_write(obj = data, dsn = file.path(new_dir, paste0(dir_name, ".shp")), delete_layer = F)
}

#####################################

# Municipal Tidelands

url_list <- c(
  "OpenData/Ownership_MunicipalEntitlementandTidelands/MapServer/0"
)

parallel::detectCores()[1]

cl <- parallel::makeCluster(spec = parallel::detectCores(), type = 'PSOCK') # number of clusters wanting to create

work <- parallel::parLapply(cl = cl, X = url_list, fun = rest_services_function, base_url = "https://arcgis.dnr.alaska.gov/arcgis/rest/services/", data_dir = data_dir)

parallel::stopCluster(cl = cl)


# Rename the AKDOTPF_Route_Data to Harbors for a more descriptive title
file.rename(from = file.path(data_dir, list.files(data_dir,
                                                  # get the harbors directory
                                                  pattern = "Ownership_MunicipalEntitlementandTidelands")),
            to = file.path(data_dir, "municipal_tidelands"))

list.files(data_dir)



#####################################
#####################################

# list all files in data directory
list.files(data_dir)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
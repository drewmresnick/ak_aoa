##################################################################
### 0. Download Data -- Natural Resources REST server download ###
##################################################################

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

# Shore Fishery Lease

url_list <- c(
  "OpenData/NaturalResource_Aquaculture/MapServer/3" # Shore Fishery Lease
)

parallel::detectCores()[1]
cl <- parallel::makeCluster(spec = parallel::detectCores(), type = 'PSOCK')

work <- parallel::parLapply(cl = cl, X = url_list, fun = rest_services_function,
                            base_url = "https://arcgis.dnr.alaska.gov/arcgis/rest/services/", data_dir = data_dir)

parallel::stopCluster(cl = cl)

# Rename the NaturalResource_Aquaculture to federally_recognized_tribes for a more descriptive title
file.rename(from = file.path(data_dir, list.files(data_dir, pattern = "NaturalResource_Aquaculture")),
            to = file.path(data_dir, "shore_fishery_lease"))


#####################################

# Alaska National Parks, Preserves, Monuments

url_list <- c("Water/Sensitive_Areas/MapServer/18")

parallel::detectCores()[1]
cl <- parallel::makeCluster(spec = parallel::detectCores(), type = 'PSOCK')

work <- parallel::parLapply(cl = cl, X = url_list, fun = rest_services_function,
                            base_url = "https://dec.alaska.gov/arcgis/rest/services/", data_dir = data_dir)

parallel::stopCluster(cl = cl)


# Rename the Sensitive_Areas to federally_recognized_tribes for a more descriptive title
file.rename(from = file.path(data_dir, list.files(data_dir, pattern = "Sensitive_Areas")),
            to = file.path(data_dir, "ak_np_preserves_monuments"))
#####################################


#####################################
#####################################

# list all files in data directory
list.files(data_dir)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
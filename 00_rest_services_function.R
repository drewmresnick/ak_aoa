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

data_dir <- "C:/Users/Breanna.Xiong/Documents/R Scripts/Alaska Aquaculture/data/a_raw_data/constraints"

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

# Tribal Waters (Southeast_Alaska_Closed_Waters_Salmon_Net_Fisheries)

url_list <- c(
  "services/SEAK_ClosedWaters_SalmonNetFisheries/FeatureServer/2"
)

parallel::detectCores()[1]
cl <- parallel::makeCluster(spec = parallel::detectCores(), # number of clusters wanting to create
                            type = 'PSOCK')

work <- parallel::parLapply(cl = cl, X = url_list, fun = rest_services_function,
                            base_url = "https://services.arcgis.com/VdkVOAHovLuozJG4/arcgis/rest/", data_dir = data_dir)

parallel::stopCluster(cl = cl)

#####################################

# National Park Service Boundary and Tracts (For Glacier Bay National Park and Preserve Tract and Boundary Data)
## have to do one at a time because the directories do not have unique name

rest_services_function <- function(url_list, base_url, data_dir){
  base_url <- base_url
  full_url <- url_list
  data_url <- file.path(base_url, full_url)
  
  data <- arcpullr::get_spatial_layer(data_url)
  
  # ***warning: change depending on the dataset wanted
  dir_name <- "nps_boundary_data_service"
  
  # create new directory for data
  dir_create <- dir.create(file.path(data_dir, dir_name))
  
  new_dir <- file.path(data_dir, dir_name)
  
  sf::st_write(obj = data, dsn = file.path(new_dir, paste0(dir_name, ".shp")), delete_layer = F)
}

url_list <- c(
  "services/NPS_Land_Resources_Division_Boundary_and_Tract_Data_Service/FeatureServer/2" ## boundary
  # "services/NPS_Land_Resources_Division_Boundary_and_Tract_Data_Service/FeatureServer/1" ## tracts
)

parallel::detectCores()[1]
cl <- parallel::makeCluster(spec = parallel::detectCores(), # number of clusters wanting to create
                            type = 'PSOCK')

work <- parallel::parLapply(cl = cl, X = url_list, fun = rest_services_function,
                            base_url = "https://services1.arcgis.com/fBc8EJBxQRMcHlei/ArcGIS/rest/", data_dir = data_dir)

parallel::stopCluster(cl = cl)

#####################################

# POA Civil works projects- Navigation Projects
# POA Civil works projects- Erosion Protection and Flood Mitigation Projects

rest_services_function <- function(url_list, base_url, data_dir){
  base_url <- base_url
  full_url <- url_list
  data_url <- file.path(base_url, full_url)
  
  data <- arcpullr::get_spatial_layer(data_url)
  
  # ***warning: change depending on the dataset wanted
  dir_name <- "poa_erosion_protection_and_flood_mitigation_projects"
  
  # create new directory for data
  dir_create <- dir.create(file.path(data_dir, dir_name))
  
  new_dir <- file.path(data_dir, dir_name)
  
  sf::st_write(obj = data, dsn = file.path(new_dir, paste0(dir_name, ".shp")), delete_layer = F)
}


url_list <- c(
  #"services/POA_Navigation_Projects_(View)/FeatureServer/0" ## navigation projects
  "services/POA_Erosion_Protection_and_Flood_Mitigation_Projects_1/FeatureServer/0" ## erosion protection and flood mitigation projects - river and harbors
)

parallel::detectCores()[1]
cl <- parallel::makeCluster(spec = parallel::detectCores(), # number of clusters wanting to create
                            type = 'PSOCK')

work <- parallel::parLapply(cl = cl, X = url_list, fun = rest_services_function,
                            base_url = "https://services7.arcgis.com/n1YM8pTrFmm7L4hs/ArcGIS/rest/", data_dir = data_dir)

parallel::stopCluster(cl = cl)



#####################################

# Alaska DEC Seafood Processing Facilities: AKG130000
## Permitted Outfall
## Permitted Net Pens
## Permitted Carcass Disposal Site

## have to do one at a time because the directories do not have unique name

rest_services_function <- function(url_list, base_url, data_dir){
  base_url <- base_url
  full_url <- url_list
  data_url <- file.path(base_url, full_url)
  
  data <- arcpullr::get_spatial_layer(data_url)
  
  # ***warning: change depending on the dataset wanted
  dir_name <- "seafood_processing_permitted_carcass_disposal"
  
  # create new directory for data
  dir_create <- dir.create(file.path(data_dir, dir_name))
  
  new_dir <- file.path(data_dir, dir_name)
  
  sf::st_write(obj = data, dsn = file.path(new_dir, paste0(dir_name, ".shp")), delete_layer = F)
}


url_list <- c(
  # "services/Water/Seafood_Processing/MapServer/12" ## Permitted Outfall
  # "services/Water/Seafood_Processing/MapServer/13" ## Permitted Net Pens
   "services/Water/Seafood_Processing/MapServer/14" ## Permitted Carcass Disposal Site
)

parallel::detectCores()[1]
cl <- parallel::makeCluster(spec = parallel::detectCores(), # number of clusters wanting to create
                            type = 'PSOCK')

work <- parallel::parLapply(cl = cl, X = url_list, fun = rest_services_function,
                            base_url = "https://dec.alaska.gov/arcgis/rest/", data_dir = data_dir)

parallel::stopCluster(cl = cl)

#####################################

# APDES DEC Permitted Onshore Seafood Processors
## seafood processing discharge locations
## seafood processing facility locations

rest_services_function <- function(url_list, base_url, data_dir){
  base_url <- base_url
  full_url <- url_list
  data_url <- file.path(base_url, full_url)
  
  data <- arcpullr::get_spatial_layer(data_url)
  
  # ***warning: change depending on the dataset wanted
  dir_name <- "seafood_processing_facility_locations"
  
  # create new directory for data
  dir_create <- dir.create(file.path(data_dir, dir_name))
  
  new_dir <- file.path(data_dir, dir_name)
  
  sf::st_write(obj = data, dsn = file.path(new_dir, paste0(dir_name, ".shp")), delete_layer = F)
}


url_list <- c(
  # "services/Water/Seafood_Processing/MapServer/3" ## seafood processing discharge locations
  "services/Water/Seafood_Processing/MapServer/2" ## seafood processing facility locations
)

parallel::detectCores()[1]
cl <- parallel::makeCluster(spec = parallel::detectCores(), # number of clusters wanting to create
                            type = 'PSOCK')

work <- parallel::parLapply(cl = cl, X = url_list, fun = rest_services_function,
                            base_url = "https://dec.alaska.gov/arcgis/rest/", data_dir = data_dir)

parallel::stopCluster(cl = cl)

#####################################

# AKG523000 Offshore Seafood Processors Line of Operation

rest_services_function <- function(url_list, base_url, data_dir){
  base_url <- base_url
  full_url <- url_list
  data_url <- file.path(base_url, full_url)
  
  data <- arcpullr::get_spatial_layer(data_url)
  
  # ***warning: change depending on the dataset wanted
  dir_name <- "offshore_seafood_processors_line_of_operation"
  
  # create new directory for data
  dir_create <- dir.create(file.path(data_dir, dir_name))
  
  new_dir <- file.path(data_dir, dir_name)
  
  sf::st_write(obj = data, dsn = file.path(new_dir, paste0(dir_name, ".shp")), delete_layer = F)
}


url_list <- c(
  "services/Water/Seafood_Processing/MapServer/7"
)

parallel::detectCores()[1]
cl <- parallel::makeCluster(spec = parallel::detectCores(), # number of clusters wanting to create
                            type = 'PSOCK')

work <- parallel::parLapply(cl = cl, X = url_list, fun = rest_services_function,
                            base_url = "https://dec.alaska.gov/arcgis/rest/", data_dir = data_dir)

parallel::stopCluster(cl = cl)

#####################################
#####################################

# list all files in data directory
list.files(data_dir)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
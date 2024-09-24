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
data_dir <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/aa_exploration_data/cultural_resources"


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

# Harbors

url_list <- c(
  "services/AKDOTPF_Route_Data/FeatureServer/1"
)

parallel::detectCores()[1]

cl <- parallel::makeCluster(spec = parallel::detectCores(), type = 'PSOCK') # number of clusters wanting to create

work <- parallel::parLapply(cl = cl, X = url_list, fun = rest_services_function, base_url = "https://services.arcgis.com/r4A0V7UzH9fcLVvv/arcgis/rest/", data_dir = data_dir)

parallel::stopCluster(cl = cl)


# Rename the AKDOTPF_Route_Data to Harbors for a more descriptive title
file.rename(from = file.path(data_dir, list.files(data_dir,
                                                  # get the harbors directory
                                                  pattern = "AKDOTPF_Route_Data")),
            to = file.path(data_dir, "harbors"))

list.files(data_dir)

#####################################

# Communities - Incorporated and Unincorporated Cities, Boroughs, CDPs, Localities
# Federally recognized Tribes

url_list <- c(
  "Community_Related/Community_Locations_and_Boundaries/MapServer/0", # Communities - Incorporated and Unincorporated Cities, Boroughs, CDPs, Localities, might come up with errors
  "Community_Related/General_CultureHistory/MapServer/0", # Community Culture and History
  "Contacts/CDO_Contacts_Federally_Recognized_Tribes/MapServer/0" # Federally recognized Tribes
)

parallel::detectCores()[1]
cl <- parallel::makeCluster(spec = parallel::detectCores(), # number of clusters wanting to create
                            type = 'PSOCK')

work <- parallel::parLapply(cl = cl, X = url_list, fun = rest_services_function,
                            base_url = "https://maps.commerce.alaska.gov/server/rest/services/", data_dir = data_dir)

parallel::stopCluster(cl = cl)


# Rename the CDO_Contacts_Federally_Recognized_Tribes to federally_recognized_tribes for a more descriptive title
file.rename(from = file.path(data_dir, list.files(data_dir, pattern = "CDO_Contacts_Federally_Recognized_Tribes")),
                                                  to = file.path(data_dir, "federally_recognized_tribes"))


# Rename the General_CultureHistory to federally_recognized_tribes for a more descriptive title
file.rename(from = file.path(data_dir, list.files(data_dir, pattern = "General_CultureHistory")),
                                                  to = file.path(data_dir, "community_culture_history"))


# Rename the Community_Locations_and_Boundaries to community_incorp_unincorp for a more descriptive title
file.rename(from = file.path(data_dir, list.files(data_dir, pattern = "Community_Locations_and_Boundaries")),
                                                  to = file.path(data_dir, "communities_incorp_unincorp"))


# list.files(data_dir)

#####################################
# Land permit or lease - polygon
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
# Economics Subsistence
## Subsistence Use Communities
## Subsistence harvest non fisheries resources
## Subsistence Harvest Fisheries Resources

## have to do one at a time because the directories do not have unique name

rest_services_function <- function(url_list, base_url, data_dir){
  base_url <- base_url
  full_url <- url_list
  data_url <- file.path(base_url, full_url)
  
  data <- arcpullr::get_spatial_layer(data_url)
  
  # ***warning: change depending on the dataset wanted
  dir_name <- "subsistence_nonfisheries_resources"
  
  # create new directory for data
  dir_create <- dir.create(file.path(data_dir, dir_name))
  
  new_dir <- file.path(data_dir, dir_name)
  
  sf::st_write(obj = data, dsn = file.path(new_dir, paste0(dir_name, ".shp")), delete_layer = F)
}


url_list <- c(
  # "Economics_Related/Economics_Subsistence/MapServer/2" ## Subsistence Use Communities
  "Economics_Related/Economics_Subsistence/MapServer/1" ## Subsistence harvest non fisheries resources
  # "Economics_Related/Economics_Subsistence/MapServer/0" ## Subsistence Harvest Fisheries Resources
)


parallel::detectCores()[1]
cl <- parallel::makeCluster(spec = parallel::detectCores(), type = 'PSOCK')

work <- parallel::parLapply(cl = cl, X = url_list, fun = rest_services_function,
                            base_url = "https://maps.commerce.alaska.gov/server/rest/services/", data_dir = data_dir)

parallel::stopCluster(cl = cl)



#####################################
#####################################

# list all files in data directory
list.files(data_dir)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
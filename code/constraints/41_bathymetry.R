################################
### 41. Bathymetry           ###
################################

# clear environment
rm(list = ls())

# calculate start time of code (determine how long it takes to complete all code)
start <- Sys.time()

#####################################
#####################################

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(docxtractr, dplyr, elsa, fasterize, fs, ggplot2, janitor, ncf, paletteer, pdftools, plyr, purrr, raster, RColorBrewer, reshape2, rgdal, rgeoda, rgeos, rmapshaper, rnaturalearth, sf, sp, stringr, terra, tidyr) # use devtools::install_github("ropenscilabs/rnaturalearth") if rnaturalearth package does not install properly


#####################################
#####################################


bathymetry_path <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data/extracted_bathymetry_hex_grids.gpkg"
output_base_path <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/study_area"



code_dict <- list(
  study_area = c("cordova", "craig", "juneau", "ketchikan", "kodiak", "metlakatla", "petersburg", "seward", "sitka", "valdez", "wrangell"),
  code = c("co", "cr", "ju", "ke", "ko", "me", "pe", "se", "si", "va", "wr"),
  id_num = c("cs_054", "cs_055", "cs_056", "cs_057", "cs_058", "cs_059", "cs_060", "cs_061", "cs_062", "cs_063", "cs_064")
)

study_area_layers <- sf::st_layers(bathymetry_path)$name

for (layer in study_area_layers) {
  
  # Read the layer from the input GeoPackage
  data <- sf::st_read(dsn = bathymetry_path, layer = layer)
  
  # Extract the study area name from the layer name (assuming the name pattern)
  study_area <- sub("fiveacre_?([^_]+).*", "\\1", layer)
  
  # Convert the first letter of the study area name to lowercase
  study_area <- paste0(tolower(substring(study_area, 1, 1)), substring(study_area, 2))
  
  # Find the corresponding code in the code_dict
  code_index <- match(study_area, code_dict$study_area)
  code <- code_dict$code[code_index]
  
  # Update "depth_range_suspended" scenario
  data$depth_range_suspended <- ifelse(data$depth_range_suspended == "Y", 1, 
                                       ifelse(data$depth_range_suspended == "N", 0, data$depth_range_suspended))
  
  # Update ""depth_range_floating" scenario
  data$depth_range_floating <- ifelse(data$depth_range_floating == "Y", 1, 
                                      ifelse(data$depth_range_floating == "N", 0, data$depth_range_floating))
  
  # Update "depth_range_intertidal" scenario
  data$depth_range_intertidal <- ifelse(data$depth_range_intertidal == "Y", 1, 
                                        ifelse(data$depth_range_intertidal == "N", 0, data$depth_range_intertidal))
  
  # Create a "baseline" scenario
  data$baseline <- ifelse(data$bathy_max_mllw < -200, 0, 1)
  
  
  # Raw Geopackage
  # Define the output raw GeoPackage path
  output_gpkg <- file.path("C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data/extracted_bathymetry_hex_grids_scenarios.gpkg")
  
  # Write the layer to the raw output GeoPackage
  sf::st_write(obj = data, dsn = output_gpkg, layer = layer, append = FALSE)
  
  
  # Submodel Geopackage
  # Define the output submodel GeoPackage path
  sub_output_gpkg <- file.path("C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/study_area", study_area, "c_submodel_data/constraints/constraints.gpkg")
  
  # Find the corresponding id_num code in the code_dict
  id_code <- code_dict$id_num[code_index]
  
  # Create the new layer name based on the study area
  new_layer_name <- paste("ak", code, id_code, sep = "_")
  
  # Write the layer to the submodel output GeoPackage
  sf::st_write(obj = data, dsn = sub_output_gpkg, layer = new_layer_name, append = FALSE)
}

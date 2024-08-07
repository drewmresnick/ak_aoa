################################
### 41. Bathymetry  ###
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


bathymetry_path <- "C:/Users/Eliza.Carter/Documents/Projects/ak_aoa/data/extracted_bathymetry_hex_grids.gpkg"
output_base_path <- "C:/Users/Eliza.Carter/Documents/Projects/ak_aoa/study_area/study_area_240609"



code_dict <- list(
  study_area = c("cordova", "craig", "juneau", "ketchikan", "kodiak", "metlakatla", "petersburg", "seward", "sitka", "valdez", "wrangell"),
  code = c("co", "cr", "ju", "ke", "ko", "me", "pe", "se", "si", "va", "wr")
)

study_area_layers <- sf::st_layers(bathymetry_path)$name


for (layer in study_area_layers) {
  
  # Read the layer from the input GeoPackage
  data <- sf::st_read(dsn = bathymetry_path, layer = layer)
  
  # Extract the study area name from the layer name (assuming the name pattern)
  study_area <- sub("fiveacre_?([^_]+).*", "\\1", layer)
  #study_area <- gsub("fiveacre|_Tess_final", "", layer)
  
  # Convert the first letter of the study area name to lowercase
  study_area <- paste0(tolower(substring(study_area, 1, 1)), substring(study_area, 2))
  
  # Find the corresponding code in the code_dict
  code_index <- match(study_area, code_dict$study_area)
  code <- code_dict$code[code_index]
  
  # Update the columns "depth_range_suspended", "depth_range_floating", and "depth_range_intertidal" 
  data$depth_range_suspended <- ifelse(data$depth_range_suspended == "Y", 1, 
                                       ifelse(data$depth_range_suspended == "N", 0, data$depth_range_suspended))
  data$depth_range_floating <- ifelse(data$depth_range_floating == "Y", 1, 
                                      ifelse(data$depth_range_floating == "N", 0, data$depth_range_floating))
  data$depth_range_intertidal <- ifelse(data$depth_range_intertidal == "Y", 1, 
                                        ifelse(data$depth_range_intertidal == "N", 0, data$depth_range_intertidal))
  
  
  # Define the output GeoPackage path
  output_gpkg <- file.path(output_base_path, study_area, "b_intermediate_data/constraints/constraints.gpkg")
  
  # Create the new layer name based on the study area
  new_layer_name <- paste("ak_cs", code, "054", sep = "_")

                 
  
  # Write the layer to the output GeoPackage
  sf::st_write(obj = data, dsn = output_gpkg, layer = new_layer_name, append = FALSE)
}


###################################################################################
### 49. Constraint: extracting unconstrained suspended scenario hexes           ###
###################################################################################

# clear environment
rm(list = ls())

# calculate start time of code (determine how long it takes to complete all code)
start <- Sys.time()

#####################################
#####################################

# Load packages
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
               RSelenium,
               sf,
               shadowr,
               sp,
               stringr,
               terra, # is replacing the raster package
               tidyr,
               tidyverse)

##################################### 
##################################### 
# Set directories
## Input directories

### Study area directory
#### The hex grids are stored within individual study area directories. Instead of accessing and referencing 
#### multiple directories separately, we can simultaneously access the hex grids from the main study area directory
study_area_dir <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/study_area"

### Constraints results geopackage
#### The constraints submodel results were ran outside of these scripts. The results of that submodel run are 
#### part of the inputs for this process
##### 1.) ak_aoa_hexGrid_constraintsDataCombined
##### 2.) constraints_floating
##### 3.) constraints_intertidal
##### 4.) constraints_suspended
constraint_results <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/zzz_regional_data/ak_aoa_hexGrid_constraintsDataCombined.gpkg"

### list out the constraints scenario layers
layer <- c("constraints_suspended")


# code to assign to different study areas
code_dict <- list(
  study_area = c("cordova", "craig", "juneau", "ketchikan", "kodiak", "metlakatla", "petersburg", "seward", "sitka", "valdez", "wrangell"),
  code = c("co", "cr", "ju", "ke", "ko", "me", "pe", "se", "si", "va", "wr")
)


######################################
######################################
for(i in 1:length(code_dict$study_area)){
  
  # Convert the first letter of the study area name to lowercase
  study_area_name <- paste0(toupper(substring(code_dict$study_area[i], 1, 1)), substring(code_dict$study_area[i], 2))
  
  # function to clean data
  clean_data <- function(constraints){
    data_layer <- constraints %>%
      # filter for only active aquatic farm permits
      dplyr::filter(study_area == study_area_name) %>%
      dplyr::filter(constr_suspended == "1") 
    return(data_layer)
  }
  
  # Read the layer from the input GeoPackage
  data <- sf::st_read(dsn = constraint_results, layer = layer) %>% clean_data
  
  # Suitability Geopackage
  # Define the output suitability GeoPackage path
  suitability_output_gpkg <- file.path("C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/study_area", code_dict$study_area[i], "3_suspended/d_suitability_data/constraints/constraints_suitability_sp.gpkg")
  
  # Create the new layer name based on the study area
  new_layer_name <- paste("ak", code_dict$code[i], "cs_sp_unconstrained", sep = "_")
  
  # Write the layer to the submodel output GeoPackage
  sf::st_write(obj = data, dsn = suitability_output_gpkg, layer = new_layer_name, append = FALSE)

}

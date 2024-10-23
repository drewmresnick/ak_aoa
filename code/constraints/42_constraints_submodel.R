################################
### 42. Constraints submodel ###
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



#################################################

## CHANGE VERSION NUMBER BEFORE RUNNING ##

version_number <- v2

#################################################

#########
# when running the code for an individual study area:
# un-comment the following line and change the value to the corresponding study area in the lists above
# i = 1 (cordova)
# run everything below INSIDE the for loop -- do not run the first line
#########


# Define the study area lists
code_dict <- list(
  study_area = c("cordova", "craig", "juneau", "ketchikan", "kodiak", "metlakatla", "petersburg", "seward", "sitka", "valdez", "wrangell"),
  code = c("co", "cr", "ju", "ke", "ko", "me", "pe", "se", "si", "va", "wr")
)

# define the base directory
base <- "C:/Users/Eliza.Carter/Documents/Projects/ak_aoa/study_area/study_area/"


### Loop through each study area and code

for (i in seq_along(code_dict$study_area)) {
  study_area <- code_dict$study_area[i]
  code <- code_dict$code[i]
  
  #### study area grid
  study_region_gpkg <- paste0(base, study_area, "/b_intermediate_data/", study_area, "_study_area.gpkg")
  #### constraints
  submodel_gpkg <- paste0(base, study_area, "/c_submodel_data/constraints/constraints.gpkg")
  #### suitability
  suitability_dir <- paste0(base, study_area, "/")
  #### bathymetry path
  bathy_path <- paste0(base, study_area, "/b_intermediate_data/constraints/constraints.gpkg")
  
  
  ## designate region name
  region <- study_area
  
  ## study area code export name
  region_export_name <- code
  
  ## submodel export name
  submodel_export_name <- "cs"
  
  ## load hex grid (not dissolved) for each study area
  study_area_hex <- sf::st_read(dsn = study_region_gpkg, layer = paste(region, "fiveacre", sep = "_"))
  
  ## create lists of data layers and their codes
  layer_name <- c("dangerzones", 
                  "aton", 
                  "wrecksobs", 
                  "deepseacoral", 
                  "submarine", 
                  "submarineareas", 
                  "sensors",
                  "shippinglane",
                  "marine_highway",
                  "maintainedchannels",
                  "munitions",
                  "wastewater_pipe",
                  "ferry_terminals",
                  "ferry_routes",
                  "aquatic_farm_permit",
                  "active_aquatic_op",
                  "awc_stream",
                  "state_park",
                  "refuge_crithab_sanct",
                  "ci_fiberoptic",
                  "seafood_processing_discharge_loc",
                  "offshore_seafood_processors",
                  "seafood_processing_permitted_outfall",
                  "seafood_processing_permitted_net_pens",
                  "seafood_processing_permitted_carcass_disposal",
                  "seafood_processing_facility_locations",
                  "walrus_haulouts",
                  "Alaska_DEC_WQ_Monitoring_Locations",
                  "steller_sea_lion_haulout_buffers",
                  "poa_navigation_projects",
                  "poa_erosion_protection",
                  "landstatus_boundaries_refuge",
                  "ocean_disposal",
                  "pipelines",
                  "OffshoreOilGasPlatform",
                  "harbor_seal_haul_buff")
  
  ## create a list of all layer numbers
  layer_number <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 16, 17, 18, 19, 24, 25, 26, 27, 29, 30, 31, 32, 33, 34, 35, 36, 38, 41, 42, 43, 50, 51, 52, 53)
  
  ## create the layer code using the study area code and the layer number
  layer_code <- paste0("ak_", code, "_cs_", sprintf("%03d", layer_number)) 
  
  
  ## create an empty list to store the output 
  data_layers <- list()
  
  ## Loop through each data layer to load them into R
  for (j in seq_along(layer_name)) {
    layer_nm <- layer_name[j]
    layer_cd <- layer_code[j]
    
    # Check if layer_cd exists in the submodel_gpkg
    if (layer_cd %in% sf::st_layers(submodel_gpkg)$name) {
      # Construct the file path for each layer
      file_path <- paste0("study_area_", layer_nm)
      
      # Load the layer only if it exists in the submodel_gpkg
      data <- sf::st_read(dsn = submodel_gpkg, layer = layer_cd) %>%
        dplyr::mutate(!!sym(layer_nm) := 0) %>%
        sf::st_drop_geometry()
      
      # Store the constraint data in the list with file_path as the name
      data_layers[[file_path]] <- data
    }
  }
  
  ## load the first data layer as each study areas hex grid (study_area_hex)
  input <- study_area_hex
  
  # Names of layers that were successfully loaded
  loaded_layer_names <- names(data_layers)
  
  # group_by with dynamically generated column names
  group_by_columns <- intersect(loaded_layer_names, layer_name)
  
  # loop through each constraint in data_layers and left join it to result
  for (data_name in names(data_layers)) {
    input <- input %>%
      dplyr::left_join(data_layers[[data_name]], by = "GRID_ID") #join by GRID_ID
  }
  
  ## load in the scenario bathymetry file
  bath <- paste0("ak_", code, "_cs_054")
  
  scenarios <- sf::st_read(dsn = bathy_path, layer = bath) %>%
    sf::st_drop_geometry() %>%
    dplyr::select(-bathy_max_mllw, -bathy_min_mhw)
  
  ## name the result study_area_hex_constraints and join the bathymetry scenarios
  study_area_hex_constraints <- input %>%
    dplyr::left_join(scenarios, by = "GRID_ID")
  
  ## Verify duplicates
  duplicates_verify <- study_area_hex_constraints %>%
    dplyr::add_count(GRID_ID) %>%
    dplyr::filter(n > 1) %>%
    dplyr::distinct()
  
  ## remove duplicates -- keep only one result per cell
  study_area_constraints <- study_area_hex_constraints %>%
    dplyr::group_by_at(vars(GRID_ID, group_by_columns)) %>% # group by GRID_ID and constraint layers
    dplyr::distinct()
  
  
  ## function to create the constraints column
  create_constraints_column <- function(data) {
    # Check for 0s in each row across all columns except excluded ones
    constraints <- apply(data, 1, function(row) any(row == 0))
    # Convert logical vector to integer (1 for no zeros, 0 for at least one zero)
    constraints <- as.integer(!constraints)
    return(constraints)
  }
  
  
  ## create the scenarios
  suspended <- study_area_constraints %>%
    dplyr::select(-depth_range_floating, -depth_range_intertidal) 
  
  floating_bag <- study_area_constraints %>%
    dplyr::select(-depth_range_suspended, -depth_range_intertidal)
  
  intertidal <- study_area_constraints %>%
    dplyr::select(-depth_range_suspended, -depth_range_floating)
  
  ## apply the function to each scenario
  suspended$constraints <- create_constraints_column(suspended)
  floating_bag$constraints <- create_constraints_column(floating_bag)
  intertidal$constraints <- create_constraints_column(intertidal)
  
  
  ## export data
  sf::st_write(obj = suspended, dsn = paste0(suitability_dir, "3_suspended/d_suitability_data/constraints/suitability.gpkg") , layer = paste(region_export_name, submodel_export_name, "sp_suitability", version_number, sep = "_"), append = FALSE)
  
  sf::st_write(obj = floating_bag, dsn = paste0(suitability_dir, "2_floating_bag/d_suitability_data/constraints/suitability.gpkg") , layer = paste(region_export_name, submodel_export_name, "fb_suitability", version_number, sep = "_"), append = FALSE)
  
  sf::st_write(obj = intertidal, dsn = paste0(suitability_dir, "1_intertidal/d_suitability_data/constraints/suitability.gpkg") , layer = paste(region_export_name, submodel_export_name, "ib_suitability", version_number, sep = "_"), append = FALSE)
  
  
}

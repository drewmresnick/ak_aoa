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
submodel <- "cs"

#####################################
#####################################
# set directories

## input data 
### exploratory constraints geopackage dire
data_dir <- "data/aa_exploration_data/constraints"


## output directory
### constraints submodel geopackage (raw data)
raw_constraints_geopackage <- "data/a_raw_data/constraints/constraints.gpkg"

#####################################
#####################################

# Danger Zones and Restricted Areas ak_cs_001
dangerzones <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                              layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_001",
                                                                        sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])


# Aids to Navigation ak_cs_002
aton <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                    layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_002",
                                                                                                    sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])


# Wrecks and Obstructions ak_cs_003
wrecksobs <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                         layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_003",
                                                                                                         sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])



# Deep Sea Coral Observations ak_cs_004
deepseacoral <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                           layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_004",
                                                                                                           sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])



# NOAA Charted Submarine Cables ak_cs_005
submarine <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                         layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_005",
                                                                                                         sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])


# Submarine Cable Areas ak_cs_006
submarineareas <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                              layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_006",
                                                                                                              sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])


# Environmental Sensors and Buoys ak_cs_007
sensors <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                       layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_007",
                                                                                                       sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])


# Shipping Fairways, Lanes, and Zones for US waters ak_cs_008
shippinglane <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                            layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_008",
                                                                                                            sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])


# Alaska Marine Highway	ak_cs_009
marine_highway <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                              layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_009",
                                                                                                              sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])


# Coastal Maintained Channels	ak_cs_010
maintainedchannels <- sf::st_read(dsn = file.path(data_dir, "maintainedchannels/maintainedchannels.shp"))


# Munitions and Explosives of Concern	ak_cs_012
munitions <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                         layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_012",
                                                                                                         sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])


# Wastewater Outfalls: Wastewater Outfall Pipes	ak_cs_015
wastewater_pipe <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                              layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_015",
                                                                                                              sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])


# Ferry Terminals	ak_cs_016
ferry_terminals <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                               layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_016",
                                                                                                               sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])


# Ferry Routes	ak_cs_017
ferry_routes <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                            layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_017",
                                                                                                            sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])



# Aquatic Farm Permit or Lease	ak_cs_018
aquatic_farm_permit <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                                   layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_018",
                                                                                                                   sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])



# ADF&G Active Aquatic Farming Operation Areas	ak_cs_019
active_aquatic_op <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                                 layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_019",
                                                                                                                 sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])


# Anadromous Water Catalog: Stream	ak_cs_024
awc_stream <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                          layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_024",
                                                                                                          sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])



# Alaska State Parks	ak_cs_025
state_park <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                          layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_025",
                                                                                                          sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])


# Alaska State Game Refuges, Critical Habitat, Sanctuaries	ak_cs_026
refuge_crithab_sanct <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                                    layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_026",
                                                                                                                    sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])




# Cook Inlet Fiberoptic Network	ak_cs_027
ci_fiberoptic <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                             layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_027",
                                                                                                             sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])


# Seafood Processing Discharge Locations	ak_cs_029
seafood_processing_discharge_loc <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                                                layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_029",
                                                                                                                                sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])



# Alaska DEC Seafood Processing Facilities: AKG5253000 Offshore Seafood Processors	ak_cs_030
offshore_seafood_processors <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                                           layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_030",
                                                                                                                           sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])




# Alaska DEC Seafood Processing Facilities: AKG130000 Permitted Outfall	ak_cs_031
seafood_processing_permitted_outfall <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                                                    layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_031",
                                                                                                                                    sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])



# Alaska DEC Seafood Processing Facilities: AKG130000 Permitted Net Pens	ak_cs_032
seafood_processing_permitted_net_pens <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                                                     layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_032",
                                                                                                                                     sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])



# Alaska DEC Seafood Processing Facilities: AKG130000 Permitted Carcass Disposal Site	ak_cs_033
seafood_processing_permitted_carcass_disposal <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                                                             layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_033",
                                                                                                                                             sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])


# Alaska DEC Seafood Processing Facilities: Seafood Processing Facility Locations	ak_cs_034
seafood_processing_facility_locations <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                                                     layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_034",
                                                                                                                                     sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])



# Pacific Walrus Buffered Haulouts 1852-2016	ak_cs_035
walrus_haulouts <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                               layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_035",
                                                                                                               sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])



# Alaska DEC WQ Monitoring Locations	ak_cs_036
Alaska_DEC_WQ_Monitoring_Locations <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                                                  layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_036",
                                                                                                                                  sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])




# Steller Sea Lion Haul-out 500m Buffers	ak_cs_038
steller_sea_lion_haulout_buffers <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                                                layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_038",
                                                                                                                                sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])


# POA Civil works projects- Navigation Projects	ak_cs_041
poa_navigation_projects <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                                       layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_041",
                                                                                                                       sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])





# POA Civil works projects- Erosion Protection and Flood Mitigation Projects	ak_cs_042
poa_erosion_protection <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                                      layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_042",
                                                                                                                      sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])



# Land Status within the National Wildlife Refuges of Alaska: Boundaries Refuge	ak_cs_043
landstatus_boundaries_refuge <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                                            layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_043",
                                                                                                                            sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])

# Ocean disposal sites	ak_cs_050
ocean_disposal <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                              layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_050",
                                                                                                              sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])


# Oil and Gas pipelines	ak_cs_051
pipelines <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                         layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_051",
                                                                                                         sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])

# Oil and gas platforms	ak_cs_052
OffshoreOilGasPlatform <- sf::st_read(dsn = paste(data_dir, "constraints.gpkg", sep = "/"),
                                      layer = sf::st_layers(paste(data_dir, "constraints.gpkg", sep = "/"))[[1]][grep(pattern = "ak_cs_052",
                                                                                                                      sf::st_layers(dsn = paste(data_dir, "constraints.gpkg", sep = "/"))[[1]])])

# Alaska Harbor Seal Haul-out 500m Buffers	ak_cs_053
harbor_seal_haul_buff <- sf::st_read(dsn = file.path(data_dir, "harbor_seal_haulouts_500m_buffer/harbor_seal_haulouts_500m_buffer.shp"))



#####################################
#####################################

# create list of the datasets
data <- list(dangerzones,
             aton,
             wrecksobs,
             deepseacoral,
             submarine,
             submarineareas,
             sensors,
             shippinglane,
             marine_highway,
             maintainedchannels,
             munitions,
             wastewater_pipe,
             ferry_terminals,
             ferry_routes,
             aquatic_farm_permit,
             active_aquatic_op,
             awc_stream,
             state_park,
             refuge_crithab_sanct,
             ci_fiberoptic,
             seafood_processing_discharge_loc,
             offshore_seafood_processors,
             seafood_processing_permitted_outfall,
             seafood_processing_permitted_net_pens,
             seafood_processing_permitted_carcass_disposal,
             seafood_processing_facility_locations,
             walrus_haulouts,
             Alaska_DEC_WQ_Monitoring_Locations,
             harbor_seal_haulouts,
             steller_sea_lion_haulout_buffers,
             poa_navigation_projects,
             poa_erosion_protection,
             landstatus_boundaries_refuge,
             ocean_disposal,
             pipelines,
             OffshoreOilGasPlatform,
             harbor_seal_haul_buff)


#####################################
# Sanity check, you above list should have 34 variables
length(data)


#####################################
#####################################

# list out the corresponding codes so that we can rename them in the geopackage

data_codes <- c("ak_cs_001",
              "ak_cs_002",
              "ak_cs_003",
              "ak_cs_004",
              "ak_cs_005",
              "ak_cs_006",
              "ak_cs_007",
              "ak_cs_008",
              "ak_cs_009",
              "ak_cs_010",
              "ak_cs_012",
              "ak_cs_015",
              "ak_cs_016",
              "ak_cs_017",
              "ak_cs_018",
              "ak_cs_019",
              "ak_cs_024",
              "ak_cs_025",
              "ak_cs_026",
              "ak_cs_027",
              "ak_cs_029",
              "ak_cs_030",
              "ak_cs_031",
              "ak_cs_032",
              "ak_cs_033",
              "ak_cs_034",
              "ak_cs_035",
              "ak_cs_036",
              "ak_cs_038",
              "ak_cs_041",
              "ak_cs_042",
              "ak_cs_043",
              "ak_cs_050",
              "ak_cs_051",
              "ak_cs_052",
              "ak_cs_053")



#####################################
# Sanity check, you above list should have 36 variables
length(data_codes)

#####################################
#####################################
# export all datasets with new codes
for(i in seq_along(data)){
  # grab the dataset
  dataset <- data[[i]]
  
  # export the dataset
  sf::st_write(obj = dataset, dsn = raw_constraints_geopackage, layer = data_codes[i], append = F)
}

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate

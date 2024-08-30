##################################################
### 0. Data Codes -- constraints               ###
##################################################

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
## submodel raw data directory
data_dir <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/aa_exploration_data/constraints"

list.files(data_dir)
list.dirs(data_dir, recursive = TRUE)

## constraints submodel geopackage
constraints_geopackage <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/aa_exploration_data/constraints/constraints.gpkg"

#####################################
#####################################


# Danger Zones and Restricted Areas ak_cs_001
dangerzones <- sf::st_read(dsn = file.path(data_dir, "DangerZoneRestrictedArea/DangerZoneRestrictedArea.gpkg"),
                           layer = sf::st_layers(file.path(data_dir, "DangerZoneRestrictedArea/DangerZoneRestrictedArea.gpkg"))[[1]][1])



# Aids to Navigation ak_cs_002
aton <- sf::st_read(dsn = file.path(data_dir, "AtoN/AtoN.gpkg"),
                    layer = sf::st_layers(file.path(data_dir, "AtoN/AtoN.gpkg"))[[1]][1])


# Wrecks and Obstructions ak_cs_003
wrecksobs <- sf::st_read(dsn = file.path(data_dir, "WreckObstruction/WreckObstruction.gpkg"),
                         layer = sf::st_layers(file.path(data_dir, "WreckObstruction/WreckObstruction.gpkg"))[[1]][1])


# Deep Sea Coral Observations ak_cs_004
deepseacoral <- sf::st_read(dsn = file.path("C:/GIS/Projects/ak_aoa_constraints/ak_aoa_constraints.gdb"),
                            layer = sf::st_layers(file.path("C:/GIS/Projects/ak_aoa_constraints/ak_aoa_constraints.gdb"))[[1]][grep(pattern = "deep_sea_coral_sponge_pts",
                                                                                                                                    sf::st_layers(dsn = file.path("C:/GIS/Projects/ak_aoa_constraints/ak_aoa_constraints.gdb"))[[1]])])


# NOAA Charted Submarine Cables ak_cs_005
submarine <- sf::st_read(dsn = file.path(data_dir, "SubmarineCable/NOAAChartedSubmarineCables.gdb"),
                         layer = sf::st_layers(file.path(data_dir, "SubmarineCable/NOAAChartedSubmarineCables.gdb"))[[1]][grep(pattern = "NOAAChartedSubmarineCables",
                                                                                                                               sf::st_layers(dsn = file.path(data_dir, "SubmarineCable/NOAAChartedSubmarineCables.gdb"))[[1]])])


# Submarine Cable Areas ak_cs_006
submarineareas <- sf::st_read(dsn = file.path(data_dir, "SubmarineCableArea/SubmarineCableArea.gpkg"),
                              layer = sf::st_layers(file.path(data_dir, "SubmarineCableArea/SubmarineCableArea.gpkg"))[[1]][1])



# Environmental Sensors and Buoys ak_cs_007
sensors <- sf::st_read(dsn = file.path(data_dir, "sensors_and_buoys/marineobs_ndbc_by_pgm.shp"))


# Shipping Fairways, Lanes, and Zones for US waters ak_cs_008
shippinglane <- sf::st_read(dsn = file.path(data_dir, "shippinglanes/shippinglanes.shp"))


# Alaska Marine Highway	ak_cs_009
marine_highway <- sf::st_read(dsn = file.path(data_dir, "alaska_marine_highway/alaska_marine_highwayLine.shp"))



# Coastal Maintained Channels	ak_cs_010
maintainedchannels <- sf::st_read(dsn = file.path(data_dir, "maintainedchannels/maintainedchannels.shp"))



# Formerly Used Defense Sites	ak_cs_011
fuds <- sf::st_read(dsn = file.path(data_dir, "FormerlyUsedDefenseSite/FormerlyUsedDefenseSite.gpkg"),
                    layer = sf::st_layers(file.path(data_dir, "FormerlyUsedDefenseSite/FormerlyUsedDefenseSite.gpkg"))[[1]][1])


# Munitions and Explosives of Concern	ak_cs_012
munitions <- sf::st_read(dsn = file.path(data_dir, "MunitionsExplosivesConcern/MunitionsExplosivesConcern.gpkg"),
                         layer = sf::st_layers(file.path(data_dir, "MunitionsExplosivesConcern/MunitionsExplosivesConcern.gpkg"))[[1]][1])


# Wastewater Outfalls	ak_cs_013
wastewater_outfall <- sf::st_read(dsn = paste(data_dir, "WastewaterOutfall/WastewaterOutfall.gpkg", sep = "/"),
                                  layer = sf::st_layers(paste(data_dir, "WastewaterOutfall/WastewaterOutfall.gpkg", sep = "/"))[[1]][grep(pattern = "Outfall",
                                                                                                                                          sf::st_layers(dsn = paste(data_dir, "WastewaterOutfall/WastewaterOutfall.gpkg", sep = "/"))[[1]])])

# Wastewater Outfalls: Wastewater Facility	ak_cs_014
wastewater_facility <- sf::st_read(dsn = paste(data_dir, "WastewaterOutfall/WastewaterOutfall.gpkg", sep = "/"),
                                   layer = sf::st_layers(paste(data_dir, "WastewaterOutfall/WastewaterOutfall.gpkg", sep = "/"))[[1]][grep(pattern = "Facility",
                                                                                                                                           sf::st_layers(dsn = paste(data_dir, "WastewaterOutfall/WastewaterOutfall.gpkg", sep = "/"))[[1]])])



# Wastewater Outfalls: Wastewater Outfall Pipes	ak_cs_015
wastewater_pipe <- sf::st_read(dsn = paste(data_dir, "WastewaterOutfall/WastewaterOutfall.gpkg", sep = "/"),
                               layer = sf::st_layers(paste(data_dir, "WastewaterOutfall/WastewaterOutfall.gpkg", sep = "/"))[[1]][grep(pattern = "Pipe",
                                                                                                                                       sf::st_layers(dsn = paste(data_dir, "WastewaterOutfall/WastewaterOutfall.gpkg", sep = "/"))[[1]])])


# Ferry Terminals	ak_cs_016
ferry_terminals <- sf::st_read(dsn = file.path(data_dir, "ferry_terminals/Ferry_Terminal.shp"))


# Ferry Routes	ak_cs_017
ferry_routes <- sf::st_read(dsn = file.path(data_dir, "ferry_routes/Ferry_Routes_DS_ferry_routes_October_31_2019.shp"))


# Aquatic Farm Permit or Lease	ak_cs_018
aquatic_farm_permit <- sf::st_read(dsn = file.path(data_dir, "aquaculture_farm_permit_lease/Aquaculture.shp"))


# ADF&G Active Aquatic Farming Operation Areas	ak_cs_019
active_aquatic_op <- sf::st_read(dsn = file.path(data_dir, "active_aquatic_farming_operation_areas/active_aquatic_farming_operation_areas.shp"))



# Anadromous Water Catalog: Barrier	ak_cs_020
awc_barrier <- sf::st_read(dsn = file.path(data_dir, "anadromous_water_catalog/AWC2023.gdb"),
                           layer = sf::st_layers(file.path(data_dir, "anadromous_water_catalog/AWC2023.gdb"))[[1]][grep(pattern = "AWC_barrier",
                                                                                                                        sf::st_layers(dsn = file.path(data_dir, "anadromous_water_catalog/AWC2023.gdb"))[[1]])])




# Anadromous Water Catalog: Lake	ak_cs_021
awc_lake <- awc <- sf::st_read(dsn = file.path(data_dir, "anadromous_water_catalog/AWC2023.gdb"),
                               layer = sf::st_layers(file.path(data_dir, "anadromous_water_catalog/AWC2023.gdb"))[[1]][grep(pattern = "AWC_lake",
                                                                                                                            sf::st_layers(dsn = file.path(data_dir, "anadromous_water_catalog/AWC2023.gdb"))[[1]])])





# Anadromous Water Catalog: Point	ak_cs_022
awc_pt <- sf::st_read(dsn = file.path(data_dir, "anadromous_water_catalog/AWC2023.gdb"),
                      layer = sf::st_layers(file.path(data_dir, "anadromous_water_catalog/AWC2023.gdb"))[[1]][grep(pattern = "AWC_Point",
                                                                                                                   sf::st_layers(dsn = file.path(data_dir, "anadromous_water_catalog/AWC2023.gdb"))[[1]])])



# Anadromous Water Catalog: Polygon	ak_cs_023
awc_poly <- sf::st_read(dsn = file.path(data_dir, "anadromous_water_catalog/AWC2023.gdb"),
                        layer = sf::st_layers(file.path(data_dir, "anadromous_water_catalog/AWC2023.gdb"))[[1]][grep(pattern = "AWC_poly",
                                                                                                                     sf::st_layers(dsn = file.path(data_dir, "anadromous_water_catalog/AWC2023.gdb"))[[1]])])



# Anadromous Water Catalog: Stream	ak_cs_024
awc_stream <- sf::st_read(dsn = file.path(data_dir, "anadromous_water_catalog/AWC2023.gdb"),
                          layer = sf::st_layers(file.path(data_dir, "anadromous_water_catalog/AWC2023.gdb"))[[1]][grep(pattern = "AWC_stream",
                                                                                                                       sf::st_layers(dsn = file.path(data_dir, "anadromous_water_catalog/AWC2023.gdb"))[[1]])])



# Alaska State Parks	ak_cs_025
state_park <- sf::st_read(dsn = file.path(data_dir, "ak_state_park_boundary/State_Park_Boundary.shp"))


# Alaska State Game Refuges, Critical Habitat, Sanctuaries	ak_cs_026
refuge_crithab_sanct <- sf::st_read(dsn = file.path(data_dir, "ak_gamerefuges_crtihab_sanct/Alaska_DEC_Sensitive_Areas.shp"))


# Cook Inlet Fiberoptic Network	ak_cs_027
ci_fiberoptic <- sf::st_read(dsn = file.path(data_dir, "ci_fiberoptic/ci_fiberoptic.shp"))



# Cook Inlet Pipelines	ak_cs_028
ci_pipes <- sf::st_read(dsn = file.path(data_dir, "ci_pipes/ci_pipes.shp"))

# Seafood Processing Discharge Locations	ak_cs_029
seafood_processing_discharge_loc <- sf::st_read(dsn = file.path(data_dir, "seafood_processing_discharge_locations/seafood_processing_discharge_locations.shp"))


# Alaska DEC Seafood Processing Facilities: AKG5253000 Offshore Seafood Processors	ak_cs_030
offshore_seafood_processors <- sf::st_read(dsn = file.path(data_dir, "offshore_seafood_processors_permitted_vessels/offshore_seafood_processors_permitted_vessels.shp"))



# Alaska DEC Seafood Processing Facilities: AKG130000 Permitted Outfall	ak_cs_031
seafood_processing_permitted_outfall <- sf::st_read(dsn = file.path(data_dir, "seafood_processing_permitted_outfall/seafood_processing_permitted_outfall.shp"))


# Alaska DEC Seafood Processing Facilities: AKG130000 Permitted Net Pens	ak_cs_032
seafood_processing_permitted_net_pens <- sf::st_read(dsn = file.path(data_dir, "seafood_processing_permitted_net_pens/seafood_processing_permitted_net_pens.shp"))


# Alaska DEC Seafood Processing Facilities: AKG130000 Permitted Carcass Disposal Site	ak_cs_033
seafood_processing_permitted_carcass_disposal <- sf::st_read(dsn = file.path(data_dir, "seafood_processing_permitted_carcass_disposal/seafood_processing_permitted_carcass_disposal.shp"))


# Alaska DEC Seafood Processing Facilities: Seafood Processing Facility Locations	ak_cs_034
seafood_processing_facility_locations <- sf::st_read(dsn = file.path(data_dir, "seafood_processing_facility_locations/seafood_processing_facility_locations.shp"))


# Pacific Walrus Buffered Haulouts 1852-2016	ak_cs_035
walrus_haulouts <- sf::st_read(dsn = file.path(data_dir, "hauloutsdb_buffer_3338_4326/hauloutsdb_buffer_3338_4326.shp"), options = "ENCODING=WINDOWS-1252")


# Alaska DEC WQ Monitoring Locations	ak_cs_036
Alaska_DEC_WQ_Monitoring_Locations <- sf::st_read(dsn = file.path(data_dir, "Alaska_DEC_WQ_Monitoring_Locations/Alaska_DEC_WQ_Monitoring_Locations.shp"))


# Alaska Harbor Seal Haul-out Locations	ak_cs_037
harbor_seal_haulouts <- sf::st_read(dsn = file.path(data_dir, "harbor_seal_haulouts/harbor_seal_haulouts.shp"))



# Steller Sea Lion Haul-out 500m Buffers	ak_cs_038
steller_sea_lion_haulout_buffers <- sf::st_read(dsn = file.path(data_dir, "steller_sea_lion_haulout_buffers/steller_sea_lion_haulout_buffers.shp"))



# National Park Service Boundary Data (for Glacier Bay)	ak_cs_039
nps_boundary_data_service <-  sf::st_read(dsn = file.path(data_dir, "glacier_bay_np_preserve/glacier_bay_np_preserve.shp"))



# National Park Service Tract Data (for Glacier Bay)	ak_cs_040
nps_tract_data_service <-  sf::st_read(dsn = file.path(data_dir, "glacier_bay_np_tracts/glacier_bay_np_tracts.shp"))


# POA Civil works projects- Navigation Projects	ak_cs_041
poa_navigation_projects <- sf::st_read(dsn = file.path(data_dir, "poa_navigation_projects/poa_navigation_projects.shp"))



# POA Civil works projects- Erosion Protection and Flood Mitigation Projects	ak_cs_042
poa_erosion_protection <- sf::st_read(dsn = file.path(data_dir, "poa_erosion_protection_and_flood_mitigation_projects/poa_erosion_protection_and_flood_mitigation_projects.shp"))


# Land Status within the National Wildlife Refuges of Alaska: Boundaries Refuge	ak_cs_043
landstatus_boundaries_refuge <- sf::st_read(dsn = file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"),
                                            layer = sf::st_layers(file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"))[[1]][grep(pattern = "Boundaries_Refuge",
                                                                                                                                                                               sf::st_layers(dsn = file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"))[[1]])])





# Land Status within the National Wildlife Refuges of Alaska: Boundaries Wilderness	ak_cs_044
landstatus_boundaries_wild <- sf::st_read(dsn = file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"),
                                          layer = sf::st_layers(file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"))[[1]][grep(pattern = "Boundaries_Wilderness",
                                                                                                                                                                             sf::st_layers(dsn = file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"))[[1]])])



# Land Status within the National Wildlife Refuges of Alaska: Marine Coastline	ak_cs_045
landstatus_coastline <- sf::st_read(dsn = file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"),
                                    layer = sf::st_layers(file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"))[[1]][grep(pattern = "Marine_Coastline",
                                                                                                                                                                       sf::st_layers(dsn = file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"))[[1]])])



# Land Status within the National Wildlife Refuges of Alaska: Subsurface Current	ak_cs_046
landstatus_sub_current <- sf::st_read(dsn = file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"),
                                      layer = sf::st_layers(file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"))[[1]][grep(pattern = "Subsurface_Current",
                                                                                                                                                                         sf::st_layers(dsn = file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"))[[1]])])


# Land Status within the National Wildlife Refuges of Alaska: Subsurface Off Refuge	ak_cs_047
landstatus_sub_offrefuge <- sf::st_read(dsn = file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"),
                                        layer = sf::st_layers(file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"))[[1]][grep(pattern = "Subsurface_Off_Refuge",
                                                                                                                                                                           sf::st_layers(dsn = file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"))[[1]])])



# Land Status within the National Wildlife Refuges of Alaska: Surface Current	ak_cs_048
landstatus_suface_current <- sf::st_read(dsn = file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"),
                                         layer = sf::st_layers(file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"))[[1]][grep(pattern = "Surface_Current",
                                                                                                                                                                            sf::st_layers(dsn = file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"))[[1]])])



# Land Status within the National Wildlife Refuges of Alaska: Surface Off Refuge	ak_cs_049
landstatus_surface_offrefuge <- sf::st_read(dsn = file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"),
                                            layer = sf::st_layers(file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"))[[1]][grep(pattern = "Surface_Off_Refuge",
                                                                                                                                                                               sf::st_layers(dsn = file.path(data_dir, "USFWS-Region-7-Land-Status.gdb/USFWS Region 7 Land Status (2024-05-16).gdb"))[[1]])])


# Ocean disposal sites	ak_cs_050
ocean_disposal <- sf::st_read(dsn = file.path(data_dir, "OceanDisposalSite/OceanDisposalSite.gpkg"),
                              layer = sf::st_layers(file.path(data_dir, "OceanDisposalSite/OceanDisposalSite.gpkg"))[[1]][1])




# Oil and Gas pipelines	ak_cs_051
pipelines <- sf::st_read(dsn = file.path(data_dir, "Pipeline/Pipelines.gdb"),
                         layer = sf::st_layers(file.path(data_dir, "Pipeline/Pipelines.gdb"))[[1]][grep(pattern = "Pipelines",
                                                                                                        sf::st_layers(dsn = file.path(data_dir, "Pipeline/Pipelines.gdb"))[[1]])])



# Oil and gas platforms	ak_cs_052
OffshoreOilGasPlatform <- sf::st_read(dsn = file.path(data_dir, "OffshoreOilGasPlatform/OffshoreOilGasPlatform.gpkg"),
                                      layer = sf::st_layers(file.path(data_dir, "OffshoreOilGasPlatform/OffshoreOilGasPlatform.gpkg"))[[1]][1])


# Alaska Harbor Seal Haul-out 500m Buffers	ak_cs_053
harbor_seal_haul_buff <- sf::st_read(dsn = file.path(data_dir, "harbor_seal_haulouts_500m_buffer/harbor_seal_haulouts_500m_buffer.shp"))



# added later on, raw processed by Isaac K. and further processed by Eliza C.
# Bathymetry: Cordova	ak_cs_054
bathy_cordova <- sf::st_read(dsn = file.path("C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data/extracted_bathymetry_hex_grids_scenarios.gpkg"), layer = "fiveacreCordova_Tess_Final")


# Bathymetry: Craig	ak_cs_055
bathy_craig <- sf::st_read(dsn = file.path("C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data/extracted_bathymetry_hex_grids_scenarios.gpkg"), layer = "fiveacreCraig_Tess_Final")

# Bathymetry: Juneau	ak_cs_056
bathy_juneau <- sf::st_read(dsn = file.path("C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data/extracted_bathymetry_hex_grids_scenarios.gpkg"), layer = "fiveacreJuneau_Tess_Final")

# Bathymetry: Ketchikan	ak_cs_057
bathy_ketchikan <- sf::st_read(dsn = file.path("C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data/extracted_bathymetry_hex_grids_scenarios.gpkg"), layer = "fiveacre_Ketchikan_Tess_Final")

# Bathymetry: Kodiak	ak_cs_058
bathy_kodiak <- sf::st_read(dsn = file.path("C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data/extracted_bathymetry_hex_grids_scenarios.gpkg"), layer = "fiveacreKodiak_Tess_Final")


# Bathymetry: Metlakatla	ak_cs_059
bathy_metlakatla <- sf::st_read(dsn = file.path("C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data/extracted_bathymetry_hex_grids_scenarios.gpkg"), layer = "fiveacreMetlakatla_Tess_Final")


# Bathymetry: Petersburg	ak_cs_060
bathy_petersburg <- sf::st_read(dsn = file.path("C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data/extracted_bathymetry_hex_grids_scenarios.gpkg"), layer = "fiveacrePetersburg_Tess_Final")


# Bathymetry: Seward	ak_cs_061
bathy_seward <- sf::st_read(dsn = file.path("C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data/extracted_bathymetry_hex_grids_scenarios.gpkg"), layer = "fiveacreSeward_Tess_Final")


# Bathymetry: Sitka	ak_cs_062
bathy_sitka <- sf::st_read(dsn = file.path("C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data/extracted_bathymetry_hex_grids_scenarios.gpkg"), layer = "fiveacreSitka_Tess_Final")


# Bathymetry: Valdez	ak_cs_063
bathy_valdez <- sf::st_read(dsn = file.path("C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data/extracted_bathymetry_hex_grids_scenarios.gpkg"), layer = "fiveacreValdez_Tess_Final")

# Bathymetry: Wrangell 	ak_cs_064
bathy_wrangell <- sf::st_read(dsn = file.path("C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data/extracted_bathymetry_hex_grids_scenarios.gpkg"), layer = "fiveacreWrangell_Tess_Final")


# Anchorages	ak_cs_065
anchor <- sf::st_read(dsn = file.path(data_dir, "Anchorage/Anchorage.gpkg"))

# Area Plan Management Units - No Aquaculture	ak_cs_066
area_plan <- sf::st_read(dsn = file.path(data_dir, "AKAP_AOA_Overlap_8_14/AKAP_AOA_Overlap.gdb"), layer = "POWAP_No_Aq")


#####################################
#####################################

# create list of the datasets
data <- list(
              # dangerzones,
              # aton,
              # wrecksobs,
              # deepseacoral,
              # submarine,
              # submarineareas,
              # sensors,
              # shippinglane,
              # marine_highway,
              # maintainedchannels,
              # fuds,
              # munitions,
              # wastewater_outfall,
              # wastewater_facility,
              # wastewater_pipe,
              # ferry_terminals,
              # ferry_routes,
              # aquatic_farm_permit,
              # active_aquatic_op,
              # awc_barrier,
              # awc_lake,
              # awc_pt,
              # awc_poly,
              # awc_stream,
              # state_park,
              # refuge_crithab_sanct,
              # ci_fiberoptic,
              # ci_pipes,
              # seafood_processing_discharge_loc,
              # offshore_seafood_processors,
              # seafood_processing_permitted_outfall,
              # seafood_processing_permitted_net_pens,
              # seafood_processing_permitted_carcass_disposal,
              # seafood_processing_facility_locations,
              # walrus_haulouts,
              # Alaska_DEC_WQ_Monitoring_Locations,
              # harbor_seal_haulouts,
              # steller_sea_lion_haulout_buffers,
              # nps_boundary_data_service,
              # nps_tract_data_service,
              # poa_navigation_projects,
              # poa_erosion_protection,
              # landstatus_boundaries_refuge,
              # landstatus_boundaries_wild,
              # landstatus_coastline,
              # landstatus_sub_current,
              # landstatus_sub_offrefuge,
              # landstatus_suface_current,
              # landstatus_surface_offrefuge,
              # ocean_disposal,
              # pipelines,
              # OffshoreOilGasPlatform,
              # harbor_seal_haul_buff,
              # bathy_cordova,
              # bathy_craig,
              # bathy_juneau,
              # bathy_ketchikan,
              # bathy_kodiak,
              # bathy_metlakatla,
              # bathy_petersburg,
              # bathy_seward,
              # bathy_sitka,
              # bathy_valdez,
              # bathy_wrangell,
              # anchor,
              area_plan)

#####################################
# Sanity check
length(data)

#####################################

# create a sequence starting from 1 to the length of the number of the datasets by an increment of 1
data_order <- seq(from = 66,
                  to = 67,
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
  sf::st_write(obj = dataset, dsn = constraints_geopackage, layer = data_code[i], append = F)
}

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate

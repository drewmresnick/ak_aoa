##############################################
### 0. Download Data -- Constraints        ###
##############################################

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
               sf,
               sp,
               stringr,
               terra, # is replacing the raster package
               tidyr)

#####################################
#####################################

# Commentary on R and code formulation:
## ***Note: If not familiar with dplyr notation
## dplyr is within the tidyverse and can use %>%
## to "pipe" a process, allowing for fluidity
## Can learn more here: https://style.tidyverse.org/pipes.html

## Another common coding notation used is "::"
## For instance, you may encounter it as dplyr::filter()
## This means "use the filter function from the dplyr package"
## Notation is used given sometimes different packages have
## the same function name, so it helps code to tell which
## package to use for that particular function.
## The notation is continued even when a function name is
## unique to a particular package so it is obvious which
## package is used

#####################################
#####################################

# set directories
## define data directory (as this is an R Project, pathnames are simplified)
data_dir <- "C:/Users/Breanna.Xiong/Documents/R Scripts/Carolinas/data/a_raw_data/natural_resources/direct_download"

#####################################
#####################################

# download data
## natural resources
### Audobon Important Areas
audobon <- "https://marinecadastre.gov/downloads/data/mc/AudubonImportantBirdArea.zip"

### Bottlenose Dolphin Take Reduction Plan Northern North Carolina
n_nc_bdtrp <- "https://media.fisheries.noaa.gov/2020-04/bdtrp_n_nc_po.zip"

### Bottlenose Dolphin Take Reduction Plan South Carolina, Georgia and Florida
sc_bdtrp <- "https://media.fisheries.noaa.gov/2020-04/bdtrp_sc_fl_po_0.zip"

### Bottlenose Dolphin Take Reduction Plan Southern North Carolina
s_nc_bdtrp <- "https://media.fisheries.noaa.gov/2020-04/bdtrp_s_nc_po.zip"

### Cetacean Biologically Important Areas
cetacean_bia <-"http://cetsound.noaa.gov/Assets/cetsound/data/CetMap_BIA_WGS84.zip"

### Chesapeake Bay Environmental Sensitivty Index 2016
#### 1.) Invertebrates -- point
#### 2.) Invertebrates -- polygon
#### 3.) Marine mammals
#### 4.) Herp
#### 5.) Habitat
#### 6.) Fish -- point
#### 7.) Fish - polygon
#### 8.) Bird -- point
#### 9.) Bird -- polygon
#### 10.) Benthic
#### 11.) Terrestrial Mammals
#### 12.) ESI -- line
#### 13.) ESI -- polygon
#### 14.) Resource Management -- point
#### 15.) Resource Management -- polygon
cb_esi_2016 <- "https://response.restoration.noaa.gov/sites/default/files/esimaps/gisdata/ChesapeakeBay_2016_GDB.zip"

### Coastal Barrier Resource System
cbra <- "https://marinecadastre.gov/downloads/data/mc/CoastalBarrierResourceAreas.zip"

### Coastal Critical Habitat Designations
coastal_crtihab <- "https://marinecadastre.gov/downloads/data/mc/CoastalCriticalHabitat.zip"

### Coastal Migratory Pelagics EFH-HAPC
### costmigpelhapc <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:coastmigpelhapc"

### Coastal Virginia Ecological Value Assessment (Coastal VEVA)
coastal_veva <- "https://dwr.virginia.gov/-/gis-data/veva_shapefile.zip"

### Coastal Wetlands
coastal_wetlands <- "https://marinecadastre.gov/downloads/data/mc/CoastalWetland.zip"

### Coral, Coral Reefs, Live or Hard Bottom EFH-HAPC
# coral_hapc <- "coralhapc https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:coralhapc"

### Deep-sea Coral and Sponge Observations
deepsea_coral_obs <- "https://marinecadastre.gov/downloads/data/mc/DeepSeaCoralObservation.zip"

### Deep-sea Coral Habitat Suitability
deepsea_coral_suit <- "https://marinecadastre.gov/downloads/data/mc/DeepSeaCoralHabitatSuitability.zip"

# ### Deepwater Coral Habitat Area of Particular Concern
# deepwater_coral_hapc <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:deepwater_coral_hapcs"
# 
# ### Dolphin-Wahoo EFH-HAPC
# dol_wahoo_efh_hapc <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:dolphin_wahoo_efh_hapc"
# 
# ### Essential Fish Habitat Dolphin and Wahoo
# dol_wahoo_efh <- "https://data.axds.co/gs/secoora/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=secoora:dolphin_wahoo_efh"
# 
# ### Essential Fish Habitat Golden Crab
# golden_crab_efh <- "https://data.axds.co/gs/secoora/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=secoora:goldencrabefh"
# 
# ### Essential Fish Habitat Shrimp
# shrimp_efh <- "https://data.axds.co/gs/secoora/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=secoora:shrimpefh"
# 
# ### Essential Fish Habitat Snapper and Grouper
# snapper_grouper_efh <- "https://data.axds.co/gs/secoora/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=secoora:snapper_grouper_efh"
# 
# ### Essential Fish Habitat Spiny Lobster
# spiny_lob_efh <- "https://data.axds.co/gs/secoora/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=secoora:spinylobsterefh"

### Frank R. Lautenberg Deep-Sea Coral Protection Areas
flautenber_coral_pa <- "https://media.fisheries.noaa.gov/2020-04/frank_r_lautenberg_deep_sea_coral_protection_areas_20180409.zip"

### Highly Migratory Species
highly_migratory_sp <- "https://marinecadastre.gov/downloads/data/mc/EFHHighlyMigratorySpecies.zip"

# ### In-water Loggerhead Sea Turtle Trawl Survey
# in_water_loggerhead <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:seamap_turtle"
# 
# ### Kemp's Ridley Sea Turtle Trawl Survey
# in_water_kemps <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:in_water_kemps"
# 
# ### Loggerhead Sea Turtle SEAMAP Survey
# seamap_loggerhead <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:seamap_turtle"

### Mallows Bay-Potomac River National Marine Sanctuary Boundary
mbpr_boundary <- "https://sanctuaries.noaa.gov/media/gis/mbpr_py.zip"

### Mid-Atlantic Artificial Reefs
midatl_artificial_reefs <- "https://portal.midatlanticocean.org/static/data_manager/data-download/Zip_Files/Fishing/ArtificialReefs2023FebUpdate.zip"

### Mid-Atlantic Harbor Porpoise Take Reduction Plan Regulated and Exempt Waters
midatl_hptrp_trp <- "https://media.fisheries.noaa.gov/2020-04/hptrp_mid-atlantic_regulated_and_exempted_waters_20140915.zip"

### National Estuarine Research Reserve System
estuarine_reserve_sys <- "https://marinecadastre.gov/downloads/data/mc/NationalEstuarineResearchReserveSystem.zip"

### NC Biodiversity and Wildlife Habitat Assessment
ncnhde_bwha <- "https://ncnhde.natureserve.org/system/files/Biodiversity_and_Habitat_Assessment_2022-07_0.zip"

### NC Environment Sensitivity Index 2011 
#### 1.) Birds
#### 2.) ESI line
#### 3.) ESI polygon
#### 4.) Fish
#### 5.) Habitats
#### 6.) Hydro
#### 7.) Index
#### 8.) Invertebrates
#### 9.) Marine Mammals
#### 10.) Nests
#### 11.) Reptiles
#### 12.) Terrestrial Mammals
nc_esi_2011 <- "https://response.restoration.noaa.gov/sites/default/files/esimaps/gisdata/NCarolina_2011_GDB.zip"

### NC Environment Sensitivity Index 2016
#### 1.) Benthic
#### 2.) BIO INDEX
#### 3.) Birds
#### 4.) ESI -- line
#### 5.) ESI -- polygon
#### 6.) Fish -- line
#### 7.) Fish -- polygon
#### 8.) Habitats -- point
#### 9.) Habitats -- polygon
#### 10.) Herp
#### 11.) HU INDEX
#### 12.) Hydro -- line
#### 13.) Hydro -- polygon
#### 14.) INDEX
#### 15.) Invertebrate -- point
#### 16.) Invertebrate -- polygon
#### 17.) Marine Mammals
#### 18.) Resource Management Area -- point
#### 19.) Resource Management Area -- polygon
#### 20.) Terrestrial Mammals
nc_esi_2016 <- "https://response.restoration.noaa.gov/sites/default/files/esimaps/gisdata/NCarolina_2016_GDB.zip"

### NC Managed Areas (MAREA)
ncnhde_marea <- "https://ncnhde.natureserve.org/system/files/marea_ManagedArea_2024-01.zip"

### NC Natural Heritage Program Natural Areas
ncnhde_na <- "https://ncnhde.natureserve.org/system/files/nhna_NaturalArea_2024-01.zip"

### Protected Areas
protected_areas <- "https://marinecadastre.gov/downloads/data/mc/ProtectedArea.zip"

### SC Environment Sensitivity Index 1996 
#### 1.) Birds
#### 2.) ESI lines
#### 3.) ESI polygons
#### 4.) Hydro -- line
#### 5.) Hydro -- polygon
#### 6.) Index Polygon
#### 7.) Invertebrates Polygon
#### 8.) Marine Mammal
#### 9.) Nesting Sites
#### 10.) Reptiles
#### 11.) Terrestrial Mammals
sc_esi_1996 <- "https://response.restoration.noaa.gov/sites/default/files/esimaps/gisdata/SCarolina_1996_GDB.zip"

### SC Environment Sensitivity Index 2015 
#### 1.) Birds -- point
#### 2.) Birds -- polygon
#### 3.) ESI -- line
#### 4.) ESI -- polygon
#### 5.) Hydro -- polygon
#### 6.) Fish
#### 7.) Habitats
#### 8.) Hydro -- line
#### 9.) Hydro -- polygon
#### 10.) Index Bio
#### 11.) Index HU
#### 12.) Invertebrates
#### 13.) Marine Mammals
#### 14.) Reptile and Amphibian
#### 15.) Resource Management -- point
#### 16.) Resource Management -- polygon
sc_esi_2015 <- "https://response.restoration.noaa.gov/sites/default/files/esimaps/gisdata/SCarolina_2015_GDB.zip"

# ### Shorebird Nests- Georgia, South Carolina, North Carolina
# nc_sc_shorebird_nests <- "https://data.axds.co/gs/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa_shorebirds"
# 
# ### Snapper Grouper EFH-HAPC
# sg_efh_hapc <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:snapper_grouper_efh_hapc"

### Summer Flounder Sea Turtle Protection Area
sf_turtle_pa <- "https://media.fisheries.noaa.gov/2023-09/summer-flounder-fishery-sea-turtle-protection-area-20140501-1.zip"

### Tilefish EFH-HAPC
# tilefish_efh_hapc <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:tilefish_efh_hapc"

### USFWS Threatened & Endangered Species Active Critical Habitat Report
usfws_crithab <- "https://ecos.fws.gov/docs/crithab/crithab_all/crithab_all_layers.zip"

### VA DWR Wildlife Management Area Boundaries
va_wma <- "https://dwr.virginia.gov/-/gis-data/VDGIF_Wildlife_Management_Area_WMA_Boundaries.zip"

### VA ES Submerged Aquatic Vegetation Sanctuaries
### KML 
va_es_sav <- "https://webapps.mrc.virginia.gov/public/maps/kml/sav.kml"

### VA Jones Shore Special Management Area
va_jones_shore <- "https://webapps.mrc.virginia.gov/public/maps/kml/prfcWeb.kml"

### VA Priority Conservation Areas
va_pca <- "https://dwr.virginia.gov/-/gis-data/pca_shapefile.zip"

### VA State Marsh and Meadow Lands
va_marsh_meadows <- "https://webapps.mrc.virginia.gov/public/maps/kml/State.kmz"

### VA Submerged Aquatic Vegetation 2017 - 2021
va_sav_2017_2021 <- "https://webapps.mrc.virginia.gov/public/maps/kml/VIMS_SAV_2023_p1.kmz"

### VA Tier I and II Species Habitat - Wildlife Action Plan 
va_esshabtier1_2 <- "https://dwr.virginia.gov/-/gis-data/EssHabTier1_2.zip"

### VA Tier I Species Habitat - Wildlife Action Plan 
va_esshabtier1 <- "https://dwr.virginia.gov/-/gis-data/Tier1_EssHab.zip"

### Seagrasses
seagrasses <- "https://marinecadastre.gov/downloads/data/mc/Seagrass.zip"

# ### Coral Mounds
# coral_mounds <- "https://data.axds.co/gs/secoora/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=secoora:coral_mounds"
# 
# ### Southeast Atlantic Artificial Reef
# se_atl_artificial_reef <- "https://data.axds.co/gs/secoora/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=secoora:artificial_reefs"
# 
# ### North American Right Whale Sightings 
# right_whale_sightings <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:north_american_right_whale"
# 
# ### Piping Plover Critical Habitat SE
# se_pplover_crithab <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:pipingplover_se"

### Cape Lookout Lophelia Banks Deepwater Coral HAPC Fishery Management Area
#### 1.) Coral HAPC Fishery Management Area
#### 2.) Coral HAPC Extension Fishery Management Area
capeLookout_coral_hapc <- "https://media.fisheries.noaa.gov/2020-04/shapefile-cape-lookout-orig-ext.zip"

### Cape Fear Lophelia Banks Deepwater Coral HAPC Fishery Management Area
capeFear_coral_hapc <- "https://media.fisheries.noaa.gov/2020-04/capefear.zip"

### Stetson-Miami Terrace Deepwater Coral HAPC Fishery Management Area
stensonMiami_coral_hapc <- "https://media.fisheries.noaa.gov/2020-04/stetson_miami.zip"

### Blake Ridge Diapir Deepwater Coral HAPC Fishery Management Area
blakeRidge_coral_hapc <- "https://media.fisheries.noaa.gov/2020-04/blakeridge.zip"

### Southeast blueprint indicator 2023
#### 1.) Intact Habitat Cores
#### 2.) South Atlantic Amphibian & Reptile Areas
#### 3.) South Atlantic Forest Birds
#### 4.) Atlantic Migratory Fish Habitat
#### 5.) Imperiled Aquatic Species
#### 6.) Natural Landcover In Floodplains
#### 7.) Network Complexity
#### 8.) Atlantic Coral & Hardbottom
#### 9.) Atlantic Deep-Sea Coral Richness
#### 10.) Atlantic Estuarine Fish Habitat
#### 11.) Atlantic Marine Birds
#### 12.) Atlantic Marine Mammals
#### 13.) Coastal Shoreline Condition
#### 14.) Estuarine Coastal Condition
#### 15.) Island Habitat
#### 16.) Marine Highly Migratory Fish
#### 17.) Seagrass
#### 18.) South Atlantic Beach Birds 
#### 19.) South Atlantic Maritime Forest
#### 20.) Stable Coastal Wetlands
#### 21.) Marine & Estuarine Continental Corridors
southeast_blueprint <- "https://www.sciencebase.gov/catalog/file/get/64f8da38d34ed30c20546a6a?name=Southeast_Blueprint_2023_Data_Download.zip"


### North Atlantic Right Whale Seasonal Management Area
na_right_whale_sma <- "https://marinecadastre.gov/downloads/data/mc/NorthAtlanticRightWhaleSMA.zip"

### Marine Protected Areas (MPAs) Fishery Management Areas
mpa_fma <- "https://media.fisheries.noaa.gov/2020-04/mpas.zip"

### Defined Fishery Management Areas Off South Atlantic States
south_atl_fma <- "https://www.fisheries.noaa.gov/s3/2020-04/sa_eez_off_states.zip"

### Commercial Vessel Permits for South Atlantic Snapper-Grouper Fishery Management 
comm_permits_sa_sg <- "https://media.fisheries.noaa.gov/2020-04/comm_permits_sa_sg.zip"

### Sea Bass Fishery Management Area
#### 1.) special management zones fishery management areas
#### 2.) sea bass pot and associated Buoy Gear ID fishery management area
seabass_potid <- "https://media.fisheries.noaa.gov/2020-04/seabass_potid.zip"

### Longline Prohibited Areas Fishery Management Areas
ll_prohibareas_n_s <- "https://media.fisheries.noaa.gov/2020-04/ll_prohibareas_n_s.zip"

### Spawning Special Management Zones (SMZs) Fishery Management Area
spawning_smzs <- "https://media.fisheries.noaa.gov/2020-04/spawning_smzs.zip"

### Commercial Black Sea Bass Pot Closure for November & April Fishery Management Area
bsb_pot_nov_apr <- "https://media.fisheries.noaa.gov/2020-04/bsb_pot_nov_apr.zip"

### Commercial Black Sea Bass Pot Closure Dec 1 - Mar 31 Fishery Management Area
bsb_pot_dec_mar <- "https://media.fisheries.noaa.gov/2020-04/bsb_pot_dec_mar.zip"

### South Atlantic Shrimp Cold Weather Closure Fishery Management Area
sa_shrimp_cold_weather <- "https://media.fisheries.noaa.gov/2020-04/sa_shrimp_cold_weather.zip"

### Allowable Octocoral Closed Area Fishery Management Area
octocoral_fma <- "https://media.fisheries.noaa.gov/2020-04/octocoral.zip"

### Golden Crab Trap Fishing Zones and Closed Fishery Management Areas
goldencrab_fma <- "https://media.fisheries.noaa.gov/2020-04/goldencrab.zip"

### Charleston Bump Closed Area Fishery Management Area
charleston_bump_closed_fma <- "https://media.fisheries.noaa.gov/2020-04/pelagicll_charleston.zip"

### Pelagic Sargassum Habitat Area & Seasonal Restrictions Fishery Management Area
pelagic_sargassum_fma <- "https://media.fisheries.noaa.gov/2020-04/pelagic_sargassum.zip"

### King Mackerel Migratory Group Zones Fishery Management Areas
king_mackerel_migratory <- "https://media.fisheries.noaa.gov/2020-04/king_mackerel.zip"

### Spanish Mackerel Migratory Group Zones Fishery Management Areas
spanish_mackerel_migratory <- "https://media.fisheries.noaa.gov/2020-04/spanish_mackerel_.zip"

### Cobia Migratory Group Zones Fishery Management Areas
cobia_migratory <- "https://media.fisheries.noaa.gov/2020-04/cobia.zip"

### VA Blue Crab Sanctuaries 4 VAC 20-725-10
va_blue_crab_sant <- "https://webapps.mrc.virginia.gov/public/maps/kml/crabs.kml"

### VA Open Harvest Areas 4 VAC 20-720-40
va_open_harvest <- "https://webapps.mrc.virginia.gov/public/maps/kml/OpenHarvest.kmz"

### VA Oyster Gardening Permits
va_oystergarden_permits <- "https://webapps.mrc.virginia.gov/public/maps/kml/OyGarden.kmz"

### VA Oyster Ground Applications
va_oyster_leases <- "https://webapps.mrc.virginia.gov/public/maps/kml/LeaseApplications.kmz"

### VA Oyster Sanctuaries
va_oyster_sanctuaries <- "https://webapps.mrc.virginia.gov/public/maps/kml/oyster_sanctuaries.kml"

### VA Private Oyster Ground Leases
va_oyster_private_leases <- "https://webapps.mrc.virginia.gov/public/maps/kml/PrivateLeases.kmz"

### VA Shellfish Condemnation Zones by VDH
va_shellfish_condemnation <- "https://apps.vdh.virginia.gov/kml/CondemnationZones_sim.kmz"

# ### Bottom Longlines Restrictions
# bottom_ll_restrict <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:bottom_longlines_restrictions"
# 
# ### Octocoral Gear Restrictions
# octocoral_gear_restrict <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:octocoral_gear_restrictions"
# 
# ### Recreational Fishing Seasons and Closures
# recreational_fishing_close <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:recreational_fishing_seasons_and_closures"
# 
# ### Roller Rig Trawls Restrictions
# roller_rig_trawl_restrict <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:roller_rig_trawls_restrictions"
# 
# ### Sargassum Restrictions
# sargassum_restrict <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:sargassum_restrictions"

### Scup Gear Restricted Areas
scup_gear_restrict <- "https://media.fisheries.noaa.gov/2020-04/scup-gear-restricted-areas-20161114-noaa-garfo.zip"

### Monkfish Fishery Management Areas
monkfish_fma <- "https://media.fisheries.noaa.gov/2023-11/MonkfishFisheryManagementAreasShapefile.zip"

# ### SEAMAP-SA Weakfish
# seamap_weakfish <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:weakfish"
# 
# ### SEAMAP-SA Atlantic Sharpnose Shark
# seamap_atl_sharpnose <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:atlantic_sharpnose_shark"
# 
# ### SEAMAP-SA Atlantic Croaker 
# seamap_atl_croaker <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:atlantic_croaker"
# 
# ### SEAMAP-SA Spot 
# seamap_spot <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:spot"
# 
# ### SEAMAP-SA Bluefish 
# seamap_bluefish <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:bluefish"
# 
# ### SEAMAP-SA Southern Kingfish 
# seamap_southern_kingfish <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:southern_kingfish"

### Lobster Gear Areas
lobster_gear <- "https://media.fisheries.noaa.gov/2020-04/lobster_gear_areas_20160501.zip"

### Illex Fishery Mesh Exemption Area
illex_mesh_exempt <- "https://media.fisheries.noaa.gov/2020-04/illex_fishery_mesh_exemption_area_20140501.zip"

### Atlantic Red Drum Fishery Harvest or Possession Prohibition Area
atl_red_drum_prohibit <- "https://media.fisheries.noaa.gov/2020-04/atlantic-red-drum-fishery-harvest-or-possession-prohibition-area-20140915-noaa-garfo.zip"

### Southern New England Dogfish Gillnet Exemption Area
sne_dogfish_gillnet_exempt <- "https://media.fisheries.noaa.gov/2020-04/sne-dogfish-gillnet-exemption-area-20150315-noaa-garfo.zip"

### Southern New England Regulated Mesh Area
sne_regulated_mesh <- "https://media.fisheries.noaa.gov/2020-04/sne-regulated-mesh-area-20150315-noaa-garfo.zip"

### Skate Management Unit
skate_management <- "https://media.fisheries.noaa.gov/2020-04/skate-management-unit-20140501-noaa-garfo.zip"

### Southern New England Exemption Area
sne_exemption <- "https://media.fisheries.noaa.gov/2020-04/sne_exemption_area_20150315.zip"

### Management Units for Summer Flounder, Scup, and Black Sea Bass
units_sf_s_bsb <- "https://media.fisheries.noaa.gov/2020-04/management-units-sf-scup-bsb-20140501-noaa-garfo.zip"

### Scup Transfer-at-Sea Boundary
scup_transfer <- "https://media.fisheries.noaa.gov/2020-04/scup-transfer-at-sea-20140501-noaa-garfo.zip"

### Southern New England Monkfish and Skate Trawl Exemption Area
sne_monkfish_skate_trawl_exempt <- "https://media.fisheries.noaa.gov/2020-04/sne_monkfish_and_skate_trawl_exemption_area_20150315.zip"


### Southern New England Monkfish and Skate Gillnet Exemption Area
sne_monkfish_skate_gillnet_exempt <- "https://media.fisheries.noaa.gov/2020-04/sne_monkfish_and_skate_gillnet_exemption_area_20150315.zip"

### Atlantic Sea Scallop Rotational Areas
atl_scallop_rotation <- "https://media.fisheries.noaa.gov/2023-04/Scallop-Rotational-Areas-20230419.zip"

### VA Pound Net Regulated Area
va_pound_net <- "https://media.fisheries.noaa.gov/2022-05/Virginia_Pound_Net_Regulated_Areas_2022523.zip"

# ### Fish Traps Restrictions
# fish_traps_restrict <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:fish_traps_restrictions"
# 
# ### Marine Resources Monitoring, Assessment, and Prediction (MARMAP)
# marmap <- "https://data.axds.co/gs/secoora/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=secoora:marmap_biodiv_index"
# 
# ### MARMAP: Vermillion Snapper (Trap) 
# marmap_vs_trap <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:trap_vermillion_snapper"
# 
# ### MARMAP: Snowy Grouper (Short Bottom Longline)
# marmap_sngr_sbl <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:short_bottom_longline_snowy_grouper"
# 
# ### MARMAP: Scup (Trap)
# marmap_scup_trap <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:trap_scup"
# 
# ### MARMAP: Scamp Grouper (Trap)
# marmap_scgr_trap <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:trap_scamp_grouper"
# 
# ### MARMAP: Blackbelly Rosefish (Short Bottom Longline)
# marmap_blro_sbl <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:short_bottom_longline_blackbelly_rosefish"
# 
# ### MARMAP: Red Grouper (Trap)
# marmap_regr_trap <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:trap_red_grouper"
# 
# ### MARMAP: Scamp Grouper (Short Bottom Longline)
# marmap_scgr_sbl <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:short_bottom_longline_scamp_grouper"
# 
# ### MARMAP: Sand Perch (Trap)
# marmap_sape_trap <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:trap_sand_perch"
# 
# ### MARMAP: Red Porgy (Trap)
# marmap_repo_trap <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:trap_red_porgy"
# 
# ### MARMAP: Red Snapper (Trap)
# marmap_resn_trap <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:trap_red_snapper"
# 
# ### MARMAP: Red Grouper (Short Bottom Longline)
# marmap_regr_sbl <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:short_bottom_longline_red_grouper"
# 
# ### MARMAP: Knobbed Porgy (Trap)
# marmap_knpo <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:trap_knobbed_porgy"
# 
# ### MARMAP: White Grunt (Trap)
# marmap_whgr_trap <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:trap_white_grunt"
# 
# ### MARMAP: Snowy Grouper (Long Bottom Longline)
# marmap_sngr_lbl <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:long_bottom_longline_snowy_grouper"
# 
# ### MARMAP: Gag Grouper (Trap)
# marmap_gagr_trap <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:trap_gag_grouper"
# 
# ### MARMAP: Golden Tilefish (Short Bottom Longline)
# marmap_goti_sbl <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:short_bottom_longline_golden_tilefish"
# 
# ### MARMAP: Bank Sea Bass (Trap)
# marmap_basb_trap <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:trap_banksea_bass"
# 
# ### MARMAP: Black Sea Bass (Trap)
# marmap_blsb_trap <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:trap_blacksea_bass"
# 
# ### MARMAP: Grey Triggerfish (Trap)
# marmap_grtr_trap <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:trap_grey_triggerfish"
# 
# ### MARMAP: Tomtate (Trap)
# marmap_tomtate_trap <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:trap_tomtate"
# 
# ### MARMAP: Spotted Moray Eel (Trap)
# marmap_sme_trap <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:trap_spotted_moray_eel"
# 
# ### MARMAP: Spottail Pinfish (Trap)
# marmap_sppi_trap <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:trap_spottail_pinfish"
# 
# ### MARMAP: Golden Tilefish (Long Bottom Longline)
# marmap_goti_lbl <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:long_bottom_longline_golden_tilefish"
# 
# ### MARMAP: White Shrimp 
# marmap_white_shrimp <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:white_shrimp"
# 
# ### MARMAP: Brown Shrimp
# marmap_brown_shrimp <- "https://data.axds.co/gs/gsaa/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=gsaa:brown_shrimp"
# 
# ### MARMAP: Blackfish Trap Survey 1990-2009
# marmap_bf_trap_1990_2009 <- "https://data.axds.co/gs/secoora/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=secoora:marmap_blackfish_trap_survey_1990_2009"
# 
# ### MARMAP: Bottom Longline 1990-2009
# marmap_bll_1990_2009 <- "https://data.axds.co/gs/secoora/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=secoora:marmap_bottom_longline_1990_2009_"
# 
# ### MARMAP: Isaacs-Kidd Midwater Trawl 1990-2009
# marmap_ikmt_1990_2009 <- "_https://data.axds.co/gs/secoora/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=secoora:marmap_isaacs_kidd_midwater_trawl_1990_2009"
# 
# ### MARMAP: Kali Pole 1990-2009 
# marmap_kp_1990_2009 <- "https://data.axds.co/gs/secoora/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=secoora:marmap_kali_pole_1990_2009"
# 
# ### MARMAP: Short Bottom Longline 1990-2009
# marmap_sbll_1990_2009 <- "https://data.axds.co/gs/secoora/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=secoora:marmap_short_bottom_longline_1990_2009"
# 
# ### MARMAP: Yankee Trawl 1990-2009
# marmap_yt_1990_2009 <- "https://data.axds.co/gs/secoora/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=secoora:marmap_yankee_trawl_1990_2009"

#####################################
#####################################
# Check the number of variables you have 
str(as.list(.GlobalEnv))


#####################################
#####################################

# Download list (non KML/KMZ)
download_list <- c(
  # audobon,
  # n_nc_bdtrp,
  # sc_bdtrp,
  # s_nc_bdtrp,
  # cetacean_bia,
  # cb_esi_2016,
  # cbra,
  # coastal_crtihab,
  # coastal_veva,
  # coastal_wetlands,
  # deepsea_coral_obs,
  # deepsea_coral_suit,
  # flautenber_coral_pa, # name is too long, manual extraction needed (ok on macOS, not on Windows)
  # highly_migratory_sp,
  # mbpr_boundary,
  # midatl_artificial_reefs,
  # midatl_hptrp_trp, # name is too long, manual extraction needed (ok on macOS, not on Windows)
  # estuarine_reserve_sys,
  # ncnhde_bwha,
  # nc_esi_2011,
  # nc_esi_2016,
  # ncnhde_marea ,
  # ncnhde_na,
  # protected_areas,
  # sc_esi_1996,
  # sc_esi_2015,
  # sf_turtle_pa,# name is too long, manual extraction needed (ok on macOS, not on Windows)
  # usfws_crithab,
  # va_wma,
  # va_es_sav,
  # va_jones_shore,
  # va_pca,
  # va_marsh_meadows,
  # va_sav_2017_2021,
  # va_esshabtier1_2,
  # va_esshabtier1,
  # seagrasses,
  # capeLookout_coral_hapc,
  # capeFear_coral_hapc,
  # stensonMiami_coral_hapc,
  # blakeRidge_coral_hapc,
  # southeast_blueprint,# Windows does not like the special characters in the file name, manual extraction needed (ok on macOS)
  # na_right_whale_sma,
  # mpa_fma,
  # south_atl_fma,
  # comm_permits_sa_sg,
  # seabass_potid,
  # ll_prohibareas_n_s,
  # spawning_smzs,
  # bsb_pot_nov_apr,
  # bsb_pot_dec_mar,
  # sa_shrimp_cold_weather,
  # octocoral_fma,
  # goldencrab_fma,
  # charleston_bump_closed_fma,
  # pelagic_sargassum_fma,
  # king_mackerel_migratory,
  # spanish_mackerel_migratory,
  # cobia_migratory,
  # va_blue_crab_sant,
  # va_open_harvest,
  # va_oystergarden_permits,
  # va_oyster_leases,
  # va_oyster_sanctuaries,
  # va_oyster_private_leases,
  # va_shellfish_condemnation,
  # scup_gear_restrict,
  # monkfish_fma,
  # lobster_gear,
  # illex_mesh_exempt,
  # atl_red_drum_prohibit,# name is too long, manual extraction needed (ok on macOS, not on Windows)
  # sne_dogfish_gillnet_exempt,
  # sne_regulated_mesh,
  # skate_management,
  # sne_exemption,
  # units_sf_s_bsb,
  # scup_transfer,
  # sne_monkfish_skate_trawl_exempt,
  # sne_monkfish_skate_gillnet_exempt,# name is too long, manual extraction needed (ok on macOS, not on Windows)
  # atl_scallop_rotation,
  # va_pound_net
)

length(download_list)

#####################################
#####################################
# Create function that will pull data from publicly available websites
## This allows for the analyis to have the most current data; for some
## of the datasets are updated with periodical frequency (e.g., every 
## month) or when needed. Additionally, this keeps consistency with
## naming of files and datasets.
### The function downloads the desired data from the URL provided and
### then unzips the data for use

data_download_function <- function(download_list, data_dir){
  
  # loop function across all datasets
  for(i in 1:length(download_list)){
    
    # designate the URL that the data are hosted on
    url <- download_list[i]
    
    # file will become last part of the URL, so will be the data for download
    file <- basename(url)
    
    # Download the data
    if (!file.exists(file)) {
      options(timeout=100000)
      # download the file from the URL
      download.file(url = url,
                    # place the downloaded file in the data directory
                    destfile = file.path(data_dir, file),
                    mode="wb")
    }
    
    # Unzip the file if the data are compressed as .zip
    ## Examine if the filename contains the pattern ".zip"
    ### grepl returns a logic statement when pattern ".zip" is met in the file
    if (grepl(".zip", file)){
      
      # grab text before ".zip" and keep only text before that
      new_dir_name <- sub(".zip", "", file)
      
      # create new directory for data
      new_dir <- file.path(data_dir, new_dir_name)
      
      # unzip the file
      unzip(zipfile = file.path(data_dir, file),
            # export file to the new data directory
            exdir = new_dir)
      # remove original zipped file
      file.remove(file.path(data_dir, file))
      
    }
    
    # if (grepl(".kmz", file)){
    #   
    #   ## rename 
    #   file.rename(from=file.path(data_dir, file),  # Make default download directory flexible
    #               # send to the raw data directory
    #               to=file.path(data_dir, paste0(sub(".kmz", "", file), ".zip")))
    #   
    #   unzip(zipfile = file.path(data_dir, paste0(sub(".kmz", "", file, ".zip"))),
    #         # export file to the new data directory 
    #         exdir = file.path(data_dir, paste0(sub(".kmz", "", file, ".kml"))))
    #         
    #   file.rename(from=file.path(data_dir, "doc.kml"),  # Make default download directory flexible
    #               # send to the raw data directory
    #               to=file.path(data_dir, paste0(sub(".kmz", "", file), ".kml")))
    #   
    #   ## remove original zipped file
    #   file.remove(file.path(data_dir, paste0(sub(".kmz", "", file), ".zip")))
    # }
  }
}

#####################################
#####################################
# Run the download
data_download_function(download_list, data_dir)

#####################################
#####################################

# list all files in data directory
list.files(data_dir)

#####################################
#####################################

file.rename(from = file.path(data_dir, list.files(data_dir,
                                                  # get the Southeast_Blueprint directory
                                                  pattern = "Southeast_Blueprint")),
            to = file.path(data_dir, "Southeast_Blueprint"))

list.files(data_dir)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate

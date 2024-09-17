######################################### 
### 0. Data Set up: Study Area        ###
######################################### 

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
# Input directories
## data directory for hex grids 
data_dir <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/aa_exploration_data/aoa_study_area"

list.files(data_dir)
list.dirs(data_dir, recursive = TRUE)

# Output directories
## study areas geopackage (to raw_data)
study_areas_gpkg <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data/ak_study_areas.gpkg"

#####################################
#####################################
# Load Data 

# Hex Grids (source: Google Drive - Aquaculture AOA)
ketchikan <- sf::st_read(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"),
                          layer = sf::st_layers(file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]][grep(pattern = "fiveacre_Ketchikan_Tess_Final",
                                                                                    sf::st_layers(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]])])


cordova <- sf::st_read(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"),
                          layer = sf::st_layers(file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]][grep(pattern = "fiveacreCordova_Tess_Final",
                                                                                                       sf::st_layers(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]])])

craig <- sf::st_read(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"),
                          layer = sf::st_layers(file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]][grep(pattern = "fiveacreCraig_Tess_Final",
                                                                                                       sf::st_layers(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]])])


juneau <- sf::st_read(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"),
                          layer = sf::st_layers(file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]][grep(pattern = "fiveacreJuneau_Tess_Final",
                                                                                                       sf::st_layers(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]])])


kodiak <- sf::st_read(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"),
                          layer = sf::st_layers(file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]][grep(pattern = "fiveacreKodiak_Tess_Final",
                                                                                                       sf::st_layers(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]])])


metlakatla <- sf::st_read(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"),
                          layer = sf::st_layers(file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]][grep(pattern = "fiveacreMetlakatla_Tess_Final",
                                                                                                       sf::st_layers(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]])])


petersburg <- sf::st_read(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"),
                          layer = sf::st_layers(file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]][grep(pattern = "fiveacrePetersburg_Tess_Final",
                                                                                                       sf::st_layers(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]])])


seward <- sf::st_read(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"),
                          layer = sf::st_layers(file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]][grep(pattern = "fiveacreSeward_Tess_Final",
                                                                                                       sf::st_layers(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]])])


sitka <- sf::st_read(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"),
                          layer = sf::st_layers(file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]][grep(pattern = "fiveacreSitka_Tess_Final",
                                                                                                       sf::st_layers(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]])])


valdez <- sf::st_read(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"),
                          layer = sf::st_layers(file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]][grep(pattern = "fiveacreValdez_Tess_Final",
                                                                                                       sf::st_layers(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]])])


wrangell <- sf::st_read(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"),
                      layer = sf::st_layers(file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]][grep(pattern = "fiveacreWrangell_Tess_Final",
                                                                                                   sf::st_layers(dsn = file.path(data_dir, "Alaska_AOA_Grids.gdb"))[[1]])])



#####################################
#####################################

# create list of the datasets
data <- list(ketchikan,
             cordova,
             craig,
             juneau,
             kodiak,
             metlakatla,
             petersburg,
             seward,
             sitka,
             valdez,
             wrangell)

#####################################
# Sanity check, you above list should have 11 variables
length(data)

#####################################
#####################################

# create list of the datasets
data_codes <- c("ketchikan_fiveacre",
             "cordova_fiveacre",
             "craig_fiveacre",
             "juneau_fiveacre",
             "kodiak_fiveacre",
             "metlakatla_fiveacre",
             "petersburg_fiveacre",
             "seward_fiveacre",
             "sitka_fiveacre",
             "valdez_fiveacre",
             "wrangell_fiveacre")

#####################################
#####################################

# export all datasets with the data names as the geopackage layer name
for(i in seq_along(data)){
  # grab the dataset
  dataset <- data[[i]]
  
  # export the dataset
  sf::st_write(obj = dataset, dsn = study_areas_gpkg, layer = data_codes[i], append = F)
}

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate

#######################################
### 0. Download Data -- constraints ###
#######################################

# clear environment
rm(list = ls())

# calculate start time of code (determine how long it takes to complete all code)
start <- Sys.time()

#####################################
#####################################

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr,
               plyr,
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
      
      # unzip and prepare data hosted on AXDS's servers
      ## take the parts with "typeName" in the file and then get unique data name 
      if (grepl("typeName", file)){
        
        # grab unique file name portion
        new_dir_name <- unlist(strsplit(file, split=':', fixed=TRUE))[2]
        
        # create new directory for data
        new_dir <- file.path(data_dir, new_dir_name)
        
        # unzip the file
        unzip(zipfile = file.path(data_dir, file),
              # export file to the new data directory
              exdir = new_dir)
        # remove original zipped file
        file.remove(file.path(data_dir, file))
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
    }
  }

#####################################
#####################################
    
# set directories
## define data directory (as this is an R Project, pathnames are simplified)
data_dir <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/aa_exploration_data/constraints"

#####################################
#####################################

# Download list
download_list <- c(
  # danger zones and restricted areas (source: https://marinecadastre.gov/downloads/data/mc/DangerZoneRestrictedArea.zip)
  ## MarineCadastre: 
  ## metadata:
  "https://marinecadastre.gov/downloads/data/mc/DangerZoneRestrictedArea.zip",
  "https://marinecadastre.gov/downloads/data/mc/AtoN.zip",
  "https://marinecadastre.gov/downloads/data/mc/WreckObstruction.zip",
  "https://marinecadastre.gov/downloads/data/mc/CoastalPopulatedPlace.zip",
  "https://marinecadastre.gov/downloads/data/mc/FederalStateWaters.zip",

  "https://marinecadastre.gov/downloads/data/mc/SubmarineCable.zip",
  "https://marinecadastre.gov/downloads/data/mc/SubmarineCableArea.zip",
  
  # needs to be further processed in arcgis pro (kml -> Layer, then export features)
  "https://www.ndbc.noaa.gov/kml/marineobs_by_pgm.kml",
  
  "https://encdirect.noaa.gov/theme_layers/data/shipping_lanes/shippinglanes.zip",
  "https://gs.audubon.axds.co/audubon_2019/wms?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=audubon_2019:alaska_marine_highway",
  "https://encdirect.noaa.gov/theme_layers/data/coastal_maintained_channels/maintainedchannels.zip",
  "https://marinecadastre.gov/downloads/data/mc/FormerlyUsedDefenseSite.zip",
  "https://marinecadastre.gov/downloads/data/mc/MunitionsExplosivesConcern.zip",
  "https://marinecadastre.gov/downloads/data/mc/UnexplodedOrdnanceArea.zip",
  "https://marinecadastre.gov/downloads/data/mc/UnexplodedOrdnance.zip",
  "https://marinecadastre.gov/downloads/data/mc/WastewaterOutfall.zip",

  "https://data.axds.co/gs/mariculture/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=mariculture:active_aquatic_farming_operation_areas",
  "https://www.adfg.alaska.gov/static-sf/AWC/GDB/2023GDB_statewide.zip",

  "https://data.axds.co/gs/nfwf/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=nfwf:ci_fiberoptic",
  "https://data.axds.co/gs/nfwf/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=nfwf:ci_pipes",

  "https://data.axds.co/gs/walrus/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=walrus:hauloutsdb_buffer_3338_4326",

  "https://data.axds.co/gs/mariculture/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=mariculture:harbor_seal_haulouts_500m_buffer",
  "https://data.axds.co/gs/mariculture/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=mariculture:harbor_seal_haulouts",
  "https://data.axds.co/gs/mariculture/wfs?service=WFS&version=1.0.0&request=GetFeature&outputFormat=SHAPE-ZIP&typeName=mariculture:steller_sea_lion_haulout_buffers",

  "https://www.fws.gov/r7/nwr/Realty/data/GIS/Land-Status/USFWS-Region-7-Land-Status.gdb.zip",
  
  "https://marinecadastre.gov/downloads/data/mc/OceanDisposalSite.zip",
  "https://marinecadastre.gov/downloads/data/mc/Pipeline.zip",
  "https://marinecadastre.gov/downloads/data/mc/OffshoreOilGasPlatform.zip"
)

#####################################
#####################################

parallel::detectCores()

cl <- parallel::makeCluster(spec = parallel::detectCores(), # number of clusters wanting to create
                            type = 'PSOCK')

work <- parallel::parLapply(cl = cl, X = download_list, fun = data_download_function, data_dir = data_dir)

parallel::stopCluster(cl = cl)

#####################################
#####################################

# list all files in data directory
list.files(data_dir)

#####################################
#####################################
# Rename the 2023GDB_statewide to anadromous water catalog for a more descriptive title
file.rename(from = file.path(data_dir, list.files(data_dir,
                                                  # get the Anadromous streams directory
                                                  pattern = "2023GDB_statewide")),
            to = file.path(data_dir, "anadromous_water_catalog"))

list.files(data_dir)

#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate

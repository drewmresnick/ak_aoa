#########################################################################################################
### 0. Webscrape Data -- Alaska State Game Refuges, Critical Habitat, Sanctuaries shadow                                           ###
#########################################################################################################

# Clear environment
rm(list = ls())

# Calculate start time of code (determine how long it takes to complete all code)
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
               rgdal,
               rgeoda,
               rgeos,
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
## download directory
download_dir <- "C:/Users/Breanna.Xiong/Downloads"

## output directory
data_dir <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/aa_exploration_data/constraints"

#####################################
#####################################

# Webscrape set-up
## Process uses RSelenium package (learn more about basics here: https://cran.r-project.org/web/packages/RSelenium/vignettes/basics.html)
### Another helpful tutorial: https://joshuamccrain.com/tutorials/web_scraping_R_selenium.html
### Firefox profile (based on this link: https://yizeng.me/2014/05/23/download-pdf-files-automatically-in-firefox-using-selenium-webdriver/)
fprof <- RSelenium::makeFirefoxProfile(list(
  # detail level for download (0 = Desktop, 1 = systems default downloads location, 2 = custom folder.)
  browser.download.folderList = 2,
  # location for data download
  browser.download.dir = data_dir,
  # stores a comma-separated list of MIME types to save to disk without asking what to use to open the file
  browser.helperApps.neverAsk.saveToDisk = "application/pdf",
  # disable PDF javascript so that PDFs are not displayed
  pdfjs.disabled = TRUE,
  # turn off scan and loading of any additionally added plug-ins
  plugin.scan.plid.all = FALSE,
  # high number defined for version of Adobe Acrobat
  plugin.scan.Acrobat = "99.0"))

#####################################

# Launch RSelenium server and driver
rD <- RSelenium::rsDriver(browser="firefox",
                          # set which version of browser
                          version = "latest",
                          # Chrome version (turn off as Firefox will be used)
                          chromever = NULL,
                          # set which version of Gecko to use
                          geckover = "latest",
                          # status messages
                          verbose = TRUE,
                          # populate with the Firefox profile
                          extraCapabilities = fprof)

## Remote driver
remDr <- rD[["client"]]
remDr$open(silent = TRUE)

#####################################
#####################################

# Navigates to Alaska State Game Refuges, Critical Habitat, Sanctuaries (source: https://data-soa-adec.opendata.arcgis.com/datasets/ADEC::alaska-dec-sensitive-areas/explore?layer=16&location=50.000528%2C-154.002228%2C20.60)
# and scrapes the site data for the states and regions of interest

# Base URL
base_url <- "https://data-soa-adec.opendata.arcgis.com/datasets/ADEC::alaska-dec-sensitive-areas/explore?layer=16&location=50.000528%2C-154.002228%2C20.60"

# Navigate to page
remDr$navigate(base_url)
Sys.sleep(3)

#####################################

# Prepare window
remDr$maxWindowSize()
Sys.sleep(2)

#####################################

# Click "Download" toggle on side panel
download_toggle <-remDr$findElement(using = "css selector",
                                    value = "button.btn-default:nth-child(2)")
download_toggle$clickElement()
Sys.sleep(3)

#####################################

# Click "Download" for the shapefile to get those data
## data are in a shadow form, so need to use shadowr package
shadow_rd <- shadowr::shadow(remDr)
Sys.sleep(3)

# find the calcite (shadow) buttons
shapefile_panel_button <- shadowr::find_elements(shadow_rd, 'calcite-button')

### shapefile are the third dataset (after CSV, KML, -- and before geojson)
#### ***note: for some reason the first element is nothing, the second element
####          is for the CSV, hence the 4th element is for the shapefile
shapefile_panel_button[[4]]$clickElement()
Sys.sleep(5)

### generate latest data
shapefile_latest_data <- shadowr::find_elements(shadow_rd, 'calcite-dropdown-item')
### click the option for the latest data for the shapefile
shapefile_latest_data[[5]]$clickElement()
#### data take time to generate so need to have system have the the time to download before closing
Sys.sleep(120)

#####################################

# Close RSelenium servers
remDr$close()
rD$server$stop()

#####################################
#####################################

# Move data to correct directory
file.rename(from=file.path(download_dir, "Alaska_DEC_Sensitive_Areas.zip"),  # Make default download directory flexible
            # send to the raw data directory
            to=file.path(data_dir, "ak_gamerefuges_crtihab_sanct.zip"))

#####################################

# Unzip the data
## grab text before ".zip" and keep only text before that
new_dir_name <- sub(".zip", "", "ak_gamerefuges_crtihab_sanct.zip")

## create new directory for data
new_dir <- file.path(data_dir, new_dir_name)

## unzip the file
unzip(zipfile = file.path(data_dir, "ak_gamerefuges_crtihab_sanct.zip"),
      # export file to the new data directory
      exdir = new_dir)

## remove original zipped file
file.remove(file.path(data_dir, "ak_gamerefuges_crtihab_sanct.zip"))

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate

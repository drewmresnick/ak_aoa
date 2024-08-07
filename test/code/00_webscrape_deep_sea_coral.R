######################################################
### 0. Webscrape Data -- deep-sea coral and sponge ###
######################################################

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

# Navigates to  (source: https://www.ncei.noaa.gov/maps/deep-sea-corals/mapSites.htm)
# and scrapes the site data for the states and regions of interest

# Base URL
base_url <- "https://www.ncei.noaa.gov/maps/deep-sea-corals/mapSites.htm"

# Navigate to page
remDr$navigate(base_url)
Sys.sleep(3)

#####################################

# Prepare window
remDr$maxWindowSize()
Sys.sleep(2)

#####################################

# Click "Download" toggle on side panel
data_button <-remDr$findElement(using = "css selector",
                                value = "#downloadMenu_label")
data_button$clickElement()

download_toggle <-remDr$findElement(using = "css selector",
                                    value = "#dijit_form_Button_2_label > b:nth-child(1) > span:nth-child(1)")
download_toggle$clickElement()

Sys.sleep(100)

#####################################

# Close RSelenium servers
remDr$close()
rD$server$stop()

#####################################
#####################################

# Move data to correct directory
file.rename(from=file.path(download_dir, list.files(download_dir, pattern = ".csv")),  # Make default download directory flexible
            # send to the raw data directory
            to=file.path(data_dir, "deep_sea_coral_sponge.csv"))

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate



####################################
# Manual processing steps:
## Downloaded CSV field types are texts, ArcGIS Pro cannot read it to convert. 
## CSV to Point in ArcGIS Pro
### 1.) Create a geodatabase copy of the table (Export Table)
### 2.) Delete the first row of the table, it's all NULL
### 3.) Create longitude and latitude fields with data type as numeric floats with 6-significant figures 
### 4.) Copy the longitude text to the longitude float field, latitude text to latitude float field
### 5.) Right click the CSV to Create Points from Table
### 6.) Pull in the data from the geodatabase or chose Export Features for a shapefile



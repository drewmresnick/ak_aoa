#################################################################
### 0. Download Data -- industry, navigation, transportation  ###
#################################################################

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
    }
    
    # unzip and prepare data hosted on AXDS's servers
    ## take the parts with "typeName" in the file and then get unique data name 
    if (grepl("typeName", file)){
      
      
      # grab unique file name portion
      new_dir_name <- unlist(strsplit(file, split=':', fixed=TRUE))[2]
      
      
      # create new directory for data
      new_dir_base <- file.path(data_dir, new_dir_name)
      
      
      
      # WINDOWS: add a .zip extension at the end of the basename 
      extension <- ".zip"
      
      
      # concatenate the .zip on the basename
      new_dir <- paste(new_dir_base, extension, sep = "")
      
      
      # download the file from the URL
      download.file(url = url,
                    # place the downloaded file in the data directory
                    destfile = file.path(new_dir),
                    mode="wb")
      
      # unzip the file
      unzip(zipfile = file.path(new_dir),
            # export file to the new data directory
            exdir = file.path(data_dir, new_dir_name))
      
      # remove original zipped file
      file.remove(file.path(new_dir))
    }
    
    # unzip and prepare data hosted on AXDS's servers
    ## take the parts with "typeName" in the file and then get unique data name 
    if (grepl("boem.gov", file)){
      
      
      # WINDOWS: add a .zip extension at the end of the basename 
      extension <- ".zip"
      
      
      # concatenate the .zip on the basename
      new_dir_base <- paste(file, extension, sep = "")
      
      
      # download the file from the URL
      download.file(url = url,
                    # place the downloaded file in the data directory
                    destfile = file.path(data_dir, new_dir_base),
                    mode="wb")
      
      
      # unzip the file
      unzip(zipfile = file.path(data_dir, new_dir_base),
            # export file to the new data directory
            exdir = file.path(data_dir, file))
      
      # remove original zipped file
      file.remove(file.path(data_dir, new_dir_base))
    }
    
    # unzip and prepare data hosted on AXDS's servers
    ## take the parts with "typeName" in the file and then get unique data name
    if (grepl("planarea", file)){


      # WINDOWS: add a .zip extension at the end of the basename
      extension <- ".zip"


      # concatenate the .zip on the basename
      new_dir_base <- paste(file, extension, sep = "")


      # download the file from the URL
      download.file(url = url,
                    # place the downloaded file in the data directory
                    destfile = file.path(data_dir, new_dir_base),
                    mode="wb")


      # unzip the file
      unzip(zipfile = file.path(data_dir, new_dir_base),
            # export file to the new data directory
            exdir = file.path(data_dir, file))

      # remove original zipped file
      file.remove(file.path(data_dir, new_dir_base))
    }

    # Unzip the file if the data are compressed as .zip
    ## Examine if the filename contains the pattern ".zip"
    ### grepl returns a logic statement when pattern ".zip" is met in the file
    if (grepl(".zip", file)){
      
      # download the file from the URL
      download.file(url = url,
                    # place the downloaded file in the data directory
                    destfile = file.path(data_dir, file),
                    mode="wb")
      
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
data_dir <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/aa_exploration_data/industry_navigation"

#####################################
#####################################

# Download list
download_list <- c(
                   "https://www.boem.gov/regions/alaska-ocs-region/leasing-and-plans/akhistoricalleaseszip"
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
# Uncomment if you need to rename a file

# Rename the akhistoricallease to boem_oil_gas_lease for a more descriptive title
file.rename(from = file.path(data_dir, list.files(data_dir, pattern = "akhistoricallease")),
                                                  to = file.path(data_dir, "boem_oil_gas_lease"))


list.files(data_dir)

#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
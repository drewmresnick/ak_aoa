#############################
### 0. Create Directories ###
#############################

# create project folder if not already created
project <- "C:/Users/Breanna.Xiong/Documents/R Scripts/test"
project_folder <- dir.create(project)

# create data directory
data <- "C:/Users/Breanna.Xiong/Documents/R Scripts/test/data"
data_dir <- dir.create(data)

# create the study area data directory
study_area <- "C:/Users/Breanna.Xiong/Documents/R Scripts/test/study_area"
study_area_dir <- dir.create(study_area)

###############################################

# designate regional data subdirectories 
data_subdirectories <- c("aa_exploration_data",
                         "a_raw_data")

# designate study area subdirectories 
study_area_subdirectories <- c("b_intermediate_data",
                               "c_submodel_data",
                               "d_suitability_data",
                               "e_rank_data",
                               "f_sensitivity_data",
                               "g_uncertainty_data",
                               "zz_miscellaneous")


# study area names
study_area_names <- c("ketchikan",
                   "cordova",
                   "craig",
                   "juneau",
                   "kodiak",
                   "metlakatla",
                   "petersburg",
                   "seward",
                   "sitka",
                   "valdez",
                   "wrangell")


# designate submodel directories
data_submodels <- c("boundaries",
                    "constraints",
                    "geology",
                    "fisheries",
                    "industry_navigation",
                    "logistics",
                    "natural_cultural_resources",
                    "national_security")


#####################################
# Data folder
# create sub-directories within data directory (aa-a)
for (i in 1:length(data_subdirectories)){
  subdirectories <- dir.create(file.path(data, data_subdirectories[i]))
}

# create submodel sub-directories within data directory for the exploration data
for (i in 1:length(data_submodels)){
  subdirectories <- dir.create(file.path(data, "aa_exploration_data", data_submodels[i]))
}

# create submodel sub-directories within data directory for the raw data 
for (i in 1:length(data_submodels)){
  subdirectories <- dir.create(file.path(data, "a_raw_data", data_submodels[i]))
}

######################################
# Study Area Data folder

# create study area sub-directories within the study area folder (cordova - wrangell)
for(i in study_area_names){
  # loop through the data_codes list
  dataset <- i
  # create sub-directories based on the study_area list 
  subdirectories <- dir.create(file.path(study_area, dataset))
}


# create submodel sub-directories within study area directory for b_intermediate - zz_miscellaneous 
for(i in (study_area_names)){
  dataset <- i
  
  # create sub-directories based on the study_area list 
  filepath <- paste(study_area, dataset, sep = "/")
  
  # create a new folder within each study area
  for (k in (study_area_subdirectories)){
    subdirectories <- dir.create(file.path(filepath, k))
  }
}
  

# create sub-directories within study area subdirectories for the different submodels (boundaries - natural cultural resources)
for(i in (study_area_names)){
  dataset <- i
  
  # create sub-directories based on the study_area list 
  filepath <- paste(study_area, dataset, sep = "/")
  
  # create a new folder within each study area
  for (k in (study_area_subdirectories)){
    subdirectories <- (file.path(filepath, k))
    
    # within each of the new folders, create a folder for each submodel
    for (i in 1:length(data_submodels)){
      submodels <- dir.create(file.path(subdirectories, data_submodels[i]))
    }
  }
}

  
#####################################

# create code directory
code_dir <- dir.create("C:/Users/Breanna.Xiong/Documents/R Scripts/test/code")

#####################################

# create figure directory
figure_dir <- dir.create("C:/Users/Breanna.Xiong/Documents/R Scripts/test/figure")

#####################################
#####################################

# delete directory (if necessary)
### ***Note: change directory path for desired directory
#unlink("data/a_raw_data", recursive = T)
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
                               "c_submodel_data")



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




# designate scenario subdirectories
scenario_subdirectories <- c("d_suitability_data",
                             "e_rank_data",
                             "f_sensitivity_data",
                             "g_uncertainty_data",
                             "zz_miscellaneous")


# designate submodel directories
data_submodels <- c("constraints",
                    "geophysical",
                    "fisheries",
                    "natural_resources",
                    "cultural_resources",
                    "national_security",
                    "industry_navigation")


# designate scenario directories
scenarios <- c(
  "1_intertidal",
  "2_floating_bag",
  "3_suspended",
  "4_baseline",
  "5_intertidal_wetlands"
)



#####################################
# Data folder
# create sub-directories within data directory (aa-a)
for (i in 1:length(data_subdirectories)){
  subdirectories <- dir.create(file.path(data, data_subdirectories[i]))
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


# create study area sub-directories within study area directory for b_intermediate - c_submodel_data
for(i in (study_area_names)){
  dataset <- i
  
  # create sub-directories based on the study_area list 
  filepath <- paste(study_area, dataset, sep = "/")
  
  # create a new folder within each study area
  for (k in (study_area_subdirectories)){
    subdirectories <- dir.create(file.path(filepath, k))
  }
}


# create submodel directories within study area subdirectories (boundaries - natural cultural resources)
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
# Scenarios 
# create scenario directories within study area folders (intertidal - baseline)
for(i in (study_area_names)){
  dataset <- i
  
  # create sub-directories based on the study_area list 
  filepath <- paste(study_area, dataset, sep = "/")
  
  # create a new folder within each study area
  for (k in (scenarios)){
    subdirectories <- dir.create(file.path(filepath, k))
  }
}


## create submodel directories within study area subdirectories (boundaries - natural cultural resources)
for(i in (study_area_names)){
  dataset <- i
  
  # create sub-directories based on the study_area list 
  filepath <- paste(study_area, dataset, sep = "/")
  
  # create a new folder within each study area
  for (k in scenarios){
    
    for (j in 1:length(scenario_subdirectories)){
      folder <- (file.path(k, scenario_subdirectories[j]))
    
    # create sub-directories based on the study_area list
    filepath <- paste(study_area, dataset, folder, sep = "/")
    
    # create the new folders
    subdirectories <- dir.create(file.path(filepath))

    }
  }
}


# create submodel directories within study area subdirectories (boundaries - natural cultural resources)
for(i in (study_area_names)){
  dataset <- i
  
  # create sub-directories based on the study_area list
  filepath <- paste(study_area, dataset, sep = "/")
  
  # create a new folder within each study area
  for (k in (scenarios)){
    subdirectories <- (file.path(filepath, k))
    
    # within each of the new folders, create a folder for each submodel
    for (l in 1:length(scenario_subdirectories)){
      submodels <- (file.path(subdirectories, scenario_subdirectories[l]))
      
      for (j in 1:length(data_submodels)){
        folder <- (file.path(submodels, data_submodels[j]))
        print(folder)

        last_sub <- dir.create(file.path(folder))
      }
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
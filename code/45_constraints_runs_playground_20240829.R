
library(dplyr)
library(sf)
library(matrixStats)
library(tidyr)

##################
universal_colnames = c("nwi_sys_PRL", "aton", "wrecksobs", "deepseacoral", "submarine",
                       "submarineareas", "marine_highway", "ferry_routes", "aquatic_farm_permit",
                       "active_aquatic_op", "awc_stream", "state_park", "offshore_seafood_processors",
                       "Alaska_DEC_WQ_Monitoring_Locations", "harbor_seal_haul_buff", "sensors",
                       "maintainedchannels", "wastewater_pipe", "ferry_terminals",
                       "seafood_processing_discharge_loc", "seafood_processing_permitted_outfall",
                       "seafood_processing_permitted_net_pens", "seafood_processing_permitted_carcass_disposal",
                       "seafood_processing_facility_locations", "poa_navigation_projects", "ocean_disposal",
                       "refuge_crithab_sanct", "poa_erosion_protection", "dangerzones", "ci_fiberoptic",
                       "landstatus_boundaries_refuge", "steller_sea_lion_haulout_buffers", "pipelines",
                       "shippinglane", "taku_glacier", "area_plan_AQ", "island_80")

unique_colnames = c("depth_range_suspended", "depth_range_floating","SYSTEM_Marine",
                    "SYSTEM_Estuarine", "SUBSYSTEM_Intertidal","nwi_sys_EorM")

id_colnames = c("GRID_ID", "study_area")

####################

constr_dsn = "./regional/b_intermediate_data/combined_gpkgs/ak_aoa_hexGrid_constraintsDataCombined.gpkg"
my_sf = st_read(dsn=constr_dsn, "ak_aoa_hexGrid_constraintsDataCombined")

my_sf = my_sf %>% 
  select(all_of(c(id_colnames, unique_colnames, universal_colnames)))


# st_write(my_sf,
#          dsn = "./regional/b_intermediate_data/combined_gpkgs/ak_aoa_hexGrid_constraintsDataCombined.gpkg",
#          layer = "ak_aoa_hexGrid_constraintsDataCombined",
#          delete_layer = TRUE)

####################################
# function to calculate geometric mean
geom_mean_columns <- function(my_df, cols, id_cols=c(), weights=NULL){
  
  # subset the data into only what's needed and make a matrix
  my_df <- my_df %>% select(all_of(c(id_cols, cols))) 
  
  if(ncol(my_df) == length(c(id_cols, cols))+1){
    my_df = st_drop_geometry(my_df)
  }
  
  my_mtrx = as.matrix(my_df %>% select(all_of(cols)))
  if(is.null(weights)){ weights = rep(1/ncol(my_mtrx), ncol(my_mtrx)) }
  ### run rowwise weighted mean calculation by using matrix math
  # transpose the matrix and take the columwise exponent based on the weights
  # then transpose back to the original format
  my_mtrx = t(t(my_mtrx)^weights)
  # get product of row values and raise to the power of 1/ the sum of the weights
  vals = matrixStats::rowProds(my_mtrx)^(1/sum(weights)) 
  
  if(length(id_cols)==0){return(vals)
  }else{
    my_df = my_df %>% select(all_of(id_cols))
    my_df$vals = vals
    return(my_df)
  }
}
#####
#######################
# replace any NA in the data colums with a 1
my_sf = my_sf %>%
  mutate_at(c(unique_colnames, universal_colnames), ~replace_na(.x, 1))


scenario_1 = geom_mean_columns(
  my_sf,
  c("SUBSYSTEM_Intertidal","nwi_sys_EorM", universal_colnames),  # scenario 1 has Intertidal and marine or estuarine
  id_cols = id_colnames) %>%
  rename(constr_intertidal = vals)

scenario_2 = geom_mean_columns(
  my_sf,
  c("depth_range_suspended", universal_colnames),  # scenario 2 has depth_range_suspended
  id_cols = id_colnames) %>%
  rename(constr_suspended = vals)

scenario_3 = geom_mean_columns(
  my_sf,
  c("depth_range_floating", universal_colnames),  # scenario 3 has depth_range_floating
  id_cols = id_colnames) %>%
  rename(constr_floating = vals)


#############################
output = my_sf %>%
  select(GRID_ID, study_area) %>%
  left_join(scenario_1, by=c("GRID_ID", "study_area"))

st_write(output, dsn=constr_dsn, layer = "constraints_intertidal_20240829")
#

output = my_sf %>%
  select(GRID_ID, study_area) %>%
  left_join(scenario_2, by=c("GRID_ID", "study_area"))

st_write(output, dsn=constr_dsn, layer = "constraints_suspended_20240829")
#

output = my_sf %>%
  select(GRID_ID, study_area) %>%
  left_join(scenario_3, by=c("GRID_ID", "study_area"))

st_write(output, dsn=constr_dsn, layer = "constraints_floating_20240829")




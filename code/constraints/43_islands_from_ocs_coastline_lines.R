
library(sf)
library(terra)
library(dplyr)
library(purrr)
library(tidyterra)

#
fp = "./regional/b_intermediate_data/study_areas_full.shp"
study_areas = st_read(fp, quiet = TRUE) %>%
  select(portName)

#
fp = "./regional/b_intermediate_data/coastline/ak_aoa_approachCoastlineOcsNavChart.shp"
sf_appr <- st_read(fp)

fp = "./regional/b_intermediate_data/coastline/ak_aoa_harborCoastlineOcsNavChart.shp"
sf_harb <- st_read(fp)

#

for(n in seq(nrow(study_areas))){
  
  print(study_areas$portName[n])
  
  study_area = study_areas[n,] %>%
    st_transform(st_crs(sf_appr))
  
  my_sf = rbind(
    sf_harb %>% 
      st_crop(., study_area) %>%
      select(geometry),
    sf_appr %>% 
      st_crop(., study_area) %>%
      select(geometry)
  )
  
  #
  nrow_start <- nrow(my_sf)
  nrow_run <- nrow_start+1
  ncol_start <- ncol(my_sf)
  
  while (nrow_run > dim(my_sf)[1]) { # iterate through until complete
    
    nrow_run <- nrow(my_sf)
    
    my_sf$intersect_group <- unlist(map(st_intersects(my_sf),1)) # create grouping based on first line of intersection
    my_sf <- aggregate(my_sf, by=list(my_sf$intersect_group),FUN=first,do_union=TRUE)[,3] # aggregate data based on grouping
    
    print(paste0(nrow_start-nrow(my_sf)," features merged"))
  }
  


oname = paste0("./regional/b_intermediate_data/coastline/",
               "ak_aoa_ocsNavChartMerged_",
               study_areas$portName[n],
               ".shp")

# st_write(my_sf, oname, delete_layer = TRUE)

} # n loop



###########################################
# after constructing polygons in arcgis

library(sf)

# my_polys = st_read("./regional/b_intermediate_data/coastline/ak_aoa_ocsNavChartPolygons.shp")


my_polys = my_islands %>%
  filter(island==0)

my_polys$id = seq(nrow(my_polys))

min_br = minRect(vect(my_polys), by="id")

for(n in seq(length(min_br))){
  
  my_polys$ar_width[n] = round(width(min_br[n]))
  my_polys$ar_lengt[n] = round(expanse(min_br[n])/width(min_br[n]))
  
  
}

my_polys$area_m2 = round(units::drop_units(st_area(my_polys)))

my_polys$perim_m = round(units::drop_units(st_perimeter(my_polys)))

my_polys$aspRat = my_polys$ar_lengt / my_polys$ar_width
my_polys$paRat = my_polys$perim_m / my_polys$area_m2

my_polys = my_polys %>%
  mutate(
    island = ifelse(area_m2 < 4046, 0,
                    ifelse(aspRat>8, 0,
                           ifelse(paRat>0.075, 0, 1)))
  )


st_write(my_polys, "./regional/b_intermediate_data/coastline/ak_aoa_ocsNavChartPolygons_edited.shp", delete_layer = TRUE)



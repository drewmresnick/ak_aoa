
library(terra)
library(sf)
library(dplyr)

#
my_islands = st_read("./regional/b_intermediate_data/coastline/ak_aoa_Islands_ocsNavChartCoastline.shp")

fp = "./regional/b_intermediate_data/combined_gpkgs/ak_aoa_hexGrid_constraintsDataCombined.gpkg"
my_hex_grid = st_read(dsn=fp, "ak_aoa_hexGrid_constraintsDataCombined") %>%
  select(GRID_ID, study_area, geom)

th_ovrlp = 0.8  # fraction of hex grid for islands overlap

####
overlaps = st_intersection(my_hex_grid, my_islands)

overlaps$intsct_area_m = units::drop_units(st_area(overlaps))

overlaps = st_drop_geometry(overlaps) %>%
  group_by(GRID_ID, study_area) %>%
  summarise(intsct_area_m = sum(intsct_area_m))

##
island_hex = my_hex_grid %>%
  left_join(overlaps, by=c("GRID_ID", "study_area")) %>%
  replace_na(list("intsct_area_m"=0))

island_hex = island_hex %>%
  mutate(island_80 = as.numeric(intsct_area_m<(th_ovrlp*20234.38)))

st_write(island_hex, "./regional/b_intermediate_data/coastline/ak_aoa_hexGrid_islandConstraint.gpkg")




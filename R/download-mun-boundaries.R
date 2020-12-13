library(tidyverse)
library(sf)
library(tidycensus)
library(rmapshaper)

mun_bound_online <- "https://opendata.arcgis.com/datasets/278ce38ecd784b79993af098f81809ed_163.geojson"

mun_sf <- read_sf(mun_bound_online) %>% 
  count(municipality = NAME) %>% 
  select(-n) %>% 
  st_transform(2263)

tract_geo <- get_acs(
  geography = "tract",
  state = "NY",
  county = "Westchester",
  variables = "B01003_001",
  geometry = TRUE
  ) %>% 
  select(GEOID, total_pop = estimate) %>% 
  st_transform(2263)

pop_by_mun <- tract_geo %>% 
  st_join(mun_sf, largest = TRUE) %>% 
  st_drop_geometry() %>% 
  group_by(municipality) %>% 
  summarize(total_pop = sum(total_pop))

mun_sf %>% 
  left_join(pop_by_mun, by = "municipality") %>%
  relocate(geometry, .after = last_col()) %>% 
  ms_simplify(keep_shapes = TRUE, keep = 0.01) %>%
  write_rds("data/mun-boundary.rds")

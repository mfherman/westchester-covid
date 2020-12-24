library(tidyverse)
library(jsonlite)
library(rvest)
library(sf)

nh_name_entity <- fromJSON("https://profiles.health.ny.gov/nursing_home/get_json") %>% 
  as_tibble() %>% 
  mutate(name = toupper(name)) %>% 
  select(name, entity_id, geo_lat, geo_long, address, city, zipcode)

get_nh_bed <- function(x) {
  
  message(paste("Scraping entity", x))
  url <- paste0("https://profiles.health.ny.gov/nursing_home/tab_overview/", x)

  read_html(url) %>% 
    html_node("#number-of-beds") %>% 
    html_table() %>% 
    slice_tail(n = 1) %>% 
    transmute(entity_id = x, beds = as.numeric(X2))
}

nh_beds <- map_dfr(nh_name_entity$entity_id, get_nh_bed)

nh_clean <- nh_name_entity %>% 
  left_join(nh_beds, by = "entity_id") %>% 
  filter(!is.na(geo_lat)) %>% 
  mutate(name = str_to_title(name)) %>% 
  st_as_sf(
    coords = c("geo_long", "geo_lat"),
    crs = 4326
  )

write_sf(nh_clean, "data/nursing-home-point.geojson")

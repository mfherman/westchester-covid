library(sf)
library(tidyverse)
library(jsonlite)

url <- "https://covidhotspotlookup.health.ny.gov/assets/HotSpots_Zone.geojson"

aa <- read_sf(url)



aa

rates_url <- "https://schoolcovidreportcard.health.ny.gov/data/positivity/positivity.rates.json"




a <- jsonlite::fromJSON(rates_url, simplifyDataFrame = TRUE)


map_dfr(a, bind_rows) %>% 
  as_tibble()

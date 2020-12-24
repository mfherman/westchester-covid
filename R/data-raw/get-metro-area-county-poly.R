library(tidyverse)
library(tidycensus)
library(rmapshaper)
library(sf)

county_geo <- get_acs(
  geography = "county",
  variables = "B01003_001",
  state = c("NY", "NJ", "CT"),
  geometry = TRUE,
  year = 2019,
  survey = "acs1"
  )

metro_fips <- c("34003", "36119", "36059", "36087", "09001", "34031", "36103", 
                "34017", "09005", "34013", "34027", "36071", "09009", "36079", 
                "34037", "36027", "36111", "36005", "36081", "36061", "36085",
                "36047")

nyc <- county_geo %>% 
  filter(GEOID %in% c("36005", "36081", "36061", "36085", "36047")) %>% 
  summarize(
    fips = NA_character_,
    county = "New York City",
    state = "New York",
    total_pop = sum(estimate)
  )

county_simple <- county_geo %>% 
  filter(GEOID %in% metro_fips) %>%
  ms_simplify(keep_shapes = TRUE, keep = 0.2) %>% 
  transmute(
    fips = GEOID,
    county = str_remove(NAME, " County.*"),
    state = str_remove(NAME, ".*,\\s*"),
    total_pop = estimate
    ) %>% 
  bind_rows(nyc) %>% 
  st_transform(4326) 

write_sf(county_simple, "data/county-poly.geojson")

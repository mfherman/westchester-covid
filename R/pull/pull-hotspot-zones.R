source(here::here("R/build/attach-packages.R"))
message(glue("{Sys.time()} -- Starting download of NY hotspots"))

url <- "https://covidhotspotlookup.health.ny.gov/assets/HotSpots_Zone.geojson"

hotspot_geo <- read_sf(url) %>% 
  clean_names() %>% 
  transmute(
    zone_id = ana_id,
    cluster = str_replace(cluster, "_", " "),
    zone,
    date_eff = as.Date(dmy_hms(effct_date))
    ) %>% 
  arrange(zone_id)

rates_url <- "https://schoolcovidreportcard.health.ny.gov/data/positivity/positivity.rates.json"

hotspot_rates <- jsonlite::fromJSON(rates_url, simplifyDataFrame = TRUE) %>% 
  map_dfr(bind_rows) %>% 
  as_tibble() %>% 
  clean_names() %>% 
  mutate(date = as.Date(mdy_hms(average_end_date))) %>% 
  filter(date == max(date)) %>% 
  select(date, zone_id = zone_mapping_id, pos_rate = percent_positive) %>% 
  arrange(zone_id)

hotspot_geo %>% 
  ms_simplify(keep = 0.25) %>% 
  left_join(hotspot_rates, by = "zone_id") %>%
  write_sf("data/hotspot-poly.geojson")

message(glue("Most recent data is from {max(hotspot_rates$date)}"))
message(glue("{Sys.time()} -- Finsished download of NY hotspots"))

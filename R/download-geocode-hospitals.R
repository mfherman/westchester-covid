library(tidyverse)
library(vroom)
library(tidygeocoder)
library(sf)

url <- "https://healthdata.gov/sites/default/files/reported_hospital_capacity_admissions_facility-level_weekly_average_timeseries_20201207.csv"

hospital <- vroom(url)

fips <- c("36071", "36079", "36087", "36119", "09001", "34031")

hosp_addr <- hospital %>% 
  filter(fips_code %in% fips, hospital_subtype != "Childrens Hospitals") %>% 
  distinct(
    hospital_pk,
    hospital_name,
    address,
    city,
    zip
    )

hosp_geo <- hosp_addr %>% 
  geocode(
    street = address,
    city = city,
    postalcode = zip,
    method = "cascade"
    ) %>% 
  mutate(across(c(hospital_name:city), str_to_title)) %>% 
  select(-geo_method) %>% 
  st_as_sf(
    coords = c("long", "lat"),
    crs = 4326,
    remove = FALSE
  )

write_rds(hosp_geo, "data/hospital-locations.rds")


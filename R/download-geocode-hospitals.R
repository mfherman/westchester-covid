library(tidyverse)
library(vroom)
library(censusxy)
library(sf)

url <- "https://healthdata.gov/sites/default/files/reported_hospital_capacity_admissions_facility-level_weekly_average_timeseries_20201207.csv"

hospital <- vroom(url)

hosp_addr <- hospital %>% 
  filter(fips_code == "36119", hospital_subtype != "Childrens Hospitals") %>% 
  distinct(
    hospital_pk,
    hospital_name,
    address,
    city,
    zip
    )

hosp_geo <- hosp_addr %>% 
  cxy_geocode(
    street = "address",
    city = "city",
    zip = "zip",
    class = "sf"
  ) %>% 
  st_transform(4326) %>% 
  mutate(across(c(hospital_name:city), str_to_title))

write_rds(hosp_geo, "data/hospital-locations.rds")
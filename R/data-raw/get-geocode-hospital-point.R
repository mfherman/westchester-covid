library(tidyverse)
library(vroom)
library(tidygeocoder)
library(sf)

url <- "https://healthdata.gov/node/3651441/download"

hospital <- vroom(url)

fips <- c("34003", "36119", "36087", "09001", "34031", "34017", "09005", "34013",
          "34027", "36071", "09009", "36079", "34037", "36027", "36111")

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
  mutate(address = str_replace(address, "STEET", "STREET")) %>% 
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

write_sf(hosp_geo, "data/hospital-point.geojson")


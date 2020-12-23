library(tidyverse)
library(tabulizer)
library(sf)

url <- "https://www.health.ny.gov/statistics/diseases/covid-19/fatalities_nursing_home_acf.pdf"
file <- paste0("data/nh-pdf/nys-nursing-home-", Sys.Date(), ".pdf")
download.file(url, file, mode = "wb")

date <- extract_text(file, pages = 1) %>% 
  str_extract("Data through .*") %>% 
  lubridate::mdy()

nh_deaths <- extract_tables(file, pages = 8) %>% 
  as.data.frame() %>% 
  transmute(
    name = X1,
    pfi = X2,
    county = X3,
    deaths_confirmed = as.numeric(X4),
    deaths_presumed = as.numeric(X5)
  ) %>% 
  mutate(
    name = case_when(
      name == "NORTH WESTCHESTER RESTORATIVE THERAPY AND NURSING" ~ "NORTH WESTCHESTER RESTORATIVE THERAPY AND NURSING CENTER",
      name == "THE PARAMOUNT AT SOMERS REHABILITATION AND NURSING" ~ "THE PARAMOUNT AT SOMERS REHABILITATION AND NURSING CENTER",
      TRUE ~ name
      ),
    name = str_to_title(name)
    ) %>% 
  filter(county == "Westcheste") %>% 
  as_tibble()

nh_beds_geo <- read_rds("data/nh-beds-geo.rds")

nh_clean <- nh_beds_geo %>% 
  inner_join(nh_deaths, by = "name") %>% 
  mutate(
    date = date,
    city = str_replace(city, "On", "on"),
    city = if_else(city == "Croton on Hudson", "Croton-on-Hudson", city)
    ) %>% 
  transmute(
    date,
    name,
    deaths_confirmed,
    deaths_presumed,
    deaths_total = deaths_confirmed + deaths_presumed,
    beds,
    address,
    city = str_replace(city, "On", "on"),
    zipcode
    )

write_rds(nh_clean, "data/nh-deaths.rds")

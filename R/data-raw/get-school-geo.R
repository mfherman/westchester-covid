library(tidyverse)
library(jsonlite)
library(tidygeocoder)

parse_school_dir <- function(x) {
  fromJSON(x) %>% 
    map_dfr(bind_rows, .id = "school")
}

parse_school_meta <- function(x) {
  tibble(
    school = x$name,
    school_beds = x$bedsCode,
    district = if_else(is.null(x$districtName), NA_character_, x$districtName),
    district_beds = if_else(is.null(x$districtBedsCode), NA_character_, x$districtBedsCode),
    county = x$county,
    street = x$addressLine1,
    city = x$city,
    state = x$state,
    zip = x$zip
  )
}

types <- c("public", "private", "charter", "boces")
url <- glue("https://schoolcovidreportcard.health.ny.gov/data/directory/{types}.directory.abbreviated.json")

school_dir <- map_dfr(url, parse_school_dir)

wch_schools <- school_dir %>%
  filter(type == "School", str_starts(schoolBedsCode, "66")) %>%
  mutate(school = str_remove(school, " \\(.*")) %>%
  transmute(
    school = school,
    school_beds = schoolBedsCode,
    district_beds = districtBedsCode,
    address,
    type = schoolType,
    type_json = case_when(
      type == "Public" ~ "public",
      type == "Private School" ~ "private",
      type == "BOCES School" ~ "boces",
      type == "Charter School" ~ "charter"
      ),
    district_beds_json = if_else(is.na(district_beds), type_json, district_beds),
    district_beds_json = if_else(type_json == "boces", paste0("boces.", district_beds_json), district_beds_json),
    url = glue("https://schoolcovidreportcard.health.ny.gov/data/{type_json}/school.{district_beds_json}.{school_beds}.json")
    )

fromJSON_safe <- safely(fromJSON)

school_json <- map(wch_schools$url, fromJSON_safe)
school_data <- school_json %>% 
  map("result") %>% 
  compact() %>% 
  map_dfr(parse_school_meta)

geo <- school_data %>% 
  geocode(
    street = street,
    city = city,
    state = state,
    postalcode = zip,
    method = "cascade"
    )

# do a little manual geocoding for those that didn't geo
geo %>% 
  filter(is.na(lat)) %>% 
  write_csv("data/raw/no-geo-school.csv", overwrite = FALSE)

# read back in manually geocoded schools
manual_geo <- read_csv(
  "data/raw/no-geo-school.csv",
  col_types = cols(.default = readr::col_character())
  ) %>% 
  select(school_beds, lat, long) %>% 
  mutate(across(c(lat, long), as.double))

school_geo_clean <- geo %>% 
  left_join(manual_geo, by = "school_beds") %>%
  left_join(select(wch_schools, school_beds, type, url), by = "school_beds") %>% 
  mutate(
    lat = coalesce(lat.y, lat.x),
    long = coalesce(long.y, long.x),
    across(c(school, district, street, city), str_to_title)
    ) %>%
  select(-geo_method, -county, -(lat.x:long.y)) %>%
  st_as_sf(
    coords = c("long", "lat"),
    crs = 4326,
    remove = TRUE
    )

write_sf(school_geo_clean, "data/school-point.geojson")

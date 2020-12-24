library(tidyverse)
library(readxl)
library(jsonlite)
library(glue)

# https://schoolcovidreportcard.health.ny.gov/assets/district.neighbors.json
# https://schoolcovidreportcard.health.ny.gov/data/public/school.660101.660101030002.json

school_dir <- fromJSON("https://schoolcovidreportcard.health.ny.gov/data/directory/public.directory.abbreviated.json") %>% 
  map_dfr(bind_rows, .id = "school")

districts <- school_dir %>%
  filter(type == "District") %>%
  select(
    district = school,
    district_beds = districtBedsCode
  )

schools <- school_dir %>%
  filter(type == "School") %>%
  mutate(school = str_remove(school, " \\(.*")) %>% 
  select(
    school = school,
    school_beds = schoolBedsCode,
    district_beds = districtBedsCode,
    address
  )




dist_json <- glue("https://schoolcovidreportcard.health.ny.gov/data/public/district.{districts$district_beds}.json")


a <- map(dist_json[1], fromJSON)



View(a)

  as.data.frame()


school <- fromJSON("https://schoolcovidreportcard.health.ny.gov/data/public/school.660101.660101030002.json")

View(school)


https://schoolcovidreportcard.health.ny.gov/data/public/district.660101.json




school_dir %>% 
  filter(is.na(schoolBedsCode))



https://schoolcovidreportcard.health.ny.gov/data/public/district.621601.json
300000.343000010010 
https://schoolcovidreportcard.health.ny.gov/data/public/school.300000.343000010010.json

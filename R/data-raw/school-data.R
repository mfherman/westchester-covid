library(tidyverse)
library(readxl)
library(jsonlite)

https://schoolcovidreportcard.health.ny.gov/assets/district.neighbors.json
https://schoolcovidreportcard.health.ny.gov/data/public/school.660101.660101030002.json



school_dir <- fromJSON("https://schoolcovidreportcard.health.ny.gov/data/directory/public.directory.abbreviated.json") %>% 
  map_dfr(bind_rows, .id = "school")


districts <- school_dir %>% 
  filter(is.na(schoolBedsCode))


library(glue)


dist_code <- districts$districtBedsCode

dist_json <- glue("https://schoolcovidreportcard.health.ny.gov/data/public/district.{dist_code}.json")


map(dist_json[1], fromJSON)




fromJSON("https://schoolcovidreportcard.health.ny.gov/data/public/district.660101.json")


https://schoolcovidreportcard.health.ny.gov/data/public/district.660101.json




school_dir %>% 
  filter(is.na(schoolBedsCode))



https://schoolcovidreportcard.health.ny.gov/data/public/district.621601.json
300000.343000010010 
https://schoolcovidreportcard.health.ny.gov/data/public/school.300000.343000010010.json

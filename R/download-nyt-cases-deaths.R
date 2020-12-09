suppressWarnings(suppressPackageStartupMessages(library(tidyverse)))
suppressWarnings(suppressPackageStartupMessages(library(glue)))

message(glue("{Sys.time()} -- Starting download of NY Times data"))

url <- "https://github.com/nytimes/covid-19-data/raw/master/us-counties.csv"

nyt_county <- read_csv(url, col_types = cols()) %>% 
  filter(county == "Westchester", state == "New York") %>% 
  select(date, cases, deaths)

nyt_clean <- nyt_county %>% 
  mutate(
    new_cases = cases - lag(cases),
    new_cases = if_else(is.na(new_cases), 0, new_cases),
    new_deaths = deaths - lag(deaths),
    new_deaths = if_else(is.na(new_deaths), 0, new_deaths)
    ) %>% 
  rename(total_cases = cases, total_deaths = deaths) %>% 
  pivot_longer(-date, names_to = "metric")

write_csv(nyt_clean, "data/by-county-cases-deaths-nyt.csv")

message(glue("Most recent data is from {max(nyt_clean$date)}"))
message(glue("{Sys.time()} -- Finsished download of NY Times data"))

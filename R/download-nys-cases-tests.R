suppressWarnings(suppressPackageStartupMessages(library(tidyverse)))
suppressWarnings(suppressPackageStartupMessages(library(janitor)))
suppressWarnings(suppressPackageStartupMessages(library(lubridate)))
suppressWarnings(suppressPackageStartupMessages(library(glue)))

message(glue("{Sys.time()} -- Starting download of NY state data"))

url <- "https://health.data.ny.gov/api/views/xdss-u53e/rows.csv?accessType=DOWNLOAD"

state_county <- read_csv(url, col_types = cols()) %>% 
  clean_names() %>% 
  filter(county == "Westchester") %>% 
  mutate(date = mdy(test_date))

state_clean <- state_county %>% 
  transmute(
    date,
    new_cases = new_positives,
    total_cases = cumulative_number_of_positives,
    new_tests = total_number_of_tests_performed,
    total_tests = cumulative_number_of_tests_performed,
    pos_rate = new_cases / new_tests,
    pos_rate = if_else(is.na(pos_rate), 0, pos_rate),
    ) %>% 
  pivot_longer(-date, names_to = "metric")

write_csv(state_clean, "data/by-county-cases-tests-nys.csv")

message(glue("Most recent data is from {max(state_clean$date)}"))
message(glue("{Sys.time()} -- Finsished download of NY state data"))

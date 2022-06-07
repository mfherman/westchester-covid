source(here::here("R/build/attach-packages.R"))
message(glue("{Sys.time()} -- Starting download of NY Times data"))

urls <- paste0("https://github.com/nytimes/covid-19-data/raw/master/us-counties-", 2020:2022, ".csv")

ny_counties <- c("Westchester", "Putnam", "Rockland", "Orange", "Ulster",
                 "New York City", "Suffolk", "Nassau", "Dutchess")

ct_counties <- c("Fairfield", "New Haven", "Litchfield")

nj_counties <- c("Bergen", "Passaic", "Sussex", "Hudson", "Essex", "Morris")

nyt_county <- read_csv(urls, col_types = cols()) %>% 
  filter(
    (state == "New York" & county %in% ny_counties) |
    (state == "Connecticut" & county %in% ct_counties) |
    (state == "New Jersey" & county %in% nj_counties)
    )

nyt_clean <- nyt_county %>% 
  group_by(county, state) %>% 
  mutate(
    new_cases = cases - lag(cases),
    new_cases = if_else(is.na(new_cases), 0, new_cases),
    new_deaths = deaths - lag(deaths),
    new_deaths = if_else(is.na(new_deaths) | new_deaths < 0, 0, new_deaths)
    ) %>% 
  ungroup() %>% 
  rename(total_cases = cases, total_deaths = deaths)

write_csv(nyt_clean, "data/county-cases-deaths-nyt.csv")

message(glue("Most recent data is from {max(nyt_clean$date)}"))
message(glue("{Sys.time()} -- Finsished download of NY Times data"))

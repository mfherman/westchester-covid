source(here::here("R/build/attach-packages.R"))
suppressPackageStartupMessages(suppressWarnings(suppressMessages(library(tabulizer))))

message(glue("{Sys.time()} -- Starting download of NYS nursing home deaths"))

url <- "https://www.health.ny.gov/statistics/diseases/covid-19/fatalities_nursing_home_acf.pdf"
file <- paste0("data/nh-pdf/nys-nursing-home-", Sys.Date(), ".pdf")
download.file(url, file, mode = "wb", quiet = TRUE)

date <- extract_text(file, pages = 1) %>% 
  str_extract("Data through .*") %>% 
  mdy()

nh_deaths <- extract_tables(file, pages = 8) %>% 
  as.data.frame() %>% 
  transmute(
    date = date,
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
  select(-county)

write_csv(nh_deaths, "data/nursing-home-deaths.csv")

message(glue("Most recent data is from {date}"))
message(glue("{Sys.time()} -- Finished download of NYS nursing home deaths"))

source(here::here("R/build/attach-packages.R"))
message(glue("{Sys.time()} -- Starting scrape for CDC vaccine data"))

url <- "https://covid.cdc.gov/covid-data-tracker/COVIDData/getAjaxData?id=vaccination_data"

new_cdc_vac <- fromJSON(url)[["vaccination_data"]] %>% 
  clean_names() %>% 
  select(
    date,
    state = location,
    state_long = long_name,
    total_distributed = doses_distributed,
    total_administered = doses_administered
  )

old_cdc_vac <- read_csv("data/state-vac-cdc.csv", col_types = cols())
new_date <- max(new_cdc_vac$date)
max_old_date <- max(old_cdc_vac$date)

if (new_date > max_old_date) {
  message(glue("{Sys.time()} -- Data is updated! Writing to file."))
  old_cdc_vac %>% 
    bind_rows(new_cdc_vac) %>% 
    write_csv("data/state-vac-cdc.csv")
} else {
  message(glue("{Sys.time()} -- No new data."))
}

message(glue("{Sys.time()} -- Finsished scrape for CDC vaccine data"))

source(here::here("R/build/attach-packages.R"))
suppressPackageStartupMessages(suppressWarnings(library(rvest)))
suppressPackageStartupMessages(suppressWarnings(library(jsonlite)))
suppressPackageStartupMessages(suppressWarnings(library(httr)))

message(glue("{Sys.time()} -- Starting download of NYS vaccine data"))

url <- "https://covid19tracker.health.ny.gov/views/Vaccine_Management_public/NYSVaccinations?%3Aembed=y&%3AshowVizHome=n&%3Atabs=n&%3Atoolbar=n&%3Adevice=desktop"
h <- read_html(url)

data <- h %>% 
  html_nodes("textarea#tsConfigContainer") %>% 
  html_text()

json <- fromJSON(data)

url_new <- modify_url(
  "https://covid19tracker.health.ny.gov",
  path = paste(json$vizql_root, "/bootstrapSession/sessions/", json$sessionid, sep = "")
  )

resp <- POST(url_new, body = list(sheet_id = json$sheetId), encode = "form")
data <- content(resp, "text")

extract <- str_match(data, "\\d+;(\\{.*\\})\\d+;(\\{.*\\})")
data <- fromJSON(extract[1, 3])

table <- data[["secondaryInfo"]][["presModelMap"]][["dataDictionary"]][["presModelHolder"]][["genDataDictionaryPresModel"]][["dataSegments"]][["0"]][["dataColumns"]][["dataValues"]][[2]]


second_admin_pct <- parse_number(table[5]) / (parse_number(table[3]) + parse_number(table[5]))
second_rcv_pct <- parse_number(table[4]) / (parse_number(table[2]) + parse_number(table[4]))

new_data <- tibble(
  date = lubridate::mdy(table[1]),
  region = table[7:16],
  doses_admin = parse_number(table[35:44]),
  doses_recieved = parse_number(table[46:55]),
  first_dose_admin_est = doses_admin * (1 - second_admin_pct),
  second_dose_admin_est = doses_admin * second_admin_pct,
  first_dose_rcv_est = doses_recieved * (1 - second_rcv_pct),
  second_dose_rcv_est = doses_recieved * second_rcv_pct
)

old_data <- read_csv(here("data/state-vac.csv"), col_types = cols())
max_date <- max(old_data$date)

if (max_date < max(new_data$date)) {
  
  old_data %>% 
    bind_rows(new_data) %>% 
    write_csv(here("data/state-vac.csv"))
  
  message(glue("Most recent data is from {max(new_data$date)}"))

} else {
  message("No new data")
}

message(glue("{Sys.time()} -- Finished download of NYS vaccine data"))
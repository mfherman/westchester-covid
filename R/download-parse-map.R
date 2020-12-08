library(tidyverse)
library(lubridate)
library(rtweet)
library(magick)

# pull max westchester gov tweets via API
westchestergov_timeline <- get_timeline("westchestergov", n = 3200)

# find tweets referencing covid map with media url
covid_map_img_url <- westchestergov_timeline %>% 
  filter(!is.na(media_url), str_detect(text, fixed("Covid-19 cases", ignore_case = TRUE))) %>%
  transmute(created_at, text, media_url = paste0(unlist(media_url), "?format=jpg&name=4096x4096"))

# download covid map images
walk2(
  covid_map_img_url$media_url,
  paste0("map_img/", as.Date(covid_map_img_url$created_at), ".jpg"),
  ~ download.file(.x, .y, mode = "wb")
  )

parse_covid_map <- function(x) {

  img <- image_read(x)
  height <- image_info(img)$height
  width <- image_info(img)$width
  
  message(paste("Processing", x))
  
  date <- img %>% 
    image_crop(geometry_area(400 / 3165 * width, 120 / 4096 * height,
                             2000 / 3165 * width, 3915 / 4096 * height)) %>% 
    image_ocr() %>% 
    lubridate::mdy()
  
  table <- img %>%
    image_crop(geometry_area(675 / 3165 * width, 1600 / 4096 * height,
                             2375 / 3165 * width, 1800 / 4096 * height)) %>% 
    image_ocr() %>% 
    str_split("\n") %>% 
    unlist() %>% 
    str_remove_all("[[:punct:]]") %>% 
    as_tibble() %>% 
    tail(-1)
  
  table %>% 
    mutate(
      date = date,
      total_cases = word(value, -3),
      active_cases = word(value, -2),
      new_cases = word(value, -1)
      ) %>% 
    separate(value, into = "municipality", sep = "[0-9]", extra = "drop") %>% 
    mutate(municipality = str_trim(municipality)) %>% 
    mutate(across(new_cases:total_cases, parse_number)) %>% 
    relocate(date)

}

# create safe version of function to not quit on error
parse_covid_map_safely <- safely(parse_covid_map)

# get all downloaded covid map files
covid_map_img_files <- list.files("map_img", full.names = TRUE)

# parse every map
covid_map_data <- map(covid_map_img_files, parse_covid_map_safely)

covid_map_data_success <- map_dfr(covid_map_data, "result") %>% 
  mutate(
    municipality = str_remove(municipality, "\\| "),
    municipality = case_when(
      municipality == "HastingsonHudson" ~ "Hastings-on-Hudson",
      municipality == "CrotononHudson" ~ "Croton-on-Hudson",
      TRUE ~ municipality
      ),
    total_cases = if_else(str_starts(municipality, "Unk"), new_cases, total_cases),
    new_cases = if_else(str_starts(municipality, "Unk"), NA_real_, new_cases)
    ) %>% 
  filter(municipality != "")

covid_map_data_success %>% 
  write_csv("data/raw/map-data-ocr-output.csv")



cleaned <- read_csv("data/raw/map-data-ocr-output-cleaned.csv") %>% 
  mutate(date = mdy(date)) %>% 
  filter(municipality != "Unknown", date < as.Date("2020-12-03")) %>% 
  pivot_longer(ends_with("cases"), names_to = "metric", values_to = "cases") %>% 
  mutate(metric = str_remove(metric, "_cases"))

scraped_data <- read_csv("data/by-mun-daily.csv")

cleaned %>% 
  bind_rows(scraped_data) %>%
  write_csv("data/by-mun-daily.csv")

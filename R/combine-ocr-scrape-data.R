library(tidyverse)

cleaned <- read_csv("data/raw/map-data-ocr-output-cleaned.csv") %>% 
  mutate(date = mdy(date)) %>% 
  filter(municipality != "Unknown", date < as.Date("2020-12-03")) %>% 
  pivot_longer(ends_with("cases"), names_to = "metric", values_to = "cases") %>% 
  mutate(metric = str_remove(metric, "_cases"))

scraped_data <- read_csv("data/by-mun-daily.csv")

cleaned %>% 
  bind_rows(scraped_data) %>%
  write_csv("data/by-mun-daily.csv")

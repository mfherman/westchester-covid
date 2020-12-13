suppressWarnings(suppressPackageStartupMessages(library(tidyverse)))
suppressWarnings(suppressPackageStartupMessages(library(rvest)))
suppressWarnings(suppressPackageStartupMessages(library(janitor)))
suppressWarnings(suppressPackageStartupMessages(library(lubridate)))
suppressWarnings(suppressPackageStartupMessages(library(glue)))

message(glue("{Sys.time()} -- Starting scrape for new daily muncipalilty data"))

scrape_mun_daily <- function() {

  covid_web <- read_html("https://www.westchestergov.com/covid-19-cases")
  
  web_date <- covid_web %>% 
    html_node("#jm-maincontent > div > div:nth-child(5) > table > caption") %>% 
    html_text() %>% 
    str_remove("Active and Total Westchester County COVID-19 Cases as of ") %>% 
    mdy()
  
  web_table <- covid_web %>% 
    html_node("#jm-maincontent > div > div:nth-child(5) > table") %>% 
    html_table() %>% 
    clean_names()
  
  web_table %>% 
    mutate(date = web_date) %>% 
    relocate(date)

}

update_daily_mun_data <- function() {
  
  updated <- FALSE
  counter <- 0
  
  old_mun_daily <- read_csv("data/by-mun-cases.csv", col_types = cols())
  max_old_date <- max(old_mun_daily$date)

  while (!updated | counter < 22) {
    new_mun_daily <- scrape_mun_daily()
    updated <- max(new_mun_daily$date) > max_old_date
    counter <- sum(counter, 1)
    
    if (!updated) {
      message(glue("{Sys.time()} -- No new data. Waiting 1 hour to scrape again."))
      Sys.sleep(60 * 60)
    }
  }
  
  message(glue("{Sys.time()} -- Data is updated! Writing to file."))
  
  old_mun_daily %>% 
    bind_rows(new_mun_daily) %>% 
    write_csv("data/by-mun-cases.csv")
}

update_daily_mun_data()

message(glue("{Sys.time()} -- Finsished scrape for new daily muncipalilty data"))

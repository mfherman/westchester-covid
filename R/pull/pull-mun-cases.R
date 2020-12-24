source(here::here("R/build/attach-packages.R"))
message(glue("{Sys.time()} -- Starting scrape for new daily muncipalilty data"))

scrape_mun_daily <- function() {

  url <- "https://services.arcgis.com/XKEHpOulfycN9cGC/arcgis/rest/services/Mun_Coronavirus_poly/FeatureServer/0/query?f=json&where=(Confirmed%20%3C%3E%20555)%20AND%20(Active%3E0)&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=NAME%20asc&outSR=102100&resultOffset=0&resultRecordCount=100&resultType=standard&cacheHint=true"
  url_date <- "https://services.arcgis.com/XKEHpOulfycN9cGC/ArcGIS/rest/services/Mun_Coronavirus_poly/FeatureServer/0?f=pjson"
  
  last_update <- as.Date(as_datetime(fromJSON(url_date)[["editingInfo"]][["lastEditDate"]] / 1000))
  
  fromJSON(url, flatten = TRUE)[["features"]] %>%
    transmute(
      date = last_update,
      municipality = attributes.NAME,
      total_cases = attributes.Confirmed,
      active_cases = attributes.Active,
      new_cases = attributes.Daily_New
    )
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

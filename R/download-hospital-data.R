source(here::here("R/attach-packages.R"))
message(glue("{Sys.time()} -- Starting download of HHS hospital data"))

url <- "https://healthdata.gov/node/3651441/download"

hospital <- vroom(url, col_types = cols())

fips <- c("34003", "36119", "36087", "09001", "34031", "34017", "09005", "34013",
          "34027", "36071", "09009", "36079", "34037", "36027", "36111")

county_fips <- tidycensus::fips_codes %>% 
  mutate(
    county_fips = paste0(state_code, county_code),
    county = str_remove(county, " County")
    ) %>% 
  select(county, fips_code = county_fips)

hosp_data <- hospital %>% 
  filter((fips_code %in% fips | state == "NY"), hospital_subtype != "Childrens Hospitals") %>% 
  left_join(county_fips, by = "fips_code") %>% 
  select(
    hospital_pk,
    fips_code,
    county,
    state,
    year_week = collection_week,
    bed_capacity   = all_adult_hospital_inpatient_beds_7_day_avg,
    bed_occupied   = all_adult_hospital_inpatient_bed_occupied_7_day_avg,
    icu_capacity   = total_staffed_adult_icu_beds_7_day_avg,
    icu_occupied   = staffed_adult_icu_bed_occupancy_7_day_avg,
    covid_patients = total_adult_patients_hospitalized_confirmed_and_suspected_covid_7_day_avg,
    all_patients   = all_adult_hospital_inpatient_bed_occupied_7_day_avg
    ) %>% 
  mutate(across(where(is.numeric), na_if, -999999))

write_csv(hosp_data, "data/hospital-beds-occupancy.csv")

message(glue("Most recent data is from {max(hosp_data$year_week) + days(7)}"))
message(glue("{Sys.time()} -- Starting download of HHS hospital data"))


    # bed_pct_full = bed_occupied / bed_capacity,
    # icu_pct_full = icu_occupied / icu_capacity,
    # covid_patient_pct = covid_patients / all_patients

# Average of total number of staffed inpatient adult beds in the hospital including all overflow and active surge/expansion beds used for inpatients (including all designated ICU beds) reported during the 7-day period.
# Average of total number of staffed inpatient adult beds that are occupied reported during the 7-day period.
# Average number of total number of staffed inpatient ICU beds reported in the 7-day period.
# Average of total number of staffed inpatient adult ICU beds that are occupied reported in the 7-day period.
# Average number of patients currently hospitalized in an adult inpatient bed who have laboratory-confirmed or suspected COVID19, including those in observation beds reported during the 7-day period.
# Average of total number of staffed inpatient adult beds that are occupied reported during the 7-day period.

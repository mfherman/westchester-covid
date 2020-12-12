library(tidyverse)
library(vroom)

url <- "https://healthdata.gov/sites/default/files/reported_hospital_capacity_admissions_facility-level_weekly_average_timeseries_20201207.csv"

hospital <- vroom(url)

hosp_data <- hospital %>% 
  filter(fips_code == "36119", hospital_subtype != "Childrens Hospitals") %>% 
  select(
    hospital_pk,
    year_week = collection_week,
    bed_capacity   = all_adult_hospital_inpatient_beds_7_day_avg,
    bed_occupied   = all_adult_hospital_inpatient_bed_occupied_7_day_avg,
    icu_capacity   = total_staffed_adult_icu_beds_7_day_avg,
    icu_occupied   = staffed_adult_icu_bed_occupancy_7_day_avg,
    covid_patients = total_adult_patients_hospitalized_confirmed_and_suspected_covid_7_day_avg,
    all_patients   = all_adult_hospital_inpatient_bed_occupied_7_day_avg
    ) %>% 
  mutate(across(where(is.numeric), na_if, -999999))

hosp_long <- hosp_data %>% 
  pivot_longer(
    cols = -c(hospital_pk, year_week),
    names_to = "metric",
    values_to = "n"
  )

write_csv(hosp_long, "data/hospital-beds-occupancy.csv")


    # bed_pct_full = bed_occupied / bed_capacity,
    # icu_pct_full = icu_occupied / icu_capacity,
    # covid_patient_pct = covid_patients / all_patients

# Average of total number of staffed inpatient adult beds in the hospital including all overflow and active surge/expansion beds used for inpatients (including all designated ICU beds) reported during the 7-day period.
# Average of total number of staffed inpatient adult beds that are occupied reported during the 7-day period.
# Average number of total number of staffed inpatient ICU beds reported in the 7-day period.
# Average of total number of staffed inpatient adult ICU beds that are occupied reported in the 7-day period.
# Average number of patients currently hospitalized in an adult inpatient bed who have laboratory-confirmed or suspected COVID19, including those in observation beds reported during the 7-day period.
# Average of total number of staffed inpatient adult beds that are occupied reported during the 7-day period.
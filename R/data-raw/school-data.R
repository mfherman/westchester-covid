source(here::here("R/build/attach-packages.R"))

parse_school <- function(x) {
  tibble(
    school = x$name,
    school_beds = x$bedsCode,
    district = x$districtName,
    district_beds = x$districtBedsCode,
    county = x$county,
    street = x$addressLine1,
    city = x$city,
    state = x$state,
    zip = x$zip,
    model = x$teachingModel,
    date = as.Date(lubridate::mdy_hms(x$updateDate)),
    students = x$currentCounts$onSiteStudentPopulation,
    staff = x$currentCounts$onSiteTeacherPopulation + x$currentCounts$onSiteStaffPopulation,
    all_cases_students = x$allTimeCounts$onSitePositiveStudents,
    all_cases_staff = x$allTimeCounts$onSitePositiveTeachers + x$allTimeCounts$onSitePositiveStaff,
    recent_cases_students = x$lastFourteenDaysCounts$onSitePositiveStudents,
    recent_cases_staff = x$lastFourteenDaysCounts$onSitePositiveTeachers + x$lastFourteenDaysCounts$onSitePositiveStaff
  )
}

school_dir <- fromJSON("https://schoolcovidreportcard.health.ny.gov/data/directory/public.directory.abbreviated.json") %>% 
  map_dfr(bind_rows, .id = "school")

wch_schools <- school_dir %>%
  filter(type == "School") %>%
  mutate(school = str_remove(school, " \\(.*")) %>% 
  select(
    school = school,
    school_beds = schoolBedsCode,
    district_beds = districtBedsCode,
    address
    ) %>% 
  filter(str_starts(school_beds, "66"))

school_json_url <- glue("https://schoolcovidreportcard.health.ny.gov/data/public/school.{school_beds$district_beds}.{school_beds$school_beds}.json")
school_json <- map(school_json_url[340:354], fromJSON)
school_data <- map_dfr(school_json, parse_school)


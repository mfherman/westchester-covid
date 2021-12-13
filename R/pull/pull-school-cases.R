source(here::here("R/build/attach-packages.R"))
message(glue("{Sys.time()} -- Starting download of schools data"))

parse_school <- function(x) {
  tibble(
    school_beds = x$bedsCode,
    model = x$teachingModel,
    date = as.Date(lubridate::mdy_hms(x$updateDate)),
    students = x$currentCounts$studentEnrolled,
    staff = x$currentCounts$teacherEnrolled + x$currentCounts$staffEnrolled,
    all_cases_students = x$allTimeCounts$positiveStudents,
    all_cases_staff = x$allTimeCounts$positiveTeachers + x$allTimeCounts$positiveStaff,
    recent_cases_students = x$lastFourteenDaysCounts$positiveStudents,
    recent_cases_staff = x$lastFourteenDaysCounts$positiveTeachers + x$lastFourteenDaysCounts$positiveStaff
  )
}

school <- read_sf("data/school-point.geojson")
school_json <- map(school$url, fromJSON)

school_cases <- school_json %>% 
  map_dfr(parse_school)

write_csv(school_cases, "data/school-cases.csv")

message(glue("Most recent data is from {max(school_cases$date)}"))
message(glue("{Sys.time()} -- Finsished download of schools data"))

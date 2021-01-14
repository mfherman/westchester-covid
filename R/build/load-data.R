mun_bound    <- read_sf(here("data/mun-poly.geojson"))
county_bound <- read_sf(here("data/county-poly.geojson"))
hotspot      <- read_sf(here("data/hotspot-poly.geojson"))
hosp_geo     <- read_sf(here("data/hospital-point.geojson"))
nh_geo       <- read_sf(here("data/nursing-home-point.geojson"))
school_geo   <- read_sf(here("data/school-point.geojson")) 

hosp_cap     <- read_csv(here("data/hospital-beds-occupancy.csv"), col_types = cols())
mun_cases    <- read_csv(here("data/mun-cases.csv"), col_types = cols())
nh_deaths    <- read_csv(here("data/nursing-home-deaths.csv"), col_types = cols())
mun_acs      <- read_csv(here("data/mun-acs-estimates.csv"), col_types = cols())
cdc_vac      <- read_csv(here("data/state-vac-cdc.csv"), col_types = cols())
school_cases <- read_csv(
  here("data/school-cases.csv"),
  col_types = cols(
    school_beds = col_character(),
    model = col_character(),
    date = col_date(format = ""),
    students = col_double(),
    staff = col_double(),
    all_cases_students = col_double(),
    all_cases_staff = col_double(),
    recent_cases_students = col_double(),
    recent_cases_staff = col_double()
    )
  )

nys_cases <- read_csv(here("data/county-cases-tests-nys.csv"), col_types = cols()) %>% 
  group_by(county) %>% 
  mutate(
    across(
      c(new_cases, total_cases, new_tests, total_tests), 
      list("avg_7" = ~ slide_dbl(.x, mean, .before = 6, .complete = TRUE))
      ),
    pos_rate_avg_7 = new_cases_avg_7 / new_tests_avg_7,
    ) %>% 
  ungroup()

nyt_cases <- read_csv(here("data/county-cases-deaths-nyt.csv"), col_types = cols()) %>% 
  group_by(county, state) %>% 
  mutate(
    new_cases = if_else(state == "New Jersey" & date == as.Date("2021-01-04"), NA_real_, new_cases),
    across(
      where(is.numeric), 
      list("avg_7" = ~ slide_dbl(.x, mean, na.rm = TRUE, .before = 6, .complete = TRUE))
      )
    ) %>% 
  ungroup() %>% 
  inner_join(select(county_bound, -fips), by = c("county", "state")) %>% 
  mutate(
    new_cases_per_cap = new_cases_avg_7 / total_pop * 1e5,
    tot_cases_per_cap = total_cases / total_pop,
    new_deaths_per_cap = new_deaths_avg_7 / total_pop * 1e5
    ) %>% 
  select(-geometry)

nh_clean <- nh_geo %>% 
  inner_join(nh_deaths, by = "name") %>% 
  mutate(
    date = date,
    city = str_replace(city, "On", "on"),
    city = if_else(city == "Croton on Hudson", "Croton-on-Hudson", city)
    ) %>% 
  transmute(
    date,
    name,
    deaths_confirmed,
    deaths_presumed,
    deaths_total = deaths_confirmed + deaths_presumed,
    beds,
    address,
    city = str_replace(city, "On", "on"),
    zipcode
    )

# manually input from https://covid19tracker.health.ny.gov/views/NYS-COVID19-Tracker/NYSDOHCOVID-19Tracker-Fatalities?%3Aembed=yes&%3Atoolbar=no&%3Atabs=no
death_by_race <- tribble(
  ~"race",     ~"pop",  ~"deaths", ~"age_adjust", ~"date",
  "Latino",    243261,   291,      167.2,        as.Date("2021-01-12"),
  "Black",     138566,   260,      161.6,        NA,
  "White",     520628,   792,      80.3,         NA,
  "Asian",     63448,    38,       57.6,         NA,
  "Other",     1709,     24,       NA,           NA
  ) %>%    
  mutate(
    crude = deaths / pop * 1e5,
    deaths_pct = deaths / sum(deaths),
    pop_pct = pop / sum(pop),
    pretty_rate = pretty_frac(age_adjust / 1e5)
    )

message(paste0(Sys.time(), " -- Loading data"))

mun_bound <- read_rds(here("data/mun-boundary.rds"))
county_bound <- read_rds(here("data/county-boundary.rds"))
hotspot <- read_rds((here("data/nys-hotspot.rds")))
hosp_geo <- read_rds(here("data/hospital-locations.rds"))
nh_deaths <- read_rds(here("data/nh-deaths.rds"))

hosp_cap <- read_csv(here("data/hospital-beds-occupancy.csv"), col_types = cols())
mun_cases <- read_csv(here("data/by-mun-cases.csv"), col_types = cols())

nys_cases <- read_csv(here("data/by-county-cases-tests-nys.csv"), col_types = cols()) %>% 
  group_by(county) %>% 
  mutate(
    across(c(new_cases, total_cases, new_tests, total_tests), 
    list(
      "avg_7" = ~ slide_dbl(.x, mean, .before = 6, .complete = TRUE),
      "avg_14" = ~ slide_dbl(.x, mean, .before = 13, .complete = TRUE)
      )
    ),
    pos_rate_avg_7 = new_cases_avg_7 / new_tests_avg_7,
    pos_rate_avg_14 = new_cases_avg_14 / new_tests_avg_14
    ) %>% 
  ungroup()

nyt_cases <- read_csv(here("data/by-county-cases-deaths-nyt.csv"), col_types = cols()) %>% 
  group_by(county, state) %>% 
  mutate(
    across(where(is.numeric), 
    list(
      "avg_7" = ~ slide_dbl(.x, mean, .before = 6, .complete = TRUE),
      "avg_14" = ~ slide_dbl(.x, mean, .before = 13, .complete = TRUE)
      )
    )) %>% 
  ungroup() %>% 
  inner_join(select(county_bound, -fips), by = c("county", "state")) %>% 
  mutate(
    new_cases_per_cap = new_cases_avg_7 / total_pop * 1e5,
    tot_cases_per_cap = total_cases / total_pop,
    new_deaths_per_cap = new_deaths_avg_7 / total_pop * 1e5
    ) %>% 
  select(-geometry)
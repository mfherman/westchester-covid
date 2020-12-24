message(paste0(Sys.time(), " -- Loading data"))

mun_bound    <- read_sf(here("data/mun-poly.geojson"))
county_bound <- read_sf(here("data/county-poly.geojson"))
hotspot      <- read_sf(here("data/hotspot-poly.geojson"))
hosp_geo     <- read_sf(here("data/hospital-point.geojson"))
nh_geo       <- read_sf(here("data/nursing-home-point.geojson"))

hosp_cap     <- read_csv(here("data/hospital-beds-occupancy.csv"), col_types = cols())
mun_cases    <- read_csv(here("data/mun-cases.csv"), col_types = cols())
nh_deaths    <- read_csv(here("data/nursing-home-deaths.csv"), col_types = cols())

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
    across(
      where(is.numeric), 
      list("avg_7" = ~ slide_dbl(.x, mean, .before = 6, .complete = TRUE))
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

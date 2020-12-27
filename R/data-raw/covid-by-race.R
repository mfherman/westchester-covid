source(here::here("R/build/attach-packages.R"))

url_county <- "https://data.cdc.gov/resource/k8wy-p9cg.csv?fipscode=36119"
url_state <- "https://data.cdc.gov/resource/ks3g-spdg.csv?state=New%20York"

county <- read_csv(url_county, col_types = cols())
state <- read_csv(url_state, col_types = cols())
pop_age_race <- read_csv("data/wch-nys-pop-by-race-age.csv", col_types = cols())

wch_death_race <- county %>%
  filter(str_detect(indicator, "COVID")) %>% 
  mutate(across(where(is.POSIXt), as.Date)) %>% 
  select(
    date = end_week,
    covid_deaths = covid_19_deaths_total,
    White = non_hispanic_white,
    Black = non_hispanic_black,
    Asian = non_hispanic_asian,
    Latino = hispanic,
    Other = other
    ) %>% 
  pivot_longer(c(White:Other), names_to = "race") %>% 
  mutate(wch_deaths = covid_deaths * value) %>% 
  select(race, wch_deaths)

death_age_race <- state %>% 
  select(
    date = end_week,
    age_group = age_group_new,
    race = race_and_hispanic_origin,
    covid_deaths = covid_19_deaths
    ) %>% 
  filter(!age_group %in% c("0-17 years", "18-29 years", "30-49 years", "50-64 years")) %>% 
  mutate(across(where(is.POSIXt), as.Date)) %>% 
  replace_na(list(covid_deaths = 0)) %>% 
  mutate(
    race = case_when(
      race == "Hispanic" ~ "Latino",
      race == "Non-Hispanic Asian" ~ "Asian",
      race == "Non-Hispanic Black" ~ "Black",
      race == "Non-Hispanic White" ~ "White",
      TRUE ~ "Other"
      ),
    age_group = case_when(
      age_group %in% c("Under 1 year", "1-4 years") ~ "0-4 years",
      TRUE ~ age_group
      )
    ) %>%
  count(age_group, race, wt = covid_deaths, name = "nys_deaths") %>% 
  mutate(age_group = str_replace(paste("Age", age_group), "-", " to "))

calc <- pop_age_race %>% 
  left_join(death_age_race, by = c("race", "age_group")) %>% 
  mutate(
    nys_death_rate = nys_deaths / nys_pop,
    wch_expected_deaths = nys_death_rate * wch_pop
    )

amr_by_race <- calc %>% 
  group_by(race) %>% 
  summarize(across(c(nys_pop, nys_deaths, wch_expected_deaths, wch_pop), sum)) %>% 
  left_join(wch_death_race, by = "race") %>% 
  mutate(
    nys_crude = nys_deaths / nys_pop * 1e5,
    wch_crude = wch_deaths / wch_pop * 1e5,
    smr = wch_deaths / wch_expected_deaths,
    amr = smr * nys_crude
    )

amr_by_race %>% 
  mutate(race = fct_reorder(race, -amr)) %>% 
  ggplot(aes(race, amr)) +
  geom_col() +
  labs(
    x = NULL,
    y = "Deaths by 100K (age-adjusted)"
    ) +
  theme_minimal()

amr_all <- calc %>% 
  summarize(across(c(nys_pop, nys_deaths, wch_expected_deaths, wch_pop), sum)) %>% 
  mutate(
    wch_deaths = max(county$covid_19_deaths_total),
    nys_crude = nys_deaths / nys_pop * 1e5,
    wch_crude = wch_deaths / wch_pop * 1e5,
    smr = wch_deaths / wch_expected_deaths,
    amr = smr * nys_crude
    )


calll <- county %>% 
  mutate(
    across(where(is.POSIXt), as.Date),
    indicator = case_when(
      str_detect(indicator, "all") ~ "All deaths",
      str_detect(indicator, "COV") ~ "Covid-19 deaths",
      TRUE ~ "Total pop"
      )
    ) %>% 
  select(
    date = end_week,
    indicator,
    covid_deaths = covid_19_deaths_total,
    white = non_hispanic_white,
    black = non_hispanic_black,
    asian = non_hispanic_asian,
    hispanic,
    other
    ) %>% 
  pivot_longer(
    cols = c(white:other),
    names_to = "race",
    values_to = "pct"
  )





calll %>% 
  filter(indicator == "Covid-19 deaths")

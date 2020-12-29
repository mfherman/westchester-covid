library(tidycensus)
library(tidyverse)

wch_pop <- get_estimates(
  geography = "county",
  product = "characteristics",
  breakdown = c("RACE", "HISP", "AGEGROUP"),
  breakdown_labels = TRUE,
  year = 2019,
  state = "NY",
  county = "Westchester"
  )

wch_puma <- get_acs(
  geography = "puma",
  state = "NY",
  variables = "B01003_001"
  ) %>% 
  filter(str_detect(NAME, "Westchester"))

wch_pums <- get_pums(
  variables = c("AGEP", "RAC1P", "HISP"),
  state = "NY",
  puma = str_remove(wch_puma$GEOID, "36"),
  year = 2019,
  survey = "acs1",
  recode = TRUE
  )

med_age_by_race <- wch_pums %>%
  mutate(
    race_eth = case_when(
      HISP != "01" ~ "Latino",
      RAC1P == 1 ~ "White",
      RAC1P == 2 ~ "Black",
      RAC1P == 6 ~ "Asian",
      TRUE ~ "Other"
    )
  ) %>% 
  group_by(race_eth) %>% 
  summarize(med_age = spatstat::weighted.median(AGEP, PWGTP))

write_csv

nys_pop <- get_estimates(
  geography = "state",
  product = "characteristics",
  breakdown = c("RACE", "HISP", "AGEGROUP"),
  breakdown_labels = TRUE,
  year = 2019,
  state = "NY"
  )

wch_pop_race_age <- wch_pop %>% 
  filter(
    (HISP == "Hispanic" & RACE == "All races" & AGEGROUP != "All ages") | 
      (HISP == "Non-Hispanic" & RACE != "All races") &
      !str_detect(RACE, "or in") &
      AGEGROUP != "All ages"
    ) %>% 
  mutate(
    race = case_when(
      RACE == "White alone" ~ "White",
      RACE == "Black alone" ~ "Black",
      RACE == "Asian alone" ~ "Asian",
      RACE == "All races" ~ "Latino",
      TRUE ~ "Other"
    ),
    age_group = case_when(
      AGEGROUP == "Age 0 to 4 years" ~ "Age 0 to 4 years",
      AGEGROUP %in% c("Age 5 to 9 years", "Age 10 to 14 years") ~ "Age 5 to 14 years",
      AGEGROUP %in% c("Age 15 to 19 years", "Age 20 to 24 years") ~ "Age 15 to 24 years",
      AGEGROUP %in% c("Age 25 to 29 years", "Age 30 to 34 years") ~ "Age 25 to 34 years",
      AGEGROUP %in% c("Age 35 to 39 years", "Age 40 to 44 years") ~ "Age 35 to 44 years",
      AGEGROUP %in% c("Age 45 to 49 years", "Age 50 to 54 years") ~ "Age 45 to 54 years",
      AGEGROUP %in% c("Age 55 to 59 years", "Age 60 to 64 years") ~ "Age 55 to 64 years",
      AGEGROUP %in% c("Age 65 to 69 years", "Age 70 to 74 years") ~ "Age 65 to 74 years",
      AGEGROUP %in% c("Age 75 to 79 years", "Age 80 to 84 years") ~ "Age 75 to 84 years",
      AGEGROUP == "Age 85 years and older" ~ "Age 85 years and over"
      )
   ) %>% 
  count(race, age_group, wt = value, name = "wch_pop")


nys_pop_race_age <- nys_pop %>% 
  filter(
    (HISP == "Hispanic" & RACE == "All races" & str_starts(AGEGROUP, "Age")) | 
      (HISP == "Non-Hispanic" & RACE != "All races") &
      !str_detect(RACE, "or in") &
      str_starts(AGEGROUP, "Age")
    ) %>% 
  mutate(
    race = case_when(
      RACE == "White alone" ~ "White",
      RACE == "Black alone" ~ "Black",
      RACE == "Asian alone" ~ "Asian",
      RACE == "All races" ~ "Latino",
      TRUE ~ "Other"
    ),
    age_group = case_when(
      AGEGROUP == "Age 0 to 4 years" ~ "Age 0 to 4 years",
      AGEGROUP %in% c("Age 5 to 9 years", "Age 10 to 14 years") ~ "Age 5 to 14 years",
      AGEGROUP %in% c("Age 15 to 19 years", "Age 20 to 24 years") ~ "Age 15 to 24 years",
      AGEGROUP %in% c("Age 25 to 29 years", "Age 30 to 34 years") ~ "Age 25 to 34 years",
      AGEGROUP %in% c("Age 35 to 39 years", "Age 40 to 44 years") ~ "Age 35 to 44 years",
      AGEGROUP %in% c("Age 45 to 49 years", "Age 50 to 54 years") ~ "Age 45 to 54 years",
      AGEGROUP %in% c("Age 55 to 59 years", "Age 60 to 64 years") ~ "Age 55 to 64 years",
      AGEGROUP %in% c("Age 65 to 69 years", "Age 70 to 74 years") ~ "Age 65 to 74 years",
      AGEGROUP %in% c("Age 75 to 79 years", "Age 80 to 84 years") ~ "Age 75 to 84 years",
      AGEGROUP == "Age 85 years and older" ~ "Age 85 years and over",
      TRUE ~ as.character(AGEGROUP)
      )
   ) %>% 
  count(race, age_group, wt = value, name = "nys_pop")

nys_pop_race_age %>% 
  left_join(wch_pop_race_age, by = c("race", "age_group")) %>% 
  write_csv("data/wch-nys-pop-by-race-age.csv")


















all_race_age <- pop_race_age %>% 
  count(age_group, wt = n) %>% 
  mutate(pct_all_race = n / sum(n)) %>% 
  select(-n)

pop_race_age %>% 
  group_by(race) %>% 
  mutate(
    total = sum(n),
    pct = n / total
    ) %>% 
  ungroup() %>% 
  left_join(all_race_age, by = "age_group") %>% 
  mutate(weight = pct_all_race / pct) %>% 
  group_by(race) %>% 
  summarize(weight = sum(weight)) %>% 
  mutate(weight_adj = weight / sum(weight))

  




library(tidyverse)

age_race_nys <- read_csv("https://data.cdc.gov/resource/ks3g-spdg.csv?state=New%20York")













ageadjust.direct(pop_race_age$n[pop_race_age$race == "Asian"])



count

### Use average population as standard
standard<-apply(population[,-6], 1, mean)
standard

### This recreates Table 1 of Fay and Feuer, 1997
birth.order1<-ageadjust.direct(count[,1],population[,1],stdpop=standard)
round(10^5*birth.order1,1)

birth.order2<-ageadjust.direct(count[,2],population[,2],stdpop=standard)
round(10^5*birth.order2,1)

birth.order3<-ageadjust.direct(count[,3],population[,3],stdpop=standard)
round(10^5*birth.order3,1)

birth.order4<-ageadjust.direct(count[,4],population[,4],stdpop=standard)
round(10^5*birth.order4,1)

birth.order5p<-ageadjust.direct(count[,5],population[,5],stdpop=standard)
round(10^5*birth.order5p,1)



library(epitools)

get_acs(
  geography = "county",
  state = "NY",
  county = "Westchester",
  table = "B01001H"
  )




B01001H_001


wch_dem %>% 
  select(ends_with("E")) %>% 
  mutate(otherE = totalE - (whiteE + blackE + asianE + latinoE))



vars <- load_variables("2019", "acs1", cache = TRUE)

View(vars)

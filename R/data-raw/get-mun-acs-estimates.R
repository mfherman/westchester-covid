library(tidyverse)
library(tidycensus)

tract_mun <- read_csv("data/tract-mun-crosswalk.csv", col_types = "cc")

acs_vars <- load_variables("2019", "acs5", cache = TRUE)

variables <- c(
  "B01003_001",
  paste0("B01001_0", c(20:25, 44:49)),
  paste0("B25014_0", str_pad(c(1, 5:7, 11:13), 2, "left", "0")),
  paste0("B17026_0", str_pad(1:9, 2, "left", "0")),
  paste0("B03002_0", str_pad(c(4, 12), 2, "left", "0")),
  paste0("B15003_0", str_pad(1:18, 2, "left", "0"))
  )
  
tract_acs <- get_acs(
  geography = "tract",
  state = "NY",
  county = "Westchester",
  variables = variables,
  year = 2019,
  survey = "acs5",
  output = "wide"
  )

tract_acs_calc <- tract_acs %>% 
  transmute(
    GEOID,
    total_pop = B01003_001E,
    over_65   = B01001_020E + B01001_021E + B01001_022E + B01001_023E +
                B01001_024E + B01001_025E + B01001_044E + B01001_045E +
                B01001_046E + B01001_047E + B01001_048E + B01001_049E,
    crowded_d = B25014_001E,
    crowded   = B25014_005E + B25014_006E + B25014_007E + B25014_011E +
                B25014_012E + B25014_013E,
    poverty_d = B17026_001E,
    poverty   = B17026_002E + B17026_003E + B17026_004E + B17026_005E + 
                B17026_006E + B17026_007E + B17026_008E + B17026_009E,
    black_lat = B03002_004E + B03002_012E,
    educ_d    = B15003_001E,
    hs_less   = B15003_002E + B15003_003E + B15003_004E + B15003_005E +
                B15003_006E + B15003_007E + B15003_008E + B15003_009E +
                B15003_010E + B15003_011E + B15003_012E + B15003_013E +
                B15003_014E + B15003_015E + B15003_016E + B15003_017E +
                B15003_018E
       )

mun_acs <- tract_acs_calc %>% 
  left_join(tract_mun, by = "GEOID") %>% 
  group_by(municipality) %>% 
  summarize(across(where(is.numeric), sum), .groups = "drop") %>% 
  mutate(
    over_65_pct   = over_65 / total_pop,
    crowded_pct   = crowded / crowded_d,
    poverty_pct   = poverty / poverty_d,
    black_lat_pct = black_lat / total_pop,
    hs_less_pct   = hs_less / educ_d
  ) 

write_csv(mun_acs, "data/mun-acs-estimates.csv")

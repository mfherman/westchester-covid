library(tidyverse)
library(sf)
library(leaflet)

mun_sf <- read_rds("data/mun-boundary.rds")
mun_centroid <- mun_sf %>% 
  st_centroid()

mun_daily <- read_csv("data/by-mun-daily.csv")

recent_active <- mun_daily %>% 
  filter(date == max(date), metric == "active_cases") %>% 
  select(date, municipality, active_cases = n)

recent_total <- mun_daily %>% 
  filter(date == max(date), metric == "total_cases") %>% 
  select(date, municipality, total_cases = n)


mun_sf %>% 
  left_join(recent_active, by = "municipality") %>% 
  mutate(active_per_cap = active_cases / 14 / total_pop * 1e5) %>% 
  ggplot(aes(fill = active_per_cap)) +
  geom_sf() +
  scale_fill_distiller(palette = "YlOrBr", direction = 1)

mun_sf %>% 
  left_join(recent_total, by = "municipality") %>% 
  mutate(total_per_cap = total_cases / total_pop) %>% 
  ggplot(aes(fill = total_per_cap)) +
  geom_sf() +
  scale_fill_distiller(palette = "YlOrBr", direction = 1)

mun_centroid %>% 
  left_join(recent_total, by = "municipality") %>% 
  ggplot() +
  geom_sf(aes(size = total_cases)) +
  geom_sf(data = mun_sf, fill = "transparent")


mun_sf %>% 
  left_join(recent_active, by = "municipality") %>% 
  mutate(active_per_cap = active_cases / 14 / total_pop * 1e5) %>% 
  st_drop_geometry() %>%
  mutate(municipality = fct_reorder(municipality, active_per_cap)) %>% 
  ggplot(aes(active_per_cap, municipality, fill = active_per_cap)) +
  geom_col() +
  scale_fill_distiller(palette = "YlOrBr", direction = 1) +
  theme_minimal()

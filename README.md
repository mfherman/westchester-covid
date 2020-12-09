# Covid-19 in Westchester

This repository contains information about the Covid-19 pandemic in Westchester County, NY. The [Westchester County Department of Health website](https://health.westchestergov.com/2019-novel-coronavirus) does not contain much data or detailed information about the state of the pandemic in the county, so this repository and accompanying website (coming soon!) hopes to fill the gap.

## Daily case, death, and testing data

- [Cases by municipality (Westchester County)](data/by-mun-cases.csv)
- [Cases and deaths by county (New York Times)](data/by-county-cases-deaths-nyt.csv)
- [Cases and tests by county (New York State Department of Health)](data/by-county-cases-tests-nys.csv)

## About the data

Westchester County does not currently post historical data with the number of new cases per day by municipality. Because of this limitation, I have attempted to [extract this historical data](R/download-parse-map.R) from maps that are posted each weekday to the [WestchesterGov Twitter account](https://twitter.com/westchestergov/status/1336045976981811206). This extraction processes is imperfect but until the county releases more accurate historical data, this is best I can do. Starting on December 3, 2020, I began [scraping this data each day](R/download-mun-daily.R) from the [Westchester County website](https://westchestergov.com/covid-19-cases), which results in significantly more reliable data. As new data is posted, I will update the data file with the most recent data.

In addition to the data scraped from the county, I also download daily data for Westchester from the [New York Times](https://github.com/nytimes/covid-19-data) and the [New York State Department of Health](https://health.data.ny.gov/Health/New-York-State-Statewide-COVID-19-Testing/xdss-u53e). Each of these data sources reports data at the county-level only. New York Times data contains daily cases and deaths. New York State Department of Health data contains daily cases and daily tests.

## Coming Soon

In the coming weeks, I plan to develop a website to present this data with maps, charts, and tables.
# Covid-19 in Westchester

This repository contains information about the Covid-19 pandemic in Westchester County, NY. The [Westchester County Department of Health website](https://health.westchestergov.com/2019-novel-coronavirus) does not contain much data or detailed information about the state of the pandemic in the county, so this repository and accompanying website (coming soon!) hopes to fill the gap.

## About the data

Westchester County does not currently post historical data with the number of new cases per day by municipality. Because of this limitation, I have attempted to [extract this historical data](R/download-parse-map.R) from maps that are posted each weekday to the [WestchesterGov Twitter account](https://twitter.com/westchestergov/status/1336045976981811206). This extraction processes is imperfect but until the county releases more accurate historical data, this is best I can do. Starting on December 3, 2020, I began [scraping this data each day](R/scrape-mun-daily.R) from the [Westchester County website](https://westchestergov.com/covid-19-cases), which results in significantly more reliable data. As new data is posted, I will update the data file with the most recent data.

The current version of the number of cases by municipality by day can be found here: [`by-mun-daily.csv`](data/by-mun-daily.csv).

## Coming Soon

In the coming weeks, I plan to develop a website to present this data with maps, charts, and tables.
#!/bin/sh

Rscript "R/download-nys-cases-tests.R"
Rscript "R/download-nyt-cases-deaths.R"
Rscript "R/download-hotspot-zones.R"
Rscript "R/build-site.R"

git commit data/by-county-cases-deaths-nyt.csv data/by-county-cases-tests-nys.csv data/nys-hotspot.rds -m "update nyt and nys data"
git commit -am  "update site with fresh data"
git push

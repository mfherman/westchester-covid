#!/bin/sh

Rscript "R/download-nys-cases-tests.R"
Rscript "R/download-nyt-cases-deaths.R"
Rscript "R/build-site.R"

git commit data/by-county-cases-deaths-nyt.csv data/by-county-cases-tests-nys.csv -m "update nyt and nys data"
git push

git commit -am  "update site with fresh data"
git push
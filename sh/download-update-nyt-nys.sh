#!/bin/sh

Rscript "R/pull/pull-nys-cases-tests.R"
Rscript "R/pull/pull-nyt-cases-deaths.R"
Rscript "R/pull/pull-hotspot-zones.R"
Rscript "R/pull/pull-hospital-occupancy.R"
Rscript "R/pull/pull-nursing-home-deaths.R"
Rscript "R/pull/pull-school-cases.R"
#Rscript "R/pull/pull-cdc-vac.R"
#Rscript "R/pull/pull-nys-vac.R"
Rscript "R/build/build-site.R"

git commit -am  "update site with fresh data"
git push

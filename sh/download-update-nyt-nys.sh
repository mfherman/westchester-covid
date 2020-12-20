#!/bin/sh

Rscript "R/download-nys-cases-tests.R"
Rscript "R/download-nyt-cases-deaths.R"
Rscript "R/download-hotspot-zones.R"
Rscript "R/build-site.R"

git commit -am  "update site with fresh data"
git push

#!/bin/sh

Rscript "R/download-mun-cases.R"
Rscript "R/build-site.R"

git commit -am "update municipality data"
git push
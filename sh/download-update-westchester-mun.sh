#!/bin/sh

Rscript "R/pull/pull-mun-cases.R"
Rscript "R/build/build-site.R"

git commit -am "update municipality data"
git push

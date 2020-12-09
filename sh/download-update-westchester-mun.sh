#!/bin/sh

Rscript "R/download-mun-cases.R"

git commit data/by-mun-cases.csv -m "update municipality data"
git push
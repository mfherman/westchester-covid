library(fs)
library(rmarkdown)

# build site
render_site(input = "site/")

# move site to docs/
dir_copy(path = "site/docs", new_path = "docs/", overwrite = TRUE) 

# clean-up directories
dir_delete(path = "site/docs")

build_site <- function() {
  
  # build site
  rmarkdown::render_site(input = "site/")
  
  # move site to docs/
  fs::dir_copy(path = "site/docs", new_path = "docs/", overwrite = TRUE) 
  
  # clean-up directories
  fs::dir_delete(path = "site/docs")
}

build_site()

build_site <- function() {
  
  # build site
  rmarkdown::render_site(input = "site/")
  
  # move site to docs/
  fs::dir_copy(path = "site/docs/", new_path = "docs/", overwrite = TRUE) 
  
  # clean-up directories
  fs::dir_delete(path = "site/docs/")
  }

ggplotly_config <- function(x, ...) {
  plotly::ggplotly(x, tooltip = "text", ...) %>%
    layout(
      xaxis = list(fixedrange = TRUE),
      yaxis = list(fixedrange = TRUE),
      font = list(family = "IBM Plex Sans Condensed"),
      hoverlabel = list(font = list(family = "IBM Plex Sans Condensed"))
    ) %>%
    plotly::config(displayModeBar = FALSE)
  }

month_day_year <- function(x, abbr = FALSE) {
  if(all(lubridate::is.Date(x) || lubridate::is.POSIXt(x))) {
  glue::glue("{lubridate::month(x, label = TRUE, abbr = abbr)} {lubridate::day(x)}, {lubridate::year(x)}")
  } else
    stop("Input vector must be Date or POSIX format.")
  }

pretty_frac <- function(x, accuracy = 1) {
  paste("1 in", scales::number(1 / x, accuracy))
  }
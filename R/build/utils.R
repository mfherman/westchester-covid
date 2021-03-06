build_site <- function(quiet = FALSE) {
  
  # build site
  rmarkdown::render_site(input = "site/", quiet = quiet)
  
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
      hoverlabel = list(font = list(family = "IBM Plex Sans Condensed"), align = "left")
    ) %>%
    plotly::config(displayModeBar = FALSE)
  }

month_day_year <- function(x, abbr = FALSE) {
  if(all(lubridate::is.Date(x) || lubridate::is.POSIXt(x))) {
  glue::glue("{lubridate::month(x, label = TRUE, abbr = abbr)} {lubridate::day(x)}, {lubridate::year(x)}")
  } else
    stop("Input vector must be Date or POSIX format.")
  }

month_day_year <- function(x, abbr = FALSE) {
  if(all(lubridate::is.Date(x) || lubridate::is.POSIXt(x))) {
  glue::glue("{lubridate::month(x, label = TRUE, abbr = abbr)} {lubridate::day(x)}, {lubridate::year(x)}")
  } else
    stop("Input vector must be Date or POSIX format.")
  }

pretty_time <- function(x) {
  if(all(lubridate::is.POSIXt(x))) {
  paste(as.numeric(format(x, "%I")), format(x, "%M %p"), sep = ":")
  } else
    stop("Input vector must be POSIX format.")
  }


pretty_frac <- function(x, accuracy = 1) {
  paste("1 in", scales::comma(1 / x, accuracy))
  }

num_sign <- function(x, accuracy = NULL) {
  ifelse(
    x > 0,
    glue::glue("+{scales::comma(x, accuracy)}"),
    scales::comma(x, accuracy)
    )
  }

percent_sign <- function(x, accuracy = NULL) {
  ifelse(
    x > 0,
    glue::glue("+{scales::percent(x, accuracy)}"),
    scales::percent(x, accuracy)
    )
}

a_or_an <- function(x) {
  an <- c(8, 11, 18, 80:89)
  ifelse(x %in% an, "an", "a")
}

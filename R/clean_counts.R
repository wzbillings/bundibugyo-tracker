load_package <- function(package) {
  suppressPackageStartupMessages(
    suppressWarnings(
      library(package, character.only = TRUE)
    )
  )
}

load_package("dplyr")
load_package("lubridate")
load_package("readr")
load_package("stringr")

required_count_columns <- c(
  "source_name",
  "source_url",
  "publication_date",
  "data_cutoff_date",
  "country",
  "case_classification",
  "metric",
  "count_type",
  "count",
  "notes"
)

required_source_columns <- c(
  "source_id",
  "source_name",
  "title",
  "url",
  "publication_date",
  "retrieved_at",
  "source_type",
  "country",
  "keywords",
  "review_status",
  "notes"
)

required_news_columns <- c(
  "date",
  "source",
  "title",
  "url",
  "summary",
  "category",
  "is_official",
  "notes"
)

assert_required_columns <- function(data, required_columns) {
  missing_columns <- setdiff(required_columns, names(data))

  if (length(missing_columns) > 0) {
    stop(
      "Missing required columns: ",
      paste(missing_columns, collapse = ", "),
      call. = FALSE
    )
  }

  invisible(data)
}

standardize_country <- function(country) {
  normalized <- str_to_lower(str_trim(country))

  case_when(
    normalized %in% c("drc", "dr congo", "democratic republic of congo") ~
      "Democratic Republic of the Congo",
    normalized == "democratic republic of the congo" ~
      "Democratic Republic of the Congo",
    TRUE ~ str_squish(country)
  )
}

clean_counts <- function(data) {
  assert_required_columns(data, required_count_columns)

  data %>%
    mutate(
      source_name = str_squish(source_name),
      source_url = str_squish(source_url),
      publication_date = ymd(publication_date),
      data_cutoff_date = ymd(data_cutoff_date),
      country = standardize_country(country),
      case_classification = str_to_lower(str_squish(case_classification)),
      metric = str_to_lower(str_squish(metric)),
      count_type = str_to_lower(str_squish(count_type)),
      count = as.integer(count),
      notes = str_squish(notes)
    )
}

read_counts <- function(path = "data/outbreak_counts.csv") {
  clean_counts(read_csv(path, show_col_types = FALSE))
}

clean_source_log <- function(data) {
  assert_required_columns(data, required_source_columns)

  data %>%
    mutate(
      source_id = str_squish(source_id),
      source_name = str_squish(source_name),
      title = str_squish(title),
      url = str_squish(url),
      publication_date = ymd(publication_date),
      retrieved_at = ymd_hms(retrieved_at),
      source_type = str_to_lower(str_squish(source_type)),
      country = standardize_country(country),
      keywords = str_squish(keywords),
      review_status = str_to_lower(str_squish(review_status)),
      notes = str_squish(notes)
    )
}

read_source_log <- function(path = "data/source_log.csv") {
  clean_source_log(read_csv(path, show_col_types = FALSE))
}

clean_news_highlights <- function(data) {
  assert_required_columns(data, required_news_columns)

  data %>%
    mutate(
      date = ymd(date),
      source = str_squish(source),
      title = str_squish(title),
      url = str_squish(url),
      summary = str_squish(summary),
      category = str_to_lower(str_squish(category)),
      is_official = as.logical(is_official),
      notes = str_squish(notes)
    )
}

read_news_highlights <- function(path = "data/news_highlights.csv") {
  clean_news_highlights(read_csv(path, show_col_types = FALSE))
}

source_local <- function(path) {
  if (file.exists(path)) {
    suppressPackageStartupMessages(source(path))
    return(invisible(TRUE))
  }

  command_file <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1])
  if (!is.na(command_file)) {
    alternate_path <- file.path(dirname(command_file), basename(path))
    if (file.exists(alternate_path)) {
      suppressPackageStartupMessages(source(alternate_path))
      return(invisible(TRUE))
    }
  }

  invisible(FALSE)
}

if (!exists("clean_counts", mode = "function")) {
  source_local(file.path("R", "clean_counts.R"))
}

if (!exists("make_epicurve_data", mode = "function")) {
  source_local(file.path("R", "make_epicurve_data.R"))
}

add_message <- function(messages, message) {
  c(messages, message)
}

parse_count_values <- function(counts) {
  if (is.integer(counts)) {
    return(counts)
  }

  if (is.numeric(counts)) {
    return(counts)
  }

  suppressWarnings(as.numeric(trimws(as.character(counts))))
}

is_http_url <- function(values) {
  grepl("^https?://[^[:space:]]+$", values)
}

validate_url_values <- function(values, label) {
  errors <- character()
  trimmed <- trimws(as.character(values))

  if (any(is.na(trimmed) | trimmed == "")) {
    errors <- add_message(errors, paste("Missing", label, "values"))
  }
  if (any(!is.na(trimmed) & trimmed != "" & !is_http_url(trimmed))) {
    errors <- add_message(errors, paste("Invalid", label, "values"))
  }
  if (any(grepl("^https?://example\\.org", trimmed))) {
    errors <- add_message(errors, paste("Sample", label, "values"))
  }

  errors
}

validate_counts_data <- function(data) {
  errors <- character()
  warnings <- character()

  required_columns <- if (exists("required_count_columns")) {
    required_count_columns
  } else {
    c(
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
  }

  missing_columns <- setdiff(required_columns, names(data))
  if (length(missing_columns) > 0) {
    errors <- add_message(
      errors,
      paste("Missing required columns:", paste(missing_columns, collapse = ", "))
    )
  }

  if (all(c("publication_date", "data_cutoff_date") %in% names(data))) {
    publication_dates <- suppressWarnings(lubridate::ymd(data$publication_date))
    cutoff_dates <- suppressWarnings(lubridate::ymd(data$data_cutoff_date))

    invalid_publication_dates <- is.na(publication_dates) & !is.na(data$publication_date)
    invalid_cutoff_dates <- is.na(cutoff_dates) & !is.na(data$data_cutoff_date)

    if (any(invalid_publication_dates)) {
      errors <- add_message(errors, "Invalid publication_date values")
    }
    if (any(invalid_cutoff_dates)) {
      errors <- add_message(errors, "Invalid data_cutoff_date values")
    }

    valid_date_pairs <- !is.na(publication_dates) & !is.na(cutoff_dates)
    if (any(valid_date_pairs & publication_dates < cutoff_dates)) {
      errors <- add_message(errors, "publication_date before data_cutoff_date")
    }
  }

  if ("count" %in% names(data)) {
    parsed_counts <- parse_count_values(data$count)
    invalid_counts <- is.na(parsed_counts) |
      !is.finite(parsed_counts) |
      parsed_counts < 0 |
      parsed_counts != floor(parsed_counts)

    if (any(invalid_counts)) {
      errors <- add_message(errors, "Invalid count values")
    }
  }

  if ("source_url" %in% names(data)) {
    errors <- c(errors, validate_url_values(data$source_url, "source_url"))
  }

  if ("case_classification" %in% names(data)) {
    classifications <- tolower(trimws(data$case_classification))
    invalid_classifications <- is.na(classifications) |
      !(classifications %in% c("suspected", "probable", "confirmed", "all"))
    if (any(invalid_classifications)) {
      errors <- add_message(errors, "Invalid case_classification values")
    }
  }

  if ("metric" %in% names(data)) {
    metrics <- tolower(trimws(data$metric))
    invalid_metrics <- is.na(metrics) | !(metrics %in% c("cases", "deaths"))
    if (any(invalid_metrics)) {
      errors <- add_message(errors, "Invalid metric values")
    }
  }

  if ("count_type" %in% names(data)) {
    count_types <- tolower(trimws(data$count_type))
    invalid_count_types <- is.na(count_types) | !(count_types %in% c("cumulative", "incident"))
    if (any(invalid_count_types)) {
      errors <- add_message(errors, "Invalid count_type values")
    }
  }

  if (any(duplicated(data))) {
    errors <- add_message(errors, "Duplicate full rows")
  }

  strata_columns <- c(
    "source_name",
    "country",
    "case_classification",
    "metric",
    "data_cutoff_date"
  )
  if (all(strata_columns %in% names(data))) {
    duplicate_strata <- duplicated(data[strata_columns])
    if (any(duplicate_strata)) {
      errors <- add_message(
        errors,
        "Duplicate source/country/classification/metric/cutoff combinations"
      )
    }
  }

  if (
    all(required_columns %in% names(data)) &&
      exists("clean_counts", mode = "function") &&
      exists("make_epicurve_data", mode = "function")
  ) {
    epicurve_data <- tryCatch(
      suppressWarnings(make_epicurve_data(clean_counts(data))),
      error = function(error) NULL
    )

    if (!is.null(epicurve_data) && any(epicurve_data$negative_increment, na.rm = TRUE)) {
      warnings <- add_message(warnings, "Negative derived increments detected")
    }
  }

  list(errors = errors, warnings = warnings)
}

validate_source_log_data <- function(data) {
  errors <- character()

  required_columns <- if (exists("required_source_columns")) {
    required_source_columns
  } else {
    c("source_id", "source_name", "title", "url", "publication_date", "retrieved_at",
      "source_type", "country", "keywords", "review_status", "notes")
  }

  missing_columns <- setdiff(required_columns, names(data))
  if (length(missing_columns) > 0) {
    errors <- add_message(errors, paste("Missing required source_log columns:", paste(missing_columns, collapse = ", ")))
    return(list(errors = errors, warnings = character()))
  }

  errors <- c(errors, validate_url_values(data$url, "source_log url"))

  publication_dates <- suppressWarnings(lubridate::ymd(data$publication_date))
  retrieved_at <- suppressWarnings(lubridate::ymd_hms(data$retrieved_at))

  if (any(is.na(publication_dates) & !is.na(data$publication_date))) {
    errors <- add_message(errors, "Invalid source_log publication_date values")
  }
  if (any(is.na(retrieved_at) & !is.na(data$retrieved_at))) {
    errors <- add_message(errors, "Invalid source_log retrieved_at values")
  }

  review_status <- tolower(trimws(data$review_status))
  if (any(is.na(review_status) | !(review_status %in% c("queued", "reviewed", "extracted", "rejected")))) {
    errors <- add_message(errors, "Invalid source_log review_status values")
  }

  if (any(duplicated(data$source_id))) {
    errors <- add_message(errors, "Duplicate source_log source_id values")
  }
  if (any(duplicated(data$url))) {
    errors <- add_message(errors, "Duplicate source_log url values")
  }

  list(errors = errors, warnings = character())
}

validate_news_highlights_data <- function(data) {
  errors <- character()

  required_columns <- if (exists("required_news_columns")) {
    required_news_columns
  } else {
    c("date", "source", "title", "url", "summary", "category", "is_official", "notes")
  }

  missing_columns <- setdiff(required_columns, names(data))
  if (length(missing_columns) > 0) {
    errors <- add_message(errors, paste("Missing required news_highlights columns:", paste(missing_columns, collapse = ", ")))
    return(list(errors = errors, warnings = character()))
  }

  errors <- c(errors, validate_url_values(data$url, "news_highlights url"))

  dates <- suppressWarnings(lubridate::ymd(data$date))
  if (any(is.na(dates) & !is.na(data$date))) {
    errors <- add_message(errors, "Invalid news_highlights date values")
  }

  categories <- tolower(trimws(data$category))
  if (any(is.na(categories) | !(categories %in% c("epidemiology", "response", "policy", "operations", "context")))) {
    errors <- add_message(errors, "Invalid news_highlights category values")
  }

  official <- tolower(trimws(as.character(data$is_official)))
  if (any(is.na(official) | !(official %in% c("true", "false")))) {
    errors <- add_message(errors, "Invalid news_highlights is_official values")
  }

  list(errors = errors, warnings = character())
}

combine_validation_results <- function(results) {
  list(
    errors = unlist(lapply(results, `[[`, "errors"), use.names = FALSE),
    warnings = unlist(lapply(results, `[[`, "warnings"), use.names = FALSE)
  )
}

validate_all_data <- function(counts, source_log, news_highlights) {
  result <- combine_validation_results(list(
    validate_counts_data(counts),
    validate_source_log_data(source_log),
    validate_news_highlights_data(news_highlights)
  ))

  if (all(c("source_url") %in% names(counts)) && "url" %in% names(source_log)) {
    missing_count_urls <- setdiff(unique(counts$source_url), unique(source_log$url))
    if (length(missing_count_urls) > 0) {
      result$errors <- add_message(result$errors, "count source_url values missing from source_log")
    }
  }

  result
}

run_validation <- function(
  counts_path = "data/outbreak_counts.csv",
  source_log_path = "data/source_log.csv",
  news_highlights_path = "data/news_highlights.csv"
) {
  counts <- readr::read_csv(counts_path, show_col_types = FALSE)
  source_log <- readr::read_csv(source_log_path, show_col_types = FALSE)
  news_highlights <- readr::read_csv(news_highlights_path, show_col_types = FALSE)

  result <- validate_all_data(counts, source_log, news_highlights)

  for (warning in result$warnings) {
    message("WARNING: ", warning)
  }
  for (error in result$errors) {
    message("ERROR: ", error)
  }

  if (length(result$errors) > 0) {
    quit(status = 1)
  }

  message("Validation passed")
  invisible(result)
}

is_cli_run <- function() {
  command_file <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1])
  !is.na(command_file) && basename(command_file) == "validate_counts.R"
}

if (is_cli_run()) {
  run_validation()
}

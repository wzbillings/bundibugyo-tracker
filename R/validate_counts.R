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
  grepl(
    "^https?://([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z]{2,}(:[0-9]+)?([/?#][^[:space:]]*)?$",
    values,
    ignore.case = TRUE
  )
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
  if (any(grepl("^https?://(www\\.)?example\\.org([/:?#]|$)", trimmed, ignore.case = TRUE))) {
    errors <- add_message(errors, paste("Sample", label, "values"))
  }

  errors
}

is_missing_value <- function(values) {
  trimmed <- trimws(as.character(values))
  is.na(values) | is.na(trimmed) | trimmed == ""
}

normalize_url_value <- function(values) {
  trimws(as.character(values))
}

normalize_text_value <- function(values) {
  gsub("[[:space:]]+", " ", trimws(as.character(values)))
}

source_reference_key <- function(source_name, source_url) {
  paste(normalize_text_value(source_name), normalize_url_value(source_url), sep = "\r")
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

    missing_publication_dates <- is_missing_value(data$publication_date)
    missing_cutoff_dates <- is_missing_value(data$data_cutoff_date)
    invalid_publication_dates <- is.na(publication_dates) & !missing_publication_dates
    invalid_cutoff_dates <- is.na(cutoff_dates) & !missing_cutoff_dates

    if (any(missing_publication_dates)) {
      errors <- add_message(errors, "Missing publication_date values")
    }
    if (any(missing_cutoff_dates)) {
      errors <- add_message(errors, "Missing data_cutoff_date values")
    }
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
  missing_publication_dates <- is_missing_value(data$publication_date)
  missing_retrieved_at <- is_missing_value(data$retrieved_at)

  if (any(missing_publication_dates)) {
    errors <- add_message(errors, "Missing source_log publication_date values")
  }
  if (any(missing_retrieved_at)) {
    errors <- add_message(errors, "Missing source_log retrieved_at values")
  }
  if (any(is.na(publication_dates) & !missing_publication_dates)) {
    errors <- add_message(errors, "Invalid source_log publication_date values")
  }
  if (any(is.na(retrieved_at) & !missing_retrieved_at)) {
    errors <- add_message(errors, "Invalid source_log retrieved_at values")
  }

  review_status <- tolower(trimws(data$review_status))
  if (any(is.na(review_status) | !(review_status %in% c("queued", "reviewed", "extracted", "rejected")))) {
    errors <- add_message(errors, "Invalid source_log review_status values")
  }

  if (any(duplicated(data$source_id))) {
    errors <- add_message(errors, "Duplicate source_log source_id values")
  }
  normalized_urls <- normalize_url_value(data$url)
  normalized_urls <- normalized_urls[!is.na(normalized_urls) & normalized_urls != ""]
  if (any(duplicated(normalized_urls))) {
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
  missing_dates <- is_missing_value(data$date)
  if (any(missing_dates)) {
    errors <- add_message(errors, "Missing news_highlights date values")
  }
  if (any(is.na(dates) & !missing_dates)) {
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

validate_source_candidates_data <- function(data) {
  errors <- character()

  required_columns <- if (exists("required_candidate_columns")) {
    required_candidate_columns
  } else {
    c(
      "candidate_id",
      "discovered_at",
      "source_name",
      "title",
      "url",
      "publication_date",
      "source_type",
      "country",
      "keywords",
      "discovery_method",
      "review_status",
      "review_notes",
      "reviewed_at",
      "promoted_source_id"
    )
  }

  missing_columns <- setdiff(required_columns, names(data))
  if (length(missing_columns) > 0) {
    errors <- add_message(
      errors,
      paste(
        "Missing required source_candidates columns:",
        paste(missing_columns, collapse = ", ")
      )
    )
    return(list(errors = errors, warnings = character()))
  }

  candidate_ids <- normalize_text_value(data$candidate_id)
  missing_candidate_ids <- is.na(candidate_ids) | candidate_ids == ""
  if (any(missing_candidate_ids)) {
    errors <- add_message(errors, "Missing source_candidates candidate_id values")
  }
  if (any(duplicated(candidate_ids[!missing_candidate_ids]))) {
    errors <- add_message(errors, "Duplicate source_candidates candidate_id values")
  }

  errors <- c(errors, validate_url_values(data$url, "source_candidates url"))

  discovered_at <- suppressWarnings(lubridate::ymd_hms(data$discovered_at))
  publication_dates <- suppressWarnings(lubridate::ymd(data$publication_date))
  reviewed_at <- suppressWarnings(lubridate::ymd_hms(data$reviewed_at))

  missing_discovered_at <- is_missing_value(data$discovered_at)
  missing_publication_dates <- is_missing_value(data$publication_date)
  missing_reviewed_at <- is_missing_value(data$reviewed_at)

  if (any(missing_discovered_at)) {
    errors <- add_message(errors, "Missing source_candidates discovered_at values")
  }
  if (any(is.na(discovered_at) & !missing_discovered_at)) {
    errors <- add_message(errors, "Invalid source_candidates discovered_at values")
  }
  if (any(is.na(publication_dates) & !missing_publication_dates)) {
    errors <- add_message(errors, "Invalid source_candidates publication_date values")
  }
  if (any(is.na(reviewed_at) & !missing_reviewed_at)) {
    errors <- add_message(errors, "Invalid source_candidates reviewed_at values")
  }

  review_status <- tolower(trimws(data$review_status))
  valid_statuses <- c("queued", "reviewed", "promoted", "rejected", "deferred")
  if (any(is.na(review_status) | !(review_status %in% valid_statuses))) {
    errors <- add_message(errors, "Invalid source_candidates review_status values")
  }

  normalized_urls <- normalize_url_value(data$url)
  normalized_urls <- normalized_urls[!is.na(normalized_urls) & normalized_urls != ""]
  if (any(duplicated(normalized_urls))) {
    errors <- add_message(errors, "Duplicate source_candidates url values")
  }

  promoted_source_id <- normalize_text_value(data$promoted_source_id)
  promoted_source_id_missing <- is.na(promoted_source_id) | promoted_source_id == ""

  reviewed_rows <- !is.na(review_status) & review_status %in% c("reviewed", "rejected", "deferred")
  if (any(reviewed_rows & missing_reviewed_at, na.rm = TRUE)) {
    errors <- add_message(
      errors,
      "Reviewed, rejected, and deferred candidates require reviewed_at"
    )
  }

  promoted_rows <- !is.na(review_status) & review_status == "promoted"
  if (any(promoted_rows & missing_reviewed_at, na.rm = TRUE)) {
    errors <- add_message(errors, "Promoted candidates require reviewed_at")
  }
  if (any(promoted_rows & promoted_source_id_missing, na.rm = TRUE)) {
    errors <- add_message(errors, "Promoted candidates require promoted_source_id")
  }

  non_promoted_rows <- !is.na(review_status) & review_status != "promoted"
  if (any(non_promoted_rows & !promoted_source_id_missing, na.rm = TRUE)) {
    errors <- add_message(errors, "Only promoted candidates may set promoted_source_id")
  }

  queued_rows <- !is.na(review_status) & review_status == "queued"
  if (any(queued_rows & !missing_reviewed_at, na.rm = TRUE)) {
    errors <- add_message(errors, "Queued candidates must leave reviewed_at blank")
  }

  list(errors = errors, warnings = character())
}

combine_validation_results <- function(results) {
  list(
    errors = unlist(lapply(results, `[[`, "errors"), use.names = FALSE),
    warnings = unlist(lapply(results, `[[`, "warnings"), use.names = FALSE)
  )
}

validate_all_data <- function(counts, source_log, news_highlights, source_candidates = NULL) {
  results <- list(
    validate_counts_data(counts),
    validate_source_log_data(source_log),
    validate_news_highlights_data(news_highlights)
  )
  if (!is.null(source_candidates)) {
    results <- c(results, list(validate_source_candidates_data(source_candidates)))
  }

  result <- combine_validation_results(results)

  if (all(c("source_name", "source_url") %in% names(counts)) && all(c("source_name", "url") %in% names(source_log))) {
    count_source_names <- normalize_text_value(counts$source_name)
    count_urls <- normalize_url_value(counts$source_url)
    source_log_names <- normalize_text_value(source_log$source_name)
    source_log_urls <- normalize_url_value(source_log$url)

    missing_count_source_name <- is.na(count_source_names) | count_source_names == ""
    missing_count_source_url <- is.na(count_urls) | count_urls == ""

    if (any(missing_count_source_name)) {
      result$errors <- add_message(result$errors, "counts contains missing or blank source_name")
    }
    if (any(missing_count_source_url)) {
      result$errors <- add_message(result$errors, "counts contains missing or blank source_url")
    }

    valid_count_pairs <- !missing_count_source_name & !missing_count_source_url
    valid_source_pairs <- !is.na(source_log_names) &
      source_log_names != "" &
      !is.na(source_log_urls) &
      source_log_urls != ""

    count_keys <- unique(source_reference_key(
      count_source_names[valid_count_pairs],
      count_urls[valid_count_pairs]
    ))
    source_keys <- unique(source_reference_key(
      source_log_names[valid_source_pairs],
      source_log_urls[valid_source_pairs]
    ))

    missing_count_pairs <- setdiff(count_keys, source_keys)
    if (length(missing_count_pairs) > 0) {
      result$errors <- add_message(result$errors, "count source_name/source_url pairs missing from source_log")
    }
  }

  result
}

run_validation <- function(
  counts_path = "data/outbreak_counts.csv",
  source_log_path = "data/source_log.csv",
  news_highlights_path = "data/news_highlights.csv",
  source_candidates_path = "data/source_candidates.csv"
) {
  counts <- readr::read_csv(counts_path, show_col_types = FALSE)
  source_log <- readr::read_csv(source_log_path, show_col_types = FALSE)
  news_highlights <- readr::read_csv(news_highlights_path, show_col_types = FALSE)
  source_candidates <- readr::read_csv(source_candidates_path, show_col_types = FALSE)

  result <- validate_all_data(counts, source_log, news_highlights, source_candidates)

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

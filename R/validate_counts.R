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
    missing_urls <- is.na(data$source_url) | trimws(data$source_url) == ""
    if (any(missing_urls)) {
      errors <- add_message(errors, "Missing source_url values")
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

run_validation <- function(path = "data/outbreak_counts.csv") {
  data <- readr::read_csv(path, show_col_types = FALSE)
  result <- validate_counts_data(data)

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

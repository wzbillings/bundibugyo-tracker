source_path <- function(path) {
  if (file.exists(path)) {
    source(path)
  } else {
    source(file.path("..", "..", path))
  }
}

source_path(file.path("R", "clean_counts.R"))
source_path(file.path("R", "make_epicurve_data.R"))
source_path(file.path("R", "validate_counts.R"))

valid_counts_fixture <- function() {
  data.frame(
    source_name = c("WHO", "WHO"),
    source_url = "https://example.org/report",
    publication_date = c("2026-02-02", "2026-02-05"),
    data_cutoff_date = c("2026-02-01", "2026-02-04"),
    country = "DRC",
    case_classification = "confirmed",
    metric = "cases",
    count_type = "cumulative",
    count = c(2, 5),
    notes = "sample",
    stringsAsFactors = FALSE
  )
}

test_that("validate_counts_data returns no errors for valid data", {
  result <- validate_counts_data(valid_counts_fixture())

  expect_equal(result$errors, character())
})

test_that("validate_counts_data flags invalid count type and missing url", {
  input <- valid_counts_fixture()
  input$count_type[1] <- "weekly"
  input$source_url[2] <- ""

  result <- validate_counts_data(input)

  expect_true(any(grepl("Invalid count_type", result$errors)))
  expect_true(any(grepl("Missing source_url", result$errors)))
})

test_that("validate_counts_data flags duplicate strata per cutoff", {
  input <- rbind(valid_counts_fixture(), valid_counts_fixture()[1, ])

  result <- validate_counts_data(input)

  expect_true(any(grepl("Duplicate source/country/classification/metric/cutoff", result$errors)))
})

test_that("validate_counts_data warns on negative derived increments", {
  input <- valid_counts_fixture()
  input$count[2] <- 1

  result <- validate_counts_data(input)

  expect_true(any(grepl("Negative derived increments", result$warnings)))
})

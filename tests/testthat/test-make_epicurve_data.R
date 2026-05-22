source("../../R/clean_counts.R")
source("../../R/make_epicurve_data.R")

test_that("make_epicurve_data differences cumulative counts by source and strata", {
  input <- data.frame(
    source_name = c("WHO", "WHO", "WHO"),
    source_url = "https://example.org/report",
    publication_date = c("2026-02-02", "2026-02-05", "2026-02-08"),
    data_cutoff_date = c("2026-02-01", "2026-02-04", "2026-02-07"),
    country = "DRC",
    case_classification = "confirmed",
    metric = "cases",
    count_type = "cumulative",
    count = c(2, 5, 9),
    notes = "sample",
    stringsAsFactors = FALSE
  )

  result <- input %>%
    clean_counts() %>%
    make_epicurve_data()

  expect_equal(result$reported_increment, c(2L, 3L, 4L))
  expect_false(any(result$missing_previous_report))
  expect_false(any(result$negative_increment))
})

test_that("make_epicurve_data preserves gaps and flags negative increments", {
  input <- data.frame(
    source_name = c("WHO", "WHO"),
    source_url = "https://example.org/report",
    publication_date = c("2026-02-02", "2026-02-10"),
    data_cutoff_date = c("2026-02-01", "2026-02-09"),
    country = "DRC",
    case_classification = "suspected",
    metric = "cases",
    count_type = "cumulative",
    count = c(10, 8),
    notes = "sample",
    stringsAsFactors = FALSE
  )

  result <- input %>%
    clean_counts() %>%
    make_epicurve_data()

  expect_equal(nrow(result), 2)
  expect_equal(result$reported_increment, c(10L, -2L))
  expect_equal(result$days_since_previous_report, c(NA_integer_, 8L))
  expect_true(result$negative_increment[2])
})

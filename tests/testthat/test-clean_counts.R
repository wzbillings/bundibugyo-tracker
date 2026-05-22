source(file.path("..", "..", "R", "clean_counts.R"))

test_that("clean_counts parses and normalizes core fields", {
  input <- data.frame(
    source_name = " WHO AFRO ",
    source_url = "https://example.org/report",
    publication_date = "2026-02-02",
    data_cutoff_date = "2026-02-01",
    country = "drc",
    case_classification = " Confirmed ",
    metric = " Cases ",
    count_type = " Cumulative ",
    count = "4",
    notes = "sample",
    stringsAsFactors = FALSE
  )

  result <- clean_counts(input)

  expect_s3_class(result$publication_date, "Date")
  expect_s3_class(result$data_cutoff_date, "Date")
  expect_equal(result$country, "Democratic Republic of the Congo")
  expect_equal(result$case_classification, "confirmed")
  expect_equal(result$metric, "cases")
  expect_equal(result$count_type, "cumulative")
  expect_type(result$count, "integer")
  expect_equal(result$count, 4L)
})

test_that("clean_counts requires the minimum schema", {
  input <- data.frame(source_name = "WHO AFRO")

  expect_error(
    clean_counts(input),
    "Missing required columns"
  )
})

test_that("clean_source_log and clean_news_highlights parse dates", {
  source_log <- data.frame(
    source_id = "src-1",
    source_name = "WHO AFRO",
    title = "Report",
    url = "https://example.org/report",
    publication_date = "2026-02-02",
    retrieved_at = "2026-05-22T12:00:00Z",
    source_type = "situation_report",
    country = "DRC",
    keywords = "Ebola",
    review_status = "reviewed",
    notes = "sample",
    stringsAsFactors = FALSE
  )
  news <- data.frame(
    date = "2026-02-02",
    source = "WHO AFRO",
    title = "Report",
    url = "https://example.org/report",
    summary = "Summary",
    category = "epidemiology",
    is_official = "TRUE",
    notes = "sample",
    stringsAsFactors = FALSE
  )

  expect_s3_class(clean_source_log(source_log)$publication_date, "Date")
  expect_s3_class(clean_news_highlights(news)$date, "Date")
  expect_true(clean_news_highlights(news)$is_official)
})

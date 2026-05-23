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
    source_url = "https://www.who.int/example-report",
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

valid_source_log_fixture <- function(url = "https://www.who.int/example-report") {
  data.frame(
    source_id = "src-1",
    source_name = "WHO",
    title = "Report",
    url = url,
    publication_date = "2026-02-02",
    retrieved_at = "2026-05-22T12:00:00Z",
    source_type = "disease_outbreak_news",
    country = "DRC",
    keywords = "Ebola",
    review_status = "reviewed",
    notes = "sample",
    stringsAsFactors = FALSE
  )
}

valid_news_fixture <- function(url = "https://www.who.int/news-highlight") {
  data.frame(
    date = "2026-02-02",
    source = "WHO",
    title = "Report",
    url = url,
    summary = "Summary",
    category = "epidemiology",
    is_official = "TRUE",
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

test_that("validate_counts_data flags sample and malformed urls", {
  input <- valid_counts_fixture()
  input$source_url[1] <- "https://example.org/report"
  input$source_url[2] <- "not-a-url"

  result <- validate_counts_data(input)

  expect_true(any(grepl("Sample source_url", result$errors)))
  expect_true(any(grepl("Invalid source_url", result$errors)))
})

test_that("validate_counts_data flags invalid categories and date ordering", {
  input <- valid_counts_fixture()
  input$publication_date[1] <- "2026-02-01"
  input$data_cutoff_date[1] <- "2026-02-02"
  input$case_classification[2] <- "possible"
  input$metric[2] <- "hospitalizations"

  result <- validate_counts_data(input)

  expect_true(any(grepl("publication_date before data_cutoff_date", result$errors)))
  expect_true(any(grepl("Invalid case_classification", result$errors)))
  expect_true(any(grepl("Invalid metric", result$errors)))
})

test_that("validate_counts_data flags missing required dates", {
  input <- valid_counts_fixture()
  input$publication_date[1] <- NA
  input$data_cutoff_date[2] <- ""

  result <- validate_counts_data(input)

  expect_true(any(grepl("Missing publication_date", result$errors)))
  expect_true(any(grepl("Missing data_cutoff_date", result$errors)))
})

test_that("validate_all_data flags count urls missing from source log", {
  counts <- valid_counts_fixture()
  source_log <- valid_source_log_fixture("https://www.who.int/different-report")
  news <- valid_news_fixture()

  result <- validate_all_data(counts, source_log, news)

  expect_true(any(grepl("count source_url values missing from source_log", result$errors)))
})

test_that("validate_all_data accepts matching count urls from source log", {
  result <- validate_all_data(
    valid_counts_fixture(),
    valid_source_log_fixture(),
    valid_news_fixture()
  )

  expect_false(any(grepl("count source_url values missing from source_log", result$errors)))
})

test_that("validate_all_data matches count urls with surrounding whitespace", {
  counts <- valid_counts_fixture()
  counts$source_url <- paste0("  ", counts$source_url, "  ")

  result <- validate_all_data(
    counts,
    valid_source_log_fixture(),
    valid_news_fixture()
  )

  expect_false(any(grepl("count source_url values missing from source_log", result$errors)))
})

test_that("validate_all_data ignores blank count urls in source log membership", {
  counts <- valid_counts_fixture()
  counts$source_url[1] <- ""

  result <- validate_all_data(
    counts,
    valid_source_log_fixture(),
    valid_news_fixture()
  )

  expect_true(any(grepl("Missing source_url", result$errors)))
  expect_false(any(grepl("count source_url values missing from source_log", result$errors)))
})

test_that("validate_counts_data rejects malformed http-looking urls", {
  input <- valid_counts_fixture()
  input$source_url[1] <- "https://?"

  result <- validate_counts_data(input)

  expect_true(any(grepl("Invalid source_url", result$errors)))
})

test_that("validate_counts_data flags example.org sample urls case-insensitively", {
  input <- valid_counts_fixture()
  input$source_url[1] <- "HTTPS://WWW.EXAMPLE.ORG/report"

  result <- validate_counts_data(input)

  expect_true(any(grepl("Sample source_url", result$errors)))
})

test_that("source log and news highlight validators flag invalid fields", {
  source_log <- valid_source_log_fixture()
  source_log$review_status <- "pending"
  news <- valid_news_fixture()
  news$category <- "fundraising"

  source_result <- validate_source_log_data(source_log)
  news_result <- validate_news_highlights_data(news)

  expect_true(any(grepl("Invalid source_log review_status", source_result$errors)))
  expect_true(any(grepl("Invalid news_highlights category", news_result$errors)))
})

test_that("source log and news highlight validators flag missing required dates", {
  source_log <- valid_source_log_fixture()
  source_log$publication_date <- ""
  source_log$retrieved_at <- NA
  news <- valid_news_fixture()
  news$date <- ""

  source_result <- validate_source_log_data(source_log)
  news_result <- validate_news_highlights_data(news)

  expect_true(any(grepl("Missing source_log publication_date", source_result$errors)))
  expect_true(any(grepl("Missing source_log retrieved_at", source_result$errors)))
  expect_true(any(grepl("Missing news_highlights date", news_result$errors)))
})

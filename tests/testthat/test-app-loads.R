library(testthat)

test_that("app.R can be sourced without constructing invalid objects", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  expect_no_error(source("app.R", local = new.env(parent = globalenv())))
})

test_that("app.R exposes table link helper", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  expect_true(exists("format_link", envir = env))
  expect_match(env$format_link("https://example.org/report"), "<a href=")
})

test_that("app.R exposes public disclaimer helpers", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  expect_true(exists("full_disclaimer_url", envir = env))
  expect_identical(
    env$full_disclaimer_url,
    "https://github.com/wzbillings/bundibugyo-tracker#disclaimer"
  )
  expect_true(exists("public_disclaimer_html", envir = env))
  expect_match(
    as.character(env$public_disclaimer_html()),
    "Unofficial exploratory dashboard; verify all information against original and official sources before use.",
    fixed = TRUE
  )
  expect_match(
    as.character(env$public_disclaimer_html()),
    "See the full disclaimer:",
    fixed = TRUE
  )
})

test_that("app.R reads the repo version file", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  expect_true(exists("read_app_version", envir = env))
  expect_identical(env$read_app_version("VERSION"), "0.3.0")
})

test_that("app.R derives the latest reviewed source publication date", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  source_log <- data.frame(
    source_id = c("src-1", "src-2", "src-3"),
    source_name = c("WHO", "CDC", "WHO AFRO"),
    title = c("A", "B", "C"),
    url = c(
      "https://www.who.int/a",
      "https://www.cdc.gov/b",
      "https://www.afro.who.int/c"
    ),
    publication_date = as.Date(c("2026-05-22", "2026-05-25", "2026-05-21")),
    retrieved_at = as.POSIXct(
      c("2026-05-23 12:00:00", "2026-05-23 12:00:00", "2026-05-23 12:00:00"),
      tz = "UTC"
    ),
    source_type = c("don", "statement", "sitrep"),
    country = c("DRC", "Uganda", "DRC"),
    keywords = c("a", "b", "c"),
    review_status = c("reviewed", "rejected", "reviewed"),
    notes = c("a", "b", "c"),
    stringsAsFactors = FALSE
  )

  expect_true(exists("format_latest_reviewed_source_date", envir = env))
  expect_identical(
    env$format_latest_reviewed_source_date(source_log),
    "2026-05-22"
  )
})

test_that("app.R summarizes validation results for display", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  expect_true(exists("summarize_validation_status", envir = env))
  expect_identical(
    env$summarize_validation_status(list(errors = character(), warnings = character()))$label,
    "Passed"
  )
  expect_identical(
    env$summarize_validation_status(list(errors = character(), warnings = "warning"))$label,
    "Passed with warnings"
  )
  expect_identical(
    env$summarize_validation_status(list(errors = "error", warnings = character()))$label,
    "Failed"
  )
})

test_that("app.R stops startup when curated data validation returns errors", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  expect_true(exists("abort_if_validation_errors", envir = env))
  expect_error(
    env$abort_if_validation_errors(list(errors = "bad row", warnings = character())),
    "Curated data validation failed",
    fixed = TRUE
  )
})

test_that("app.R loads source candidates for the dashboard", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  expect_true(exists("source_candidates", envir = env))
  expect_true(all(
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
    ) %in% names(env$source_candidates)
  ))
})

test_that("format_link escapes href attribute quotes", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  expect_match(
    env$format_link("https://example.org/report?title=\"quoted\""),
    "title=&quot;quoted&quot;",
    fixed = TRUE
  )
})

test_that("table display fields are escaped before raw DT rendering", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  table_data <- data.frame(
    title = "<b>raw title</b>",
    summary = "<script>alert(1)</script>",
    link = env$format_link("https://example.org/report"),
    stringsAsFactors = FALSE
  )

  escaped <- env$escape_table_display_fields(table_data, exclude = "link")

  expect_identical(escaped$title, "&lt;b&gt;raw title&lt;/b&gt;")
  expect_identical(escaped$summary, "&lt;script&gt;alert(1)&lt;/script&gt;")
  expect_match(escaped$link, "<a href=", fixed = TRUE)
})

test_that("candidate queue table data escapes raw text and preserves links", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  candidate_data <- data.frame(
    discovered_at = as.POSIXct("2026-05-23 08:00:00", tz = "UTC"),
    source_name = "WHO Disease Outbreak News",
    title = "<b>candidate title</b>",
    url = "https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON604",
    publication_date = as.Date("2026-05-22"),
    source_type = "disease_outbreak_news",
    country = "Democratic Republic of the Congo",
    discovery_method = "manual_search",
    review_status = "queued",
    review_notes = "<script>alert(1)</script>",
    promoted_source_id = "",
    stringsAsFactors = FALSE
  )

  table_data <- env$candidate_queue_table_data(candidate_data)

  expect_identical(table_data$title, "&lt;b&gt;candidate title&lt;/b&gt;")
  expect_identical(table_data$review_notes, "&lt;script&gt;alert(1)&lt;/script&gt;")
  expect_match(table_data$link, "<a href=", fixed = TRUE)
})

test_that("source log table data uses reduced public columns", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  expect_true(exists("source_log_table_data", envir = env))
  table_data <- env$source_log_table_data(env$source_log)

  expect_identical(
    names(table_data),
    c("publication_date", "source_name", "title", "country", "link")
  )
})

test_that("news highlights table data uses reduced public columns", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  expect_true(exists("news_highlights_table_data", envir = env))
  table_data <- env$news_highlights_table_data(env$news_highlights)

  expect_identical(
    names(table_data),
    c("date", "source", "title", "summary", "category", "is_official", "link")
  )
})

test_that("candidate queue table data handles an empty queue", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  empty_candidates <- env$source_candidates[0, ]
  table_data <- env$candidate_queue_table_data(empty_candidates)

  expect_equal(nrow(table_data), 0)
  expect_true(all(
    c(
      "discovered_at",
      "source_name",
      "title",
      "link",
      "publication_date",
      "source_type",
      "country",
      "discovery_method",
      "review_status",
      "review_notes",
      "promoted_source_id"
    ) %in% names(table_data)
  ))
})

test_that("latest_summary_rows includes classified death rows", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  summary_rows <- env$latest_summary_rows(env$counts)
  death_rows <- summary_rows[summary_rows$metric == "deaths", ]

  expect_gt(nrow(death_rows), 0)
  expect_true(any(death_rows$case_classification %in% c("suspected", "confirmed")))
})

test_that("headline overflow text reports hidden current strata", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  expect_equal(env$headline_overflow_text(8, 6), "+2 more strata")
  expect_equal(env$headline_overflow_text(6, 6), character())
})

test_that("headline cards render without nested layout warning", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  testServer(env$server, {
    session$setInputs(
      source = env$all_choice,
      country = env$all_choice,
      classification = env$all_choice,
      metric = env$all_choice,
      date_range = env$count_dates
    )

    expect_warning(output$headline_cards, NA)
  })
})

test_that("headline overflow card renders visible hidden-strata indicator", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  overflow_card <- env$headline_overflow_card(8, 6)

  expect_match(as.character(overflow_card), "+2 more strata", fixed = TRUE)
  expect_match(as.character(overflow_card), "Additional current strata", fixed = TRUE)
})

test_that("candidate queue table output is defined for read-only review", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  expect_true(any(grepl("candidate_queue_table", capture.output(str(env$ui)), fixed = TRUE)))
  expect_true(exists("candidate_queue_table_data", envir = env))
  expect_true(any(grepl(
    "Read-only review metadata. Candidate rows do not update outbreak counts until a human promotes them.",
    capture.output(str(env$ui)),
    fixed = TRUE
  )))
})

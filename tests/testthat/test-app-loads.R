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

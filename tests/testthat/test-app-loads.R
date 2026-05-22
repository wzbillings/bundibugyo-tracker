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

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

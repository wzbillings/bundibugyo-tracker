library(testthat)

test_files <- list.files("tests/testthat", pattern = "^test.*\\.R$", full.names = TRUE)

if (length(test_files) > 0) {
  test_dir("tests/testthat", reporter = "summary")
} else {
  message("No test files found yet.")
}

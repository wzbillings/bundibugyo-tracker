# Ebola Dashboard Manual CSV Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build milestone 0.1 of the Ebola outbreak monitoring dashboard as a local-first R Shiny app backed by manually curated CSV data.

**Architecture:** CSV files in `data/` are the source of truth. Focused R modules in `R/` clean, validate, and derive reported increments. `app.R` loads those modules and renders a responsive, Plotly-backed Shiny dashboard with source, country, classification, metric, and date filters.

**Tech Stack:** R, Shiny, bslib, dplyr, tidyr, readr, lubridate, ggplot2, plotly, DT, stringr, testthat.

---

## File Map

- Create `R/clean_counts.R`: read and normalize outbreak counts, source log, and news highlights.
- Create `R/make_epicurve_data.R`: derive reported increments from cumulative rows without filling missing dates.
- Create `R/validate_counts.R`: command-line validation script and reusable validation function.
- Create `tests/testthat/test-clean_counts.R`: tests for date parsing, normalization, required columns, and invalid values.
- Create `tests/testthat/test-make_epicurve_data.R`: tests for derived increments, missing dates, and negative-increment flagging.
- Create `tests/testthat/test-validate_counts.R`: tests for hard validation failures and warnings.
- Create `tests/testthat.R`: testthat entry point.
- Create `data/outbreak_counts.csv`: sample manual-entry epidemiologic counts.
- Create `data/news_highlights.csv`: sample reviewed news/context highlights.
- Create `data/source_log.csv`: sample manually reviewed source log.
- Create `app.R`: responsive Shiny dashboard.
- Create `www/styles.css`: small app-specific responsive styles.
- Create `README.md`: purpose, limitations, manual update workflow, validation, and local run instructions.
- Create `.gitignore`: ignore `.Rproj.user`, `.Rhistory`, `.RData`, `.superpowers`, and raw temporary files.

## Task 1: Scaffold Data Files And Test Harness

**Files:**
- Create: `.gitignore`
- Create: `data/outbreak_counts.csv`
- Create: `data/news_highlights.csv`
- Create: `data/source_log.csv`
- Create: `tests/testthat.R`

- [ ] **Step 1: Create `.gitignore`**

```gitignore
.Rproj.user/
.Rhistory
.RData
.Ruserdata
.superpowers/
raw_reports/*.tmp
raw_reports/*.partial
```

- [ ] **Step 2: Create `data/outbreak_counts.csv`**

Use sample rows only. These rows are demonstration data and must not be presented as verified outbreak facts.

```csv
source_name,source_url,publication_date,data_cutoff_date,country,case_classification,metric,count_type,count,notes
WHO AFRO sample,https://example.org/who-afro-sample-1,2026-02-02,2026-02-01,Democratic Republic of the Congo,suspected,cases,cumulative,8,Sample row for dashboard development only
WHO AFRO sample,https://example.org/who-afro-sample-1,2026-02-02,2026-02-01,Democratic Republic of the Congo,confirmed,cases,cumulative,2,Sample row for dashboard development only
WHO AFRO sample,https://example.org/who-afro-sample-1,2026-02-02,2026-02-01,Democratic Republic of the Congo,all,deaths,cumulative,1,Sample row for dashboard development only
WHO AFRO sample,https://example.org/who-afro-sample-2,2026-02-05,2026-02-04,Democratic Republic of the Congo,suspected,cases,cumulative,14,Sample row for dashboard development only
WHO AFRO sample,https://example.org/who-afro-sample-2,2026-02-05,2026-02-04,Democratic Republic of the Congo,confirmed,cases,cumulative,5,Sample row for dashboard development only
WHO AFRO sample,https://example.org/who-afro-sample-2,2026-02-05,2026-02-04,Democratic Republic of the Congo,all,deaths,cumulative,2,Sample row for dashboard development only
ReliefWeb sample,https://example.org/reliefweb-sample-1,2026-02-08,2026-02-07,Democratic Republic of the Congo,suspected,cases,cumulative,18,Sample row for dashboard development only
ReliefWeb sample,https://example.org/reliefweb-sample-1,2026-02-08,2026-02-07,Democratic Republic of the Congo,confirmed,cases,cumulative,7,Sample row for dashboard development only
ReliefWeb sample,https://example.org/reliefweb-sample-1,2026-02-08,2026-02-07,Democratic Republic of the Congo,all,deaths,cumulative,3,Sample row for dashboard development only
WHO AFRO sample,https://example.org/who-afro-sample-3,2026-02-10,2026-02-09,Uganda,suspected,cases,cumulative,1,Sample imported-case placeholder for dashboard development only
WHO AFRO sample,https://example.org/who-afro-sample-3,2026-02-10,2026-02-09,Uganda,confirmed,cases,cumulative,0,Sample imported-case placeholder for dashboard development only
WHO AFRO sample,https://example.org/who-afro-sample-3,2026-02-10,2026-02-09,Uganda,all,deaths,cumulative,0,Sample imported-case placeholder for dashboard development only
```

- [ ] **Step 3: Create `data/news_highlights.csv`**

```csv
date,source,title,url,summary,category,is_official,notes
2026-02-02,WHO AFRO,Sample official situation update,https://example.org/who-afro-sample-1,Official sample update used to test display of reviewed highlights.,epidemiology,TRUE,Sample row for dashboard development only
2026-02-08,ReliefWeb,Sample humanitarian operations update,https://example.org/reliefweb-sample-1,Humanitarian sample update used to test reviewed context display.,response,TRUE,Sample row for dashboard development only
2026-02-09,Reuters,Sample contextual news item,https://example.org/reuters-sample-1,News sample used to test non-official context display.,policy,FALSE,Sample row for dashboard development only
```

- [ ] **Step 4: Create `data/source_log.csv`**

```csv
source_id,source_name,title,url,publication_date,retrieved_at,source_type,country,keywords,review_status,notes
sample-who-afro-1,WHO AFRO sample,Sample official situation update,https://example.org/who-afro-sample-1,2026-02-02,2026-05-22T12:00:00Z,situation_report,Democratic Republic of the Congo,"Ebola; Bundibugyo; DRC",extracted,Sample row for dashboard development only
sample-reliefweb-1,ReliefWeb sample,Sample humanitarian operations update,https://example.org/reliefweb-sample-1,2026-02-08,2026-05-22T12:00:00Z,situation_report,Democratic Republic of the Congo,"Ebola; response; situation report",reviewed,Sample row for dashboard development only
sample-cdc-1,CDC sample,Sample CDC situation summary,https://example.org/cdc-sample-1,2026-02-09,2026-05-22T12:00:00Z,advisory,Uganda,"Ebola; travel; clinical guidance",reviewed,Sample row for dashboard development only
```

- [ ] **Step 5: Create `tests/testthat.R`**

```r
library(testthat)

test_dir("tests/testthat", reporter = "summary")
```

- [ ] **Step 6: Commit scaffold**

Run:

```bash
git add .gitignore data/outbreak_counts.csv data/news_highlights.csv data/source_log.csv tests/testthat.R
git commit -m "chore: scaffold manual csv dashboard data"
```

Expected: commit succeeds with the new scaffold files.

## Task 2: Clean Counts Module With Tests

**Files:**
- Create: `tests/testthat/test-clean_counts.R`
- Create: `R/clean_counts.R`

- [ ] **Step 1: Write failing tests**

Create `tests/testthat/test-clean_counts.R`:

```r
source("R/clean_counts.R")

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
```

- [ ] **Step 2: Run tests and verify they fail**

Run:

```bash
Rscript -e "testthat::test_file('tests/testthat/test-clean_counts.R')"
```

Expected: failure because `R/clean_counts.R` or `clean_counts()` does not exist.

- [ ] **Step 3: Implement `R/clean_counts.R`**

```r
library(dplyr)
library(lubridate)
library(readr)
library(stringr)

required_count_columns <- c(
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

required_source_columns <- c(
  "source_id",
  "source_name",
  "title",
  "url",
  "publication_date",
  "retrieved_at",
  "source_type",
  "country",
  "keywords",
  "review_status",
  "notes"
)

required_news_columns <- c(
  "date",
  "source",
  "title",
  "url",
  "summary",
  "category",
  "is_official",
  "notes"
)

assert_required_columns <- function(data, required_columns) {
  missing_columns <- setdiff(required_columns, names(data))
  if (length(missing_columns) > 0) {
    stop(
      "Missing required columns: ",
      paste(missing_columns, collapse = ", "),
      call. = FALSE
    )
  }
}

standardize_country <- function(country) {
  normalized <- str_to_lower(str_squish(as.character(country)))
  dplyr::case_when(
    normalized %in% c("drc", "democratic republic of congo", "democratic republic of the congo", "rdc") ~
      "Democratic Republic of the Congo",
    normalized == "uganda" ~ "Uganda",
    TRUE ~ str_to_title(str_squish(as.character(country)))
  )
}

clean_counts <- function(data) {
  assert_required_columns(data, required_count_columns)

  data %>%
    mutate(
      across(where(is.character), str_squish),
      publication_date = as_date(publication_date),
      data_cutoff_date = as_date(data_cutoff_date),
      country = standardize_country(country),
      case_classification = str_to_lower(case_classification),
      metric = str_to_lower(metric),
      count_type = str_to_lower(count_type),
      count = as.integer(count)
    )
}

read_counts <- function(path = "data/outbreak_counts.csv") {
  read_csv(path, show_col_types = FALSE) %>%
    clean_counts()
}

clean_source_log <- function(data) {
  assert_required_columns(data, required_source_columns)

  data %>%
    mutate(
      across(where(is.character), str_squish),
      publication_date = as_date(publication_date),
      retrieved_at = ymd_hms(retrieved_at, quiet = TRUE),
      country = standardize_country(country),
      review_status = str_to_lower(review_status),
      source_type = str_to_lower(source_type)
    )
}

read_source_log <- function(path = "data/source_log.csv") {
  read_csv(path, show_col_types = FALSE) %>%
    clean_source_log()
}

clean_news_highlights <- function(data) {
  assert_required_columns(data, required_news_columns)

  data %>%
    mutate(
      across(where(is.character), str_squish),
      date = as_date(date),
      category = str_to_lower(category),
      is_official = as.logical(is_official)
    )
}

read_news_highlights <- function(path = "data/news_highlights.csv") {
  read_csv(path, show_col_types = FALSE) %>%
    clean_news_highlights()
}
```

- [ ] **Step 4: Run tests and verify they pass**

Run:

```bash
Rscript -e "testthat::test_file('tests/testthat/test-clean_counts.R')"
```

Expected: all tests pass.

- [ ] **Step 5: Commit cleaning module**

Run:

```bash
git add R/clean_counts.R tests/testthat/test-clean_counts.R
git commit -m "test: add count cleaning module"
```

Expected: commit succeeds.

## Task 3: Epicurve Derivation With Tests

**Files:**
- Create: `tests/testthat/test-make_epicurve_data.R`
- Create: `R/make_epicurve_data.R`

- [ ] **Step 1: Write failing tests**

Create `tests/testthat/test-make_epicurve_data.R`:

```r
source("R/clean_counts.R")
source("R/make_epicurve_data.R")

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
```

- [ ] **Step 2: Run tests and verify they fail**

Run:

```bash
Rscript -e "testthat::test_file('tests/testthat/test-make_epicurve_data.R')"
```

Expected: failure because `R/make_epicurve_data.R` or `make_epicurve_data()` does not exist.

- [ ] **Step 3: Implement `R/make_epicurve_data.R`**

```r
library(dplyr)

make_epicurve_data <- function(counts) {
  cumulative_counts <- counts %>%
    filter(count_type == "cumulative") %>%
    arrange(source_name, country, case_classification, metric, data_cutoff_date, publication_date)

  cumulative_counts %>%
    group_by(source_name, country, case_classification, metric) %>%
    mutate(
      previous_count = lag(count),
      previous_cutoff_date = lag(data_cutoff_date),
      reported_increment = if_else(is.na(previous_count), count, count - previous_count),
      days_since_previous_report = as.integer(data_cutoff_date - previous_cutoff_date),
      missing_previous_report = FALSE,
      negative_increment = reported_increment < 0
    ) %>%
    ungroup()
}
```

- [ ] **Step 4: Run tests and verify they pass**

Run:

```bash
Rscript -e "testthat::test_file('tests/testthat/test-make_epicurve_data.R')"
```

Expected: all tests pass.

- [ ] **Step 5: Commit epicurve module**

Run:

```bash
git add R/make_epicurve_data.R tests/testthat/test-make_epicurve_data.R
git commit -m "test: derive reported increment epicurve data"
```

Expected: commit succeeds.

## Task 4: Validation Script With Tests

**Files:**
- Create: `tests/testthat/test-validate_counts.R`
- Create: `R/validate_counts.R`

- [ ] **Step 1: Write failing tests**

Create `tests/testthat/test-validate_counts.R`:

```r
source("R/clean_counts.R")
source("R/make_epicurve_data.R")
source("R/validate_counts.R")

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
```

- [ ] **Step 2: Run tests and verify they fail**

Run:

```bash
Rscript -e "testthat::test_file('tests/testthat/test-validate_counts.R')"
```

Expected: failure because `validate_counts_data()` does not exist.

- [ ] **Step 3: Implement `R/validate_counts.R`**

```r
library(dplyr)
library(readr)

source("R/clean_counts.R")
source("R/make_epicurve_data.R")

validate_counts_data <- function(data) {
  errors <- character()
  warnings <- character()

  missing_columns <- setdiff(required_count_columns, names(data))
  if (length(missing_columns) > 0) {
    errors <- c(errors, paste("Missing required columns:", paste(missing_columns, collapse = ", ")))
    return(list(errors = errors, warnings = warnings))
  }

  cleaned <- tryCatch(
    clean_counts(data),
    error = function(error) {
      errors <<- c(errors, conditionMessage(error))
      NULL
    }
  )

  if (is.null(cleaned)) {
    return(list(errors = errors, warnings = warnings))
  }

  if (any(is.na(cleaned$publication_date))) {
    errors <- c(errors, "Invalid publication_date values")
  }
  if (any(is.na(cleaned$data_cutoff_date))) {
    errors <- c(errors, "Invalid data_cutoff_date values")
  }
  if (any(is.na(cleaned$count))) {
    errors <- c(errors, "Counts must be parseable integers")
  }
  if (any(!is.na(cleaned$count) & cleaned$count < 0)) {
    errors <- c(errors, "Counts must be nonnegative integers")
  }
  if (any(cleaned$count_type %notin% c("cumulative", "incident"))) {
    errors <- c(errors, "Invalid count_type values; expected cumulative or incident")
  }
  if (any(is.na(cleaned$source_url) | cleaned$source_url == "")) {
    errors <- c(errors, "Missing source_url values")
  }

  duplicate_rows <- cleaned %>%
    count(across(all_of(required_count_columns)), name = "n") %>%
    filter(n > 1)
  if (nrow(duplicate_rows) > 0) {
    errors <- c(errors, "Duplicate rows detected")
  }

  duplicate_keys <- cleaned %>%
    count(source_name, country, case_classification, metric, data_cutoff_date, name = "n") %>%
    filter(n > 1)
  if (nrow(duplicate_keys) > 0) {
    errors <- c(errors, "Duplicate source/country/classification/metric/cutoff combinations detected")
  }

  derived <- make_epicurve_data(cleaned)
  negative_count <- sum(derived$negative_increment, na.rm = TRUE)
  if (negative_count > 0) {
    warnings <- c(warnings, paste("Negative derived increments detected:", negative_count))
  }

  list(errors = unique(errors), warnings = unique(warnings))
}

`%notin%` <- Negate(`%in%`)

run_validation <- function(path = "data/outbreak_counts.csv") {
  raw_counts <- read_csv(path, show_col_types = FALSE)
  result <- validate_counts_data(raw_counts)

  if (length(result$warnings) > 0) {
    writeLines(paste("WARNING:", result$warnings))
  }
  if (length(result$errors) > 0) {
    writeLines(paste("ERROR:", result$errors))
    quit(status = 1)
  }

  writeLines("Validation passed")
  invisible(result)
}

if (sys.nframe() == 0) {
  run_validation()
}
```

- [ ] **Step 4: Run tests and verify they pass**

Run:

```bash
Rscript -e "testthat::test_file('tests/testthat/test-validate_counts.R')"
```

Expected: all tests pass.

- [ ] **Step 5: Run validation script against sample data**

Run:

```bash
Rscript R/validate_counts.R
```

Expected: `Validation passed`.

- [ ] **Step 6: Commit validation script**

Run:

```bash
git add R/validate_counts.R tests/testthat/test-validate_counts.R
git commit -m "test: validate manual outbreak counts"
```

Expected: commit succeeds.

## Task 5: Responsive Shiny App With Plotly Filters

**Files:**
- Create: `app.R`
- Create: `www/styles.css`

- [ ] **Step 1: Write a smoke test for app load**

Create `tests/testthat/test-app-loads.R`:

```r
test_that("app.R can be sourced without constructing invalid objects", {
  expect_silent(source("app.R", local = new.env(parent = globalenv())))
})
```

- [ ] **Step 2: Run smoke test and verify it fails**

Run:

```bash
Rscript -e "testthat::test_file('tests/testthat/test-app-loads.R')"
```

Expected: failure because `app.R` does not exist.

- [ ] **Step 3: Create `www/styles.css`**

```css
.dashboard-card {
  min-height: 104px;
}

.dashboard-card .card-title {
  color: #5f6f7a;
  font-size: 0.78rem;
  text-transform: uppercase;
}

.dashboard-card .card-value {
  font-size: 1.65rem;
  font-weight: 700;
  line-height: 1.2;
}

.caveat-panel {
  border-left: 4px solid #b7791f;
  background: #fff8e6;
}

.filter-row {
  gap: 0.75rem;
}

@media (max-width: 768px) {
  .dashboard-card .card-value {
    font-size: 1.35rem;
  }

  .container-fluid {
    padding-left: 0.75rem;
    padding-right: 0.75rem;
  }
}
```

- [ ] **Step 4: Create `app.R`**

```r
library(shiny)
library(bslib)
library(dplyr)
library(DT)
library(ggplot2)
library(plotly)

source("R/clean_counts.R")
source("R/make_epicurve_data.R")

counts <- read_counts()
epicurve <- make_epicurve_data(counts)
source_log <- read_source_log()
news_highlights <- read_news_highlights()

choice_all <- function(values) {
  c("All" = "__all__", sort(unique(values)))
}

filter_values <- function(data, input) {
  filtered <- data
  if (!is.null(input$source_name) && input$source_name != "__all__") {
    filtered <- filtered %>% filter(source_name == input$source_name)
  }
  if (!is.null(input$country) && input$country != "__all__") {
    filtered <- filtered %>% filter(country == input$country)
  }
  if (!is.null(input$case_classification) && input$case_classification != "__all__") {
    filtered <- filtered %>% filter(case_classification == input$case_classification)
  }
  if (!is.null(input$metric) && input$metric != "__all__") {
    filtered <- filtered %>% filter(metric == input$metric)
  }
  if (!is.null(input$date_range) && length(input$date_range) == 2) {
    filtered <- filtered %>%
      filter(data_cutoff_date >= input$date_range[1], data_cutoff_date <= input$date_range[2])
  }
  filtered
}

latest_count <- function(data, country_value, classification_value, metric_value) {
  result <- data %>%
    filter(
      country == country_value,
      case_classification == classification_value,
      metric == metric_value,
      count_type == "cumulative"
    ) %>%
    arrange(desc(data_cutoff_date), desc(publication_date)) %>%
    slice_head(n = 1)

  if (nrow(result) == 0) {
    return("No data")
  }
  format(result$count, big.mark = ",")
}

card_value <- function(title, value) {
  bslib::card(
    class = "dashboard-card",
    div(class = "card-title", title),
    div(class = "card-value", value)
  )
}

ui <- page_navbar(
  title = "Ebola Outbreak Monitoring",
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  header = tags$head(tags$link(rel = "stylesheet", href = "styles.css")),
  nav_panel(
    "Overview",
    layout_sidebar(
      sidebar = sidebar(
        selectInput("source_name", "Source", choices = choice_all(counts$source_name)),
        selectInput("country", "Country", choices = choice_all(counts$country)),
        selectInput("case_classification", "Case classification", choices = choice_all(counts$case_classification)),
        selectInput("metric", "Metric", choices = choice_all(counts$metric)),
        dateRangeInput(
          "date_range",
          "Data cutoff date",
          start = min(counts$data_cutoff_date, na.rm = TRUE),
          end = max(counts$data_cutoff_date, na.rm = TRUE)
        )
      ),
      layout_columns(
        col_widths = c(12, 6, 6, 6, 6, 12, 12),
        uiOutput("headline_cards"),
        card(
          card_header("Cumulative counts"),
          plotlyOutput("cumulative_plot", height = "360px")
        ),
        card(
          card_header("Reported increments"),
          p("Daily values are derived from changes in cumulative public reports and may reflect reporting artifacts."),
          plotlyOutput("incident_plot", height = "360px")
        ),
        card(
          card_header("Source log"),
          DTOutput("source_table")
        ),
        card(
          card_header("News highlights"),
          DTOutput("news_table")
        ),
        card(
          class = "caveat-panel",
          card_header("Data quality and caveats"),
          tags$ul(
            tags$li("Public counts may reflect reporting date, not onset date."),
            tags$li("Recent counts are provisional."),
            tags$li("Suspected, probable, and confirmed classifications may be revised."),
            tags$li("Negative daily increments can occur after reclassification or deduplication."),
            tags$li("Missing report days should not be interpreted as zero cases."),
            tags$li("Country-level curves hide subnational heterogeneity.")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  filtered_counts <- reactive(filter_values(counts, input))
  filtered_epicurve <- reactive(filter_values(epicurve, input))

  output$headline_cards <- renderUI({
    latest_date <- filtered_counts() %>%
      summarise(latest = max(data_cutoff_date, na.rm = TRUE)) %>%
      pull(latest)

    layout_columns(
      col_widths = c(12, 6, 6, 6, 6, 6, 6),
      card_value("Latest cutoff", as.character(latest_date)),
      card_value("DRC suspected cases", latest_count(filtered_counts(), "Democratic Republic of the Congo", "suspected", "cases")),
      card_value("DRC confirmed cases", latest_count(filtered_counts(), "Democratic Republic of the Congo", "confirmed", "cases")),
      card_value("DRC deaths", latest_count(filtered_counts(), "Democratic Republic of the Congo", "all", "deaths")),
      card_value("Uganda suspected cases", latest_count(filtered_counts(), "Uganda", "suspected", "cases")),
      card_value("Uganda confirmed cases", latest_count(filtered_counts(), "Uganda", "confirmed", "cases")),
      card_value("Uganda deaths", latest_count(filtered_counts(), "Uganda", "all", "deaths"))
    )
  })

  output$cumulative_plot <- renderPlotly({
    plot_data <- filtered_counts() %>%
      filter(count_type == "cumulative")

    validate(need(nrow(plot_data) > 0, "No cumulative data for selected filters."))

    plot <- ggplot(
      plot_data,
      aes(
        x = data_cutoff_date,
        y = count,
        color = interaction(country, case_classification, metric, sep = " / "),
        group = interaction(source_name, country, case_classification, metric),
        text = paste0(
          "Source: ", source_name,
          "<br>Cutoff: ", data_cutoff_date,
          "<br>Country: ", country,
          "<br>Classification: ", case_classification,
          "<br>Metric: ", metric,
          "<br>Count: ", count
        )
      )
    ) +
      geom_line(linewidth = 0.9) +
      geom_point(size = 2) +
      labs(x = "Data cutoff date", y = "Cumulative count", color = "Series") +
      theme_minimal()

    ggplotly(plot, tooltip = "text")
  })

  output$incident_plot <- renderPlotly({
    plot_data <- filtered_epicurve()

    validate(need(nrow(plot_data) > 0, "No derived increment data for selected filters."))

    plot <- ggplot(
      plot_data,
      aes(
        x = data_cutoff_date,
        y = reported_increment,
        fill = interaction(country, case_classification, metric, sep = " / "),
        text = paste0(
          "Source: ", source_name,
          "<br>Cutoff: ", data_cutoff_date,
          "<br>Country: ", country,
          "<br>Classification: ", case_classification,
          "<br>Metric: ", metric,
          "<br>Reported increment: ", reported_increment
        )
      )
    ) +
      geom_col(position = "dodge") +
      labs(x = "Data cutoff date", y = "Derived reported increment", fill = "Series") +
      theme_minimal()

    ggplotly(plot, tooltip = "text")
  })

  output$source_table <- renderDT({
    datatable(
      source_log,
      rownames = FALSE,
      options = list(pageLength = 5, scrollX = TRUE)
    )
  })

  output$news_table <- renderDT({
    datatable(
      news_highlights %>% arrange(desc(date)),
      rownames = FALSE,
      options = list(pageLength = 5, scrollX = TRUE)
    )
  })
}

shinyApp(ui, server)
```

- [ ] **Step 5: Run smoke test and verify it passes**

Run:

```bash
Rscript -e "testthat::test_file('tests/testthat/test-app-loads.R')"
```

Expected: all tests pass.

- [ ] **Step 6: Commit Shiny app**

Run:

```bash
git add app.R www/styles.css tests/testthat/test-app-loads.R
git commit -m "feat: add interactive shiny dashboard"
```

Expected: commit succeeds.

## Task 6: README And Final Verification

**Files:**
- Create: `README.md`

- [ ] **Step 1: Create `README.md`**

```markdown
# Ebola Outbreak Monitoring Dashboard

This project is a lightweight R Shiny dashboard for manually curated public Ebola outbreak counts from official and humanitarian sources.

## Data Interpretation

The dashboard tracks publicly reported Ebola outbreak counts from official and humanitarian sources. Most case counts are cumulative and tied to report cutoff dates, not individual symptom-onset dates. Daily incident values shown in the dashboard are derived by differencing cumulative public counts and should be interpreted as reported increments rather than true epidemiologic incidence. Counts may change because of reclassification, deduplication, delayed reporting, or changes in case definitions.

The example rows in `data/` are sample development data. Replace them with reviewed counts before using the dashboard for analysis or communication.

## Manual Update Workflow

1. Review an official or humanitarian situation report.
2. Add the source metadata to `data/source_log.csv`.
3. Add any reviewed epidemiologic counts to `data/outbreak_counts.csv`.
4. Add contextual reviewed headlines to `data/news_highlights.csv`.
5. Run validation:

```r
Rscript R/validate_counts.R
```

6. Start the app:

```r
shiny::runApp()
```

## Required R Packages

Install these packages before running the dashboard:

```r
install.packages(c(
  "shiny",
  "bslib",
  "dplyr",
  "tidyr",
  "readr",
  "lubridate",
  "ggplot2",
  "plotly",
  "DT",
  "stringr",
  "testthat"
))
```

## Validation Rules

`R/validate_counts.R` checks that required columns exist, dates parse correctly, counts are nonnegative integers, source URLs are present, `count_type` values are allowed, duplicate rows are flagged, duplicate source/country/classification/metric/cutoff combinations are flagged, and negative derived increments are printed as warnings.

## First Milestone Scope

The first milestone uses manual CSV entry only. Automated source discovery, scraping, GitHub Actions, deployment, and a curated queryable news database are planned for future milestones after the manual review workflow is trusted.
```

- [ ] **Step 2: Run all tests**

Run:

```bash
Rscript -e "testthat::test_dir('tests/testthat')"
```

Expected: all tests pass.

- [ ] **Step 3: Run count validation**

Run:

```bash
Rscript R/validate_counts.R
```

Expected: `Validation passed`.

- [ ] **Step 4: Launch app locally**

Run:

```bash
Rscript -e "shiny::runApp(host = '127.0.0.1', port = 3838)"
```

Expected: Shiny starts at `http://127.0.0.1:3838`. Verify the page shows headline cards, Plotly cumulative and reported-increment plots, source and news tables, and the caveats panel.

- [ ] **Step 5: Commit documentation**

Run:

```bash
git add README.md
git commit -m "docs: explain manual dashboard workflow"
```

Expected: commit succeeds.

- [ ] **Step 6: Final status check**

Run:

```bash
git status --short
```

Expected: no uncommitted milestone files. `.superpowers/` and `dashboard-layout-preview.html` may remain untracked brainstorming artifacts unless removed or committed by user choice.

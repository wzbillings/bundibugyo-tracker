# Ebola Dashboard Milestone 0.2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace sample dashboard data with verified official/public source rows and make the manual curation workflow strong enough for repeated use.

**Architecture:** Keep CSV files in `data/` as the source of truth and keep epidemiologic counts manually curated. Use WHO outbreak pages as the initial verified seed dataset, then tighten validation and dashboard display only where real curated rows reveal ambiguity.

**Tech Stack:** R, Shiny, bslib, dplyr, readr, lubridate, stringr, ggplot2, plotly, DT, testthat, renv.

---

## Triage Priorities

1. Replace every `example.org` sample row with official source-backed rows from WHO Disease Outbreak News DON602 and DON603.
2. Model deaths by the classification stated by the source. Do not force suspected deaths or confirmed deaths into `case_classification = all`.
3. Add validation for real curation hazards: sample URLs, malformed URLs, impossible publication/cutoff ordering, invalid classifications/metrics, duplicate source URLs, and count rows whose URL is absent from `source_log.csv`.
4. Improve source and news usability after real rows land: clickable links, newest-first sorting, clearer review statuses, and dynamic headline cards that do not assume only `all` deaths.
5. Leave automation, scraping, PDF count extraction, source discovery, GitHub Actions, and deployment out of milestone 0.2.

## Source Baseline

Use these verified/public sources for the first real seed dataset:

- WHO DON602, published 2026-05-16: `https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON602`
- WHO DON603, published 2026-05-21: `https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON603`
- WHO IHR Emergency Committee statement, published 2026-05-22: `https://www.who.int/news/item/22-05-2026-first-meeting-of-the-ihr-emergency-committee-regarding-the-epidemic-of-ebola-bundibugyo-virus-disease-in-the-democratic-republic-of-the-congo-and-uganda-2026-temporary-recommendations`
- CDC newsroom statement, published 2026-05-17 and updated 2026-05-18: `https://www.cdc.gov/media/releases/2026/cdc-mobilizes-international-ebola-response.html`

## File Map

- Modify `data/outbreak_counts.csv`: replace all sample rows with official WHO DON602/DON603 count rows.
- Modify `data/source_log.csv`: replace sample source rows with reviewed official source metadata.
- Modify `data/news_highlights.csv`: replace sample highlights with context items from WHO/CDC official public updates.
- Modify `R/validate_counts.R`: add curation-oriented validation and cross-file checks.
- Modify `tests/testthat/test-validate_counts.R`: cover new validation rules.
- Modify `app.R`: make headline cards derive from real classifications and make source/news URLs clickable.
- Modify `README.md`: document the milestone 0.2 curation rules and classification conventions.

## Task 1: Replace Sample CSV Data With Official Seed Rows

**Files:**
- Modify: `data/outbreak_counts.csv`
- Modify: `data/source_log.csv`
- Modify: `data/news_highlights.csv`

- [ ] **Step 1: Replace `data/outbreak_counts.csv`**

Use this exact seed file. Counts are manually curated from WHO DON602 and DON603. Rows intentionally preserve suspected deaths and confirmed deaths separately.

```csv
source_name,source_url,publication_date,data_cutoff_date,country,case_classification,metric,count_type,count,notes
WHO Disease Outbreak News DON602,https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON602,2026-05-16,2026-05-15,Democratic Republic of the Congo,suspected,cases,cumulative,246,"WHO DON602 states that as of 15 May 2026 DRC reported 246 suspected cases from Rwampara, Mongbwalu, and Bunia health zones."
WHO Disease Outbreak News DON602,https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON602,2026-05-16,2026-05-15,Democratic Republic of the Congo,suspected,deaths,cumulative,80,"WHO DON602 states that as of 15 May 2026 DRC reported 80 deaths among suspected cases."
WHO Disease Outbreak News DON602,https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON602,2026-05-16,2026-05-15,Democratic Republic of the Congo,confirmed,cases,cumulative,8,"WHO DON602 states that INRB confirmed Bundibugyo virus disease in eight samples on 15 May 2026."
WHO Disease Outbreak News DON602,https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON602,2026-05-16,2026-05-15,Democratic Republic of the Congo,confirmed,deaths,cumulative,4,"WHO DON602 reports four deaths among confirmed cases."
WHO Disease Outbreak News DON602,https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON602,2026-05-16,2026-05-16,Uganda,confirmed,cases,cumulative,2,"WHO DON602 reports one imported case confirmed on 15 May and a second imported case confirmed on 16 May in Kampala."
WHO Disease Outbreak News DON602,https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON602,2026-05-16,2026-05-16,Uganda,confirmed,deaths,cumulative,1,"WHO DON602 reports the first Uganda imported case died on 14 May 2026."
WHO Disease Outbreak News DON603,https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON603,2026-05-21,2026-05-21,Democratic Republic of the Congo,suspected,cases,cumulative,746,"WHO DON603 states that as of 21 May 2026 DRC reported 746 suspected cases."
WHO Disease Outbreak News DON603,https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON603,2026-05-21,2026-05-21,Democratic Republic of the Congo,suspected,deaths,cumulative,176,"WHO DON603 states that as of 21 May 2026 DRC reported 176 deaths among suspected cases."
WHO Disease Outbreak News DON603,https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON603,2026-05-21,2026-05-21,Democratic Republic of the Congo,confirmed,cases,cumulative,83,"WHO DON603 states that as of 21 May 2026 DRC reported 83 confirmed cases."
WHO Disease Outbreak News DON603,https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON603,2026-05-21,2026-05-21,Democratic Republic of the Congo,confirmed,deaths,cumulative,9,"WHO DON603 states that as of 21 May 2026 DRC reported nine deaths among confirmed cases."
WHO Disease Outbreak News DON603,https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON603,2026-05-21,2026-05-20,Uganda,confirmed,cases,cumulative,2,"WHO DON603 states that as of 20 May 2026 Uganda reported two confirmed imported cases."
WHO Disease Outbreak News DON603,https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON603,2026-05-21,2026-05-20,Uganda,confirmed,deaths,cumulative,1,"WHO DON603 states that as of 20 May 2026 Uganda reported one death among confirmed imported cases."
```

- [ ] **Step 2: Replace `data/source_log.csv`**

Use this exact seed file.

```csv
source_id,source_name,title,url,publication_date,retrieved_at,source_type,country,keywords,review_status,notes
who-don-602,WHO Disease Outbreak News DON602,"Ebola disease caused by Bundibugyo virus, Democratic Republic of the Congo & Uganda",https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON602,2026-05-16,2026-05-22T22:55:56Z,disease_outbreak_news,"Democratic Republic of the Congo; Uganda","Ebola; Bundibugyo; DRC; Uganda; PHEIC",extracted,"Primary official source for initial outbreak declaration and early count rows."
who-don-603,WHO Disease Outbreak News DON603,Ebola disease caused by Bundibugyo virus - Democratic Republic of the Congo,https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON603,2026-05-21,2026-05-22T22:55:56Z,disease_outbreak_news,"Democratic Republic of the Congo; Uganda","Ebola; Bundibugyo; DRC; Uganda; situation update",extracted,"Primary official source for 21 May DRC counts and 20 May Uganda counts."
who-ihr-ec-2026-05-22,WHO IHR Emergency Committee,First meeting of the IHR Emergency Committee regarding the epidemic of Ebola Bundibugyo virus disease in the Democratic Republic of the Congo and Uganda 2026,https://www.who.int/news/item/22-05-2026-first-meeting-of-the-ihr-emergency-committee-regarding-the-epidemic-of-ebola-bundibugyo-virus-disease-in-the-democratic-republic-of-the-congo-and-uganda-2026-temporary-recommendations,2026-05-22,2026-05-22T22:55:56Z,statement,"Democratic Republic of the Congo; Uganda","Ebola; Bundibugyo; IHR; PHEIC; temporary recommendations",reviewed,"Context source only; no count rows extracted."
cdc-2026-05-17,CDC Newsroom,CDC Mobilizes International Response Following Ebola Disease Outbreak in DRC and Uganda,https://www.cdc.gov/media/releases/2026/cdc-mobilizes-international-ebola-response.html,2026-05-17,2026-05-22T22:55:56Z,statement,"Democratic Republic of the Congo; Uganda","Ebola; Bundibugyo; CDC; public health response",reviewed,"Context source only for 0.2 because WHO DON pages are the count source of record."
```

- [ ] **Step 3: Replace `data/news_highlights.csv`**

Use this exact seed file. These are contextual highlights only and must not be used to derive counts.

```csv
date,source,title,url,summary,category,is_official,notes
2026-05-16,WHO,"WHO determines Bundibugyo virus disease outbreak in DRC and Uganda is a PHEIC",https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON602,"WHO reported the initial confirmation of Bundibugyo virus disease in DRC and imported cases in Uganda, with response measures underway.",epidemiology,TRUE,"Official context highlight from DON602."
2026-05-21,WHO,"WHO reports rapid increase and geographic expansion in DRC",https://www.who.int/emergencies/disease-outbreak-news/item/2026-DON603,"WHO reported increased suspected and confirmed counts in DRC, confirmed imported cases in Uganda, and ongoing response constraints.",epidemiology,TRUE,"Official context highlight from DON603."
2026-05-22,WHO,"IHR Emergency Committee issues temporary recommendations",https://www.who.int/news/item/22-05-2026-first-meeting-of-the-ihr-emergency-committee-regarding-the-epidemic-of-ebola-bundibugyo-virus-disease-in-the-democratic-republic-of-the-congo-and-uganda-2026-temporary-recommendations,"WHO issued temporary recommendations for affected and at-risk States Parties after the first IHR Emergency Committee meeting.",policy,TRUE,"Context only; no count rows extracted."
2026-05-17,CDC,"CDC mobilizes international response support",https://www.cdc.gov/media/releases/2026/cdc-mobilizes-international-ebola-response.html,"CDC described support for surveillance, diagnostics, infection prevention and control, and outbreak containment activities in DRC and Uganda.",response,TRUE,"Context only; no count rows extracted."
```

- [ ] **Step 4: Run count validation**

Run:

```powershell
Rscript R/validate_counts.R
```

Expected: `Validation passed`.

- [ ] **Step 5: Run tests**

Run:

```powershell
Rscript tests/testthat.R
```

Expected: all tests pass.

- [ ] **Step 6: Commit official seed data**

Run:

```powershell
git add data/outbreak_counts.csv data/source_log.csv data/news_highlights.csv
git commit -m "data: seed dashboard with official outbreak sources"
```

Expected: commit succeeds.

## Task 2: Add Curation Validation Rules

**Files:**
- Modify: `R/validate_counts.R`
- Modify: `tests/testthat/test-validate_counts.R`

- [ ] **Step 1: Add failing tests for real curation hazards**

Append these tests to `tests/testthat/test-validate_counts.R`:

```r
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

test_that("validate_all_data flags count urls missing from source log", {
  counts <- valid_counts_fixture()
  source_log <- data.frame(
    source_id = "src-1",
    source_name = "WHO",
    title = "Report",
    url = "https://example.org/different-report",
    publication_date = "2026-02-02",
    retrieved_at = "2026-05-22T12:00:00Z",
    source_type = "disease_outbreak_news",
    country = "DRC",
    keywords = "Ebola",
    review_status = "reviewed",
    notes = "sample",
    stringsAsFactors = FALSE
  )
  news <- data.frame(
    date = "2026-02-02",
    source = "WHO",
    title = "Report",
    url = "https://example.org/report",
    summary = "Summary",
    category = "epidemiology",
    is_official = "TRUE",
    notes = "sample",
    stringsAsFactors = FALSE
  )

  result <- validate_all_data(counts, source_log, news)

  expect_true(any(grepl("count source_url values missing from source_log", result$errors)))
})
```

- [ ] **Step 2: Run the focused tests and verify they fail**

Run:

```powershell
Rscript -e "testthat::test_file('tests/testthat/test-validate_counts.R')"
```

Expected: tests fail because the new validation functions/rules do not exist yet.

- [ ] **Step 3: Add validation helpers to `R/validate_counts.R`**

Add these helpers near `parse_count_values()`:

```r
is_http_url <- function(values) {
  grepl("^https?://[^[:space:]]+$", values)
}

validate_url_values <- function(values, label) {
  errors <- character()
  trimmed <- trimws(as.character(values))

  if (any(is.na(trimmed) | trimmed == "")) {
    errors <- add_message(errors, paste("Missing", label, "values"))
  }
  if (any(!is.na(trimmed) & trimmed != "" & !is_http_url(trimmed))) {
    errors <- add_message(errors, paste("Invalid", label, "values"))
  }
  if (any(grepl("^https?://example\\.org", trimmed))) {
    errors <- add_message(errors, paste("Sample", label, "values"))
  }

  errors
}
```

Update `validate_counts_data()` with these checks after date parsing and before duplicate checks:

```r
  if (all(c("publication_date", "data_cutoff_date") %in% names(data))) {
    valid_date_pairs <- !is.na(publication_dates) & !is.na(cutoff_dates)
    if (any(valid_date_pairs & publication_dates < cutoff_dates)) {
      errors <- add_message(errors, "publication_date before data_cutoff_date")
    }
  }

  if ("source_url" %in% names(data)) {
    errors <- c(errors, validate_url_values(data$source_url, "source_url"))
  }

  if ("case_classification" %in% names(data)) {
    classifications <- tolower(trimws(data$case_classification))
    invalid_classifications <- is.na(classifications) |
      !(classifications %in% c("suspected", "probable", "confirmed", "all"))
    if (any(invalid_classifications)) {
      errors <- add_message(errors, "Invalid case_classification values")
    }
  }

  if ("metric" %in% names(data)) {
    metrics <- tolower(trimws(data$metric))
    invalid_metrics <- is.na(metrics) | !(metrics %in% c("cases", "deaths"))
    if (any(invalid_metrics)) {
      errors <- add_message(errors, "Invalid metric values")
    }
  }
```

Replace the old `source_url` missing-only block so source URLs are checked once.

- [ ] **Step 4: Add source/news validation functions**

Add these functions before `run_validation()`:

```r
validate_source_log_data <- function(data) {
  errors <- character()

  required_columns <- if (exists("required_source_columns")) {
    required_source_columns
  } else {
    c("source_id", "source_name", "title", "url", "publication_date", "retrieved_at",
      "source_type", "country", "keywords", "review_status", "notes")
  }

  missing_columns <- setdiff(required_columns, names(data))
  if (length(missing_columns) > 0) {
    errors <- add_message(errors, paste("Missing required source_log columns:", paste(missing_columns, collapse = ", ")))
    return(list(errors = errors, warnings = character()))
  }

  errors <- c(errors, validate_url_values(data$url, "source_log url"))

  publication_dates <- suppressWarnings(lubridate::ymd(data$publication_date))
  retrieved_at <- suppressWarnings(lubridate::ymd_hms(data$retrieved_at))

  if (any(is.na(publication_dates) & !is.na(data$publication_date))) {
    errors <- add_message(errors, "Invalid source_log publication_date values")
  }
  if (any(is.na(retrieved_at) & !is.na(data$retrieved_at))) {
    errors <- add_message(errors, "Invalid source_log retrieved_at values")
  }

  review_status <- tolower(trimws(data$review_status))
  if (any(is.na(review_status) | !(review_status %in% c("queued", "reviewed", "extracted", "rejected")))) {
    errors <- add_message(errors, "Invalid source_log review_status values")
  }

  if (any(duplicated(data$source_id))) {
    errors <- add_message(errors, "Duplicate source_log source_id values")
  }
  if (any(duplicated(data$url))) {
    errors <- add_message(errors, "Duplicate source_log url values")
  }

  list(errors = errors, warnings = character())
}

validate_news_highlights_data <- function(data) {
  errors <- character()

  required_columns <- if (exists("required_news_columns")) {
    required_news_columns
  } else {
    c("date", "source", "title", "url", "summary", "category", "is_official", "notes")
  }

  missing_columns <- setdiff(required_columns, names(data))
  if (length(missing_columns) > 0) {
    errors <- add_message(errors, paste("Missing required news_highlights columns:", paste(missing_columns, collapse = ", ")))
    return(list(errors = errors, warnings = character()))
  }

  errors <- c(errors, validate_url_values(data$url, "news_highlights url"))

  dates <- suppressWarnings(lubridate::ymd(data$date))
  if (any(is.na(dates) & !is.na(data$date))) {
    errors <- add_message(errors, "Invalid news_highlights date values")
  }

  categories <- tolower(trimws(data$category))
  if (any(is.na(categories) | !(categories %in% c("epidemiology", "response", "policy", "operations", "context")))) {
    errors <- add_message(errors, "Invalid news_highlights category values")
  }

  official <- tolower(trimws(as.character(data$is_official)))
  if (any(is.na(official) | !(official %in% c("true", "false")))) {
    errors <- add_message(errors, "Invalid news_highlights is_official values")
  }

  list(errors = errors, warnings = character())
}

combine_validation_results <- function(results) {
  list(
    errors = unlist(lapply(results, `[[`, "errors"), use.names = FALSE),
    warnings = unlist(lapply(results, `[[`, "warnings"), use.names = FALSE)
  )
}

validate_all_data <- function(counts, source_log, news_highlights) {
  result <- combine_validation_results(list(
    validate_counts_data(counts),
    validate_source_log_data(source_log),
    validate_news_highlights_data(news_highlights)
  ))

  if (all(c("source_url") %in% names(counts)) && "url" %in% names(source_log)) {
    missing_count_urls <- setdiff(unique(counts$source_url), unique(source_log$url))
    if (length(missing_count_urls) > 0) {
      result$errors <- add_message(result$errors, "count source_url values missing from source_log")
    }
  }

  result
}
```

- [ ] **Step 5: Update CLI validation to read all CSVs**

Replace `run_validation()` with:

```r
run_validation <- function(
  counts_path = "data/outbreak_counts.csv",
  source_log_path = "data/source_log.csv",
  news_highlights_path = "data/news_highlights.csv"
) {
  counts <- readr::read_csv(counts_path, show_col_types = FALSE)
  source_log <- readr::read_csv(source_log_path, show_col_types = FALSE)
  news_highlights <- readr::read_csv(news_highlights_path, show_col_types = FALSE)

  result <- validate_all_data(counts, source_log, news_highlights)

  for (warning in result$warnings) {
    message("WARNING: ", warning)
  }
  for (error in result$errors) {
    message("ERROR: ", error)
  }

  if (length(result$errors) > 0) {
    quit(status = 1)
  }

  message("Validation passed")
  invisible(result)
}
```

- [ ] **Step 6: Run tests and validation**

Run:

```powershell
Rscript -e "testthat::test_file('tests/testthat/test-validate_counts.R')"
Rscript tests/testthat.R
Rscript R/validate_counts.R
```

Expected: all commands pass.

- [ ] **Step 7: Commit validation improvements**

Run:

```powershell
git add R/validate_counts.R tests/testthat/test-validate_counts.R
git commit -m "test: strengthen manual curation validation"
```

Expected: commit succeeds.

## Task 3: Improve Dashboard Usability For Real Classifications

**Files:**
- Modify: `app.R`
- Modify: `tests/testthat/test-app-loads.R`

- [ ] **Step 1: Add a smoke assertion for app helpers**

Append this test to `tests/testthat/test-app-loads.R`:

```r
test_that("app.R exposes table link helper", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  expect_true(exists("format_link", envir = env))
  expect_match(env$format_link("https://example.org/report"), "<a href=")
})
```

- [ ] **Step 2: Run the app smoke test and verify it fails**

Run:

```powershell
Rscript -e "testthat::test_file('tests/testthat/test-app-loads.R')"
```

Expected: failure because `format_link()` does not exist yet.

- [ ] **Step 3: Add link and dynamic summary helpers to `app.R`**

Add these helpers after `format_latest_date()`:

```r
format_link <- function(url) {
  paste0("<a href=\"", htmltools::htmlEscape(url), "\" target=\"_blank\" rel=\"noopener noreferrer\">Open</a>")
}

latest_summary_rows <- function(data) {
  if (nrow(data) == 0) {
    return(data.frame(label = character(), value = character(), cutoff = character()))
  }

  data %>%
    filter(count_type == "cumulative") %>%
    group_by(country, case_classification, metric) %>%
    arrange(desc(data_cutoff_date), desc(publication_date), .by_group = TRUE) %>%
    slice_head(n = 1) %>%
    ungroup() %>%
    mutate(
      label = paste(country, case_classification, metric, sep = " - "),
      value = format(count, big.mark = ","),
      cutoff = format(data_cutoff_date, "%Y-%m-%d")
    ) %>%
    arrange(country, metric, case_classification)
}

headline_summary_card <- function(label, value, cutoff) {
  bslib::card(
    class = "dashboard-card",
    bslib::card_body(
      tags$div(class = "card-title", label),
      tags$div(class = "card-value", value),
      tags$div(class = "card-caption", paste("Cutoff", cutoff))
    )
  )
}
```

- [ ] **Step 4: Replace hard-coded DRC/Uganda cards with dynamic cards**

In `ui`, replace the current `bslib::layout_columns(...)` headline card block with:

```r
  uiOutput("headline_cards"),
```

In `server`, remove the hard-coded `headline_subset()` outputs for `drc_*` and `uganda_*`, then add:

```r
  output$headline_cards <- renderUI({
    summary_rows <- latest_summary_rows(filtered_counts())

    if (nrow(summary_rows) == 0) {
      return(bslib::card(bslib::card_body("No data match the current filters.")))
    }

    bslib::layout_columns(
      col_widths = c(12, rep(4, min(nrow(summary_rows), 6))),
      headline_card("Latest cutoff", "latest_cutoff"),
      lapply(seq_len(min(nrow(summary_rows), 6)), function(index) {
        headline_summary_card(
          summary_rows$label[[index]],
          summary_rows$value[[index]],
          summary_rows$cutoff[[index]]
        )
      })
    )
  })
```

Keep `output$latest_cutoff <- renderText(format_latest_date(filtered_counts()))`.

- [ ] **Step 5: Make source and news URLs clickable**

Update `output$source_log_table`:

```r
  output$source_log_table <- renderDT({
    table_data <- source_log %>%
      arrange(desc(publication_date), source_name) %>%
      mutate(link = format_link(url)) %>%
      select(source_name, title, publication_date, link, review_status, notes)

    datatable(
      table_data,
      escape = FALSE,
      rownames = FALSE,
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })
```

Update `output$news_highlights_table`:

```r
  output$news_highlights_table <- renderDT({
    table_data <- news_highlights %>%
      arrange(desc(date), source) %>%
      mutate(link = format_link(url)) %>%
      select(date, source, title, link, summary, category, is_official)

    datatable(
      table_data,
      escape = FALSE,
      rownames = FALSE,
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })
```

- [ ] **Step 6: Add caption styling**

Append to `www/styles.css`:

```css
.dashboard-card .card-caption {
  color: #6c757d;
  font-size: 0.78rem;
  margin-top: 0.35rem;
}
```

- [ ] **Step 7: Run app tests**

Run:

```powershell
Rscript -e "testthat::test_file('tests/testthat/test-app-loads.R')"
Rscript tests/testthat.R
```

Expected: all tests pass.

- [ ] **Step 8: Commit dashboard usability improvements**

Run:

```powershell
git add app.R www/styles.css tests/testthat/test-app-loads.R
git commit -m "feat: improve dashboard for curated classifications"
```

Expected: commit succeeds.

## Task 4: Document Manual Curation Rules

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add a curation conventions section**

Add this section after `## Manual Update Workflow`:

```markdown
## Curation Conventions

Milestone 0.2 uses official/public rows entered by hand. Prefer WHO Disease Outbreak News, WHO AFRO outbreak pages, Ministry of Health statements, CDC advisories, and UN agency operational updates. Media reports may be listed in `data/news_highlights.csv` for context, but do not use them to update `data/outbreak_counts.csv` unless the underlying official count source is also reviewed.

Use `data_cutoff_date` for the date stated by the source as the count reference date. If a single source reports different cutoff dates for different countries or classifications, enter separate rows with the cutoff date that belongs to each count.

Use the source's stated denominator for `case_classification`: `suspected` deaths remain suspected deaths, `confirmed` deaths remain confirmed deaths, and `all` should only be used when the source clearly reports an all-classification total.

Do not add zero rows for countries, classifications, or dates that are absent from a report. Missing report days are unknown, not zero.

Keep `notes` specific enough for a reviewer to find the sentence or table that supports the row.
```

- [ ] **Step 2: Update validation documentation**

Replace the `## Validation Rules` paragraph with:

```markdown
## Validation Rules

`R/validate_counts.R` checks all three manual CSVs. It verifies required columns, parseable dates, nonnegative integer counts, HTTP(S) URLs, absence of sample `example.org` URLs, allowed count types, allowed case classifications, allowed metrics, duplicate rows, duplicate source/country/classification/metric/cutoff combinations, duplicate source-log identifiers, and count URLs that are missing from `data/source_log.csv`. Negative derived increments are printed as warnings because they can reflect reclassification or deduplication and should remain reviewable.
```

- [ ] **Step 3: Run documentation-adjacent verification**

Run:

```powershell
Rscript R/validate_counts.R
Rscript tests/testthat.R
```

Expected: both commands pass.

- [ ] **Step 4: Commit documentation**

Run:

```powershell
git add README.md
git commit -m "docs: document manual curation conventions"
```

Expected: commit succeeds.

## Task 5: Final Milestone 0.2 Verification

**Files:**
- No code changes.

- [ ] **Step 1: Run test suite**

Run:

```powershell
Rscript tests/testthat.R
```

Expected: all tests pass.

- [ ] **Step 2: Run CSV validation**

Run:

```powershell
Rscript R/validate_counts.R
```

Expected: `Validation passed`.

- [ ] **Step 3: Check dependency status**

Run:

```powershell
Rscript -e "renv::status()"
```

Expected: renv reports the project is synchronized.

- [ ] **Step 4: Launch the app locally**

Run:

```powershell
Rscript -e "shiny::runApp(host = '127.0.0.1', port = 3838)"
```

Expected: app starts at `http://127.0.0.1:3838`.

- [ ] **Step 5: Manually inspect the dashboard**

Confirm:

- The latest cutoff reflects 2026-05-21 when all filters are selected.
- Headline cards include DRC suspected cases, DRC suspected deaths, DRC confirmed cases, DRC confirmed deaths, Uganda confirmed cases, and Uganda confirmed deaths.
- Reported increments are visible and are labelled as derived reported increments.
- Source log and news highlight links open the original official source pages.
- No `example.org` values remain in any `data/*.csv` file.

- [ ] **Step 6: Check git status**

Run:

```powershell
git status --short
```

Expected: clean working tree after milestone commits.

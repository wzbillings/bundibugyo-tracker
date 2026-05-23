# Ebola Dashboard Milestone 3 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the manual Ebola dashboard workflow CI-backed, provenance-strict, and clearer when dashboard headline cards hide additional current strata.

**Architecture:** Keep CSV files in `data/` as the source of truth and keep all epidemiologic counts manually curated. Add CI around the existing R scripts, strengthen validation in `R/validate_counts.R`, keep dashboard changes focused in `app.R`, and document the review path without introducing source discovery or deployment.

**Tech Stack:** R, Shiny, bslib, dplyr, readr, lubridate, testthat, renv, GitHub Actions, Markdown.

---

## Scope Summary

Milestone 3 is a stabilization gate before source discovery. The milestone should prove that tests and CSV validation can run in CI, count rows map back to the exact reviewed source identity, source-log duplicate URL checks are whitespace-normalized, and headline cards visibly indicate when more current strata exist than the dashboard displays. Milestone 3 is planned as version tag `0.1.0` unless incremental fixes are needed first.

Do not automate case-count extraction, scrape PDFs, infer zero rows, deploy the app, migrate to a database, or add source discovery in this milestone.

## File Map

- Create `.github/workflows/validate.yml`: CI workflow for tests and CSV validation.
- Create `docs/manual-reviewer-checklist.md`: compact source review and CSV entry checklist.
- Modify `R/validate_counts.R`: add normalization helpers, pair provenance validation, and normalized duplicate URL detection.
- Modify `tests/testthat/test-validate_counts.R`: add failing tests for source-name/URL pair matching and source-log URL normalization.
- Modify `app.R`: add a named headline-card limit and an overflow card when more current strata exist.
- Modify `tests/testthat/test-app-loads.R`: add tests for headline overflow helper behavior.
- Modify `README.md`: link the reviewer checklist and document CI commands.
- Modify `NEWS.md`: add a 0.1.0 section after implementation.
- Modify `TODO.md`: mark milestone 3 work complete and keep later milestones deferred.

## Task 1: Add GitHub Actions CI

**Files:**
- Create: `.github/workflows/validate.yml`
- Modify: `README.md`

- [ ] **Step 1: Create the workflow directory**

Run:

```powershell
New-Item -ItemType Directory -Force .github\workflows
```

Expected: `.github/workflows` exists.

- [ ] **Step 2: Add the validation workflow**

Create `.github/workflows/validate.yml`:

```yaml
name: Validate

on:
  pull_request:
  push:
    branches:
      - main
      - "codex/**"
  workflow_dispatch:

jobs:
  validate:
    name: R tests and CSV validation
    runs-on: ubuntu-latest

    env:
      RENV_CONFIG_SANDBOX_ENABLED: "FALSE"

    steps:
      - name: Check out repository
        uses: actions/checkout@v5

      - name: Set up R
        uses: r-lib/actions/setup-r@v2
        with:
          use-public-rspm: true

      - name: Restore renv library
        uses: r-lib/actions/setup-renv@v2

      - name: Run testthat suite
        run: Rscript tests/testthat.R

      - name: Validate curated CSV data
        run: Rscript R/validate_counts.R
```

Notes for the implementing agent:
- `r-lib/actions` documents `setup-r@v2` and `setup-renv@v2` as the maintained R/renv pattern.
- Do not add `renv::status()` as a failing CI step in this milestone because `docs/next-milestone-prompt.md` documents known R runtime / lockfile drift from milestone 2.

- [ ] **Step 3: Document CI in the README**

In `README.md`, after the validation command in **Manual Update Workflow**, add:

```markdown
The same test and validation commands are also run by GitHub Actions on pull requests and pushes. CI restores packages from `renv.lock`, runs `Rscript tests/testthat.R`, and then runs `Rscript R/validate_counts.R`.
```

- [ ] **Step 4: Commit the CI workflow**

Run:

```powershell
git add .github/workflows/validate.yml README.md
git commit -m "ci: validate tests and curated csv data"
```

Expected: commit succeeds.

## Task 2: Add Manual Reviewer Checklist

**Files:**
- Create: `docs/manual-reviewer-checklist.md`
- Modify: `README.md`

- [ ] **Step 1: Create the checklist document**

Create `docs/manual-reviewer-checklist.md`:

```markdown
# Manual Reviewer Checklist

Use this checklist before editing `data/outbreak_counts.csv`, `data/source_log.csv`, or `data/news_highlights.csv`.

## Source Eligibility

- Prefer WHO Disease Outbreak News, WHO AFRO outbreak pages, Ministry of Health statements, CDC advisories, and UN agency operational updates.
- Treat media reports as contextual news only unless the article links to an official count source that you also review.
- Do not use automatically discovered sources until a human has reviewed them.

## Source Log Entry

- Add one `data/source_log.csv` row per reviewed source.
- Use the source's public title, publication date, URL, source type, country list, keywords, review status, and notes.
- Set `review_status` to `reviewed` only after the source has been read by a human.
- Keep `url` as the canonical source URL, without surrounding whitespace.

## Count Entry

- Add epidemiologic counts only to `data/outbreak_counts.csv`.
- Use `data_cutoff_date` for the source-stated count reference date.
- If one source reports different cutoff dates for different countries, classifications, or metrics, enter separate rows.
- Preserve the source's denominator for `case_classification`: suspected stays suspected, confirmed stays confirmed, and `all` is only for an all-classification total.
- Do not infer zero rows for countries, classifications, metrics, or dates that are absent from a report.
- Keep `notes` specific enough for another reviewer to find the supporting sentence, table, or paragraph.

## News Highlight Entry

- Add contextual headlines to `data/news_highlights.csv`, not to `data/outbreak_counts.csv`.
- Use highlights to preserve response, policy, operations, or epidemiologic context.
- Do not let news highlights drive dashboard counts.

## Validation

- Run `Rscript tests/testthat.R`.
- Run `Rscript R/validate_counts.R`.
- Review warnings about negative derived increments; they may be valid reporting artifacts but should remain visible.
```

- [ ] **Step 2: Link the checklist from README**

In `README.md`, under **Curation Conventions**, add this paragraph before the existing milestone 2 paragraph:

```markdown
Use `docs/manual-reviewer-checklist.md` as the quick review checklist before changing any CSV file.
```

- [ ] **Step 3: Commit the checklist**

Run:

```powershell
git add docs/manual-reviewer-checklist.md README.md
git commit -m "docs: add manual reviewer checklist"
```

Expected: commit succeeds.

## Task 3: Add Failing Provenance And URL Normalization Tests

**Files:**
- Modify: `tests/testthat/test-validate_counts.R`

- [ ] **Step 1: Add source-log fixture support for source names**

Update `valid_source_log_fixture()` so it accepts `source_name`:

```r
valid_source_log_fixture <- function(
  url = "https://www.who.int/example-report",
  source_name = "WHO"
) {
  data.frame(
    source_id = "src-1",
    source_name = source_name,
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
```

- [ ] **Step 2: Add failing test for URL match but source-name mismatch**

Add this test after the existing `validate_all_data flags count urls missing from source log` test:

```r
test_that("validate_all_data requires count source url and source name pair in source log", {
  result <- validate_all_data(
    valid_counts_fixture(),
    valid_source_log_fixture(source_name = "WHO AFRO"),
    valid_news_fixture()
  )

  expect_true(any(grepl("count source_name/source_url pairs missing from source_log", result$errors)))
})
```

- [ ] **Step 3: Add passing test for whitespace-normalized pair matching**

Add this test after the pair-mismatch test:

```r
test_that("validate_all_data matches source provenance pairs after whitespace normalization", {
  counts <- valid_counts_fixture()
  counts$source_name <- "  WHO   "
  counts$source_url <- paste0("  ", counts$source_url, "  ")

  source_log <- valid_source_log_fixture()
  source_log$source_name <- "WHO"
  source_log$url <- paste0(source_log$url, "  ")

  result <- validate_all_data(counts, source_log, valid_news_fixture())

  expect_false(any(grepl("count source_name/source_url pairs missing from source_log", result$errors)))
})
```

- [ ] **Step 4: Add failing test for source-log URL duplicate normalization**

Add this test near the other source-log validator tests:

```r
test_that("validate_source_log_data flags duplicate urls after trimming whitespace", {
  source_log <- rbind(
    valid_source_log_fixture(),
    valid_source_log_fixture(url = "  https://www.who.int/example-report  ")
  )
  source_log$source_id <- c("src-1", "src-2")

  result <- validate_source_log_data(source_log)

  expect_true(any(grepl("Duplicate source_log url values", result$errors)))
})
```

- [ ] **Step 5: Run tests to verify failure**

Run:

```powershell
Rscript tests/testthat.R
```

Expected: test suite fails because validation does not yet require source-name/source-url pairs and does not trim duplicate source-log URLs before comparison.

## Task 4: Implement Provenance And URL Normalization

**Files:**
- Modify: `R/validate_counts.R`
- Modify: `tests/testthat/test-validate_counts.R`

- [ ] **Step 1: Add normalization helpers**

In `R/validate_counts.R`, after `is_missing_value()`, add:

```r
normalize_url_value <- function(values) {
  trimws(as.character(values))
}

normalize_text_value <- function(values) {
  squished <- gsub("[[:space:]]+", " ", trimws(as.character(values)))
  squished
}

source_reference_key <- function(source_name, source_url) {
  paste(normalize_text_value(source_name), normalize_url_value(source_url), sep = "\r")
}
```

- [ ] **Step 2: Normalize duplicate source-log URL checks**

In `validate_source_log_data()`, replace:

```r
if (any(duplicated(data$url))) {
  errors <- add_message(errors, "Duplicate source_log url values")
}
```

with:

```r
normalized_urls <- normalize_url_value(data$url)
normalized_urls <- normalized_urls[!is.na(normalized_urls) & normalized_urls != ""]
if (any(duplicated(normalized_urls))) {
  errors <- add_message(errors, "Duplicate source_log url values")
}
```

- [ ] **Step 3: Replace URL-only provenance validation with pair validation**

In `validate_all_data()`, replace the existing `count source_url values missing from source_log` block with:

```r
if (all(c("source_name", "source_url") %in% names(counts)) && all(c("source_name", "url") %in% names(source_log))) {
  count_source_names <- normalize_text_value(counts$source_name)
  count_urls <- normalize_url_value(counts$source_url)
  source_log_names <- normalize_text_value(source_log$source_name)
  source_log_urls <- normalize_url_value(source_log$url)

  valid_count_pairs <- !is.na(count_source_names) &
    count_source_names != "" &
    !is.na(count_urls) &
    count_urls != ""
  valid_source_pairs <- !is.na(source_log_names) &
    source_log_names != "" &
    !is.na(source_log_urls) &
    source_log_urls != ""

  count_keys <- unique(source_reference_key(
    count_source_names[valid_count_pairs],
    count_urls[valid_count_pairs]
  ))
  source_keys <- unique(source_reference_key(
    source_log_names[valid_source_pairs],
    source_log_urls[valid_source_pairs]
  ))

  missing_count_pairs <- setdiff(count_keys, source_keys)
  if (length(missing_count_pairs) > 0) {
    result$errors <- add_message(result$errors, "count source_name/source_url pairs missing from source_log")
  }
}
```

- [ ] **Step 4: Update existing URL-only tests to pair-message expectations**

Change tests that assert `"count source_url values missing from source_log"` to assert `"count source_name/source_url pairs missing from source_log"` where the failure is now expected from provenance pair validation.

- [ ] **Step 5: Run validation tests**

Run:

```powershell
Rscript tests/testthat.R
```

Expected: validation tests pass.

- [ ] **Step 6: Run curated CSV validation**

Run:

```powershell
Rscript R/validate_counts.R
```

Expected: `Validation passed`.

- [ ] **Step 7: Commit validation changes**

Run:

```powershell
git add R/validate_counts.R tests/testthat/test-validate_counts.R
git commit -m "test: tighten source provenance validation"
```

Expected: commit succeeds.

## Task 5: Add Failing Headline Overflow Tests

**Files:**
- Modify: `tests/testthat/test-app-loads.R`

- [ ] **Step 1: Add a test for the overflow message helper**

Add this test after `latest_summary_rows includes classified death rows`:

```r
test_that("headline overflow text reports hidden current strata", {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(normalizePath(file.path(dirname(old_wd), "..")))

  env <- new.env(parent = globalenv())
  source("app.R", local = env)

  expect_equal(env$headline_overflow_text(8, 6), "+2 more strata")
  expect_equal(env$headline_overflow_text(6, 6), character())
})
```

- [ ] **Step 2: Add a UI helper rendering test for overflow content**

Add this test after `headline cards render without nested layout warning`:

```r
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
```

- [ ] **Step 3: Run tests to verify failure**

Run:

```powershell
Rscript tests/testthat.R
```

Expected: tests fail because `headline_overflow_text()` does not exist yet and no overflow card is rendered.

## Task 6: Implement Headline Overflow Indicator

**Files:**
- Modify: `app.R`
- Modify: `tests/testthat/test-app-loads.R`

- [ ] **Step 1: Add a named headline limit**

In `app.R`, after `count_dates <- range(counts$data_cutoff_date, na.rm = TRUE)`, add:

```r
max_headline_summary_cards <- 6
```

- [ ] **Step 2: Add overflow helper functions**

In `app.R`, after `headline_summary_card()`, add:

```r
headline_overflow_text <- function(total_rows, visible_rows) {
  hidden_rows <- total_rows - visible_rows
  if (hidden_rows <= 0) {
    return(character())
  }

  paste0("+", hidden_rows, " more strata")
}

headline_overflow_card <- function(total_rows, visible_rows) {
  overflow_text <- headline_overflow_text(total_rows, visible_rows)
  if (length(overflow_text) == 0) {
    return(NULL)
  }

  bslib::card(
    class = "dashboard-card",
    bslib::card_body(
      tags$div(class = "card-title", "Additional current strata"),
      tags$div(class = "card-value", overflow_text),
      tags$div(class = "card-caption", "Use filters or tables to review hidden strata")
    )
  )
}
```

- [ ] **Step 3: Use the named limit and append overflow card**

In `output$headline_cards`, replace:

```r
summary_cards <- lapply(seq_len(min(nrow(summary_rows), 6)), function(index) {
```

with:

```r
visible_summary_rows <- min(nrow(summary_rows), max_headline_summary_cards)

summary_cards <- lapply(seq_len(visible_summary_rows), function(index) {
```

Then after the `summary_cards <- ...` block, add:

```r
overflow_card <- headline_overflow_card(nrow(summary_rows), visible_summary_rows)
if (!is.null(overflow_card)) {
  summary_cards <- c(summary_cards, list(overflow_card))
}
```

- [ ] **Step 4: Run app tests**

Run:

```powershell
Rscript tests/testthat.R
```

Expected: app and validation tests pass.

- [ ] **Step 5: Commit headline overflow changes**

Run:

```powershell
git add app.R tests/testthat/test-app-loads.R
git commit -m "feat: show headline overflow indicator"
```

Expected: commit succeeds.

## Task 7: Update Milestone Documentation

**Files:**
- Modify: `README.md`
- Modify: `NEWS.md`
- Modify: `TODO.md`
- Modify: `docs/next-milestone-scope.md`
- Modify: `docs/next-milestone-prompt.md`

- [ ] **Step 1: Update README validation section**

In `README.md`, update **Validation Rules** so it mentions normalized source-name/source-url provenance matching and normalized source-log duplicate URL checks:

```markdown
`R/validate_counts.R` checks all three manual CSVs. It verifies required columns, parseable dates, nonnegative integer counts, HTTP(S) URLs, absence of sample `example.org` URLs, allowed count types, allowed case classifications, allowed metrics, duplicate rows, duplicate source/country/classification/metric/cutoff combinations, duplicate source-log identifiers, normalized duplicate source-log URLs, and count `(source_name, source_url)` pairs that are missing from `data/source_log.csv`. Negative derived increments are printed as warnings because they can reflect reclassification or deduplication and should remain reviewable.
```

- [ ] **Step 2: Update NEWS**

Add this section above `## 0.0.3 - 2026-05-23` in `NEWS.md`:

```markdown
## 0.1.0 - 2026-05-23

Milestone 3 adds CI and stricter manual curation guardrails before any source discovery or deployment work.

### CI

- Added GitHub Actions validation for the R test suite and curated CSV validation script.
- Restored dependencies in CI from `renv.lock`.

### Curation

- Added a manual reviewer checklist for CSV updates.
- Required count rows to match reviewed source-log entries by normalized `(source_name, source_url)` pair.
- Normalized source-log URLs before duplicate checks.

### Dashboard

- Added a visible headline overflow indicator when more than six current summary strata match the active filters.
```

- [ ] **Step 3: Update TODO**

Replace the active milestone section in `TODO.md` with:

```markdown
## Next Milestone Candidate: Milestone 4 - Reviewed Source Discovery Queue

Goal: discover candidate official or humanitarian source updates without writing epidemiologic counts automatically.

- [ ] Add source discovery into a candidate queue or source-log staging file only.
- [ ] Keep discovered sources separate from reviewed `data/source_log.csv` rows until a human marks them reviewed.
- [ ] Add a dashboard or report view for unreviewed candidate sources if it remains lightweight.
- [ ] Do not update `data/outbreak_counts.csv` from source discovery.
```

Keep the existing later milestone and deferred boundaries, adjusting duplicates if needed.

- [ ] **Step 4: Update next prompt**

Revise `docs/next-milestone-prompt.md` so it describes the completed milestone 3 state and points the next agent toward milestone 4 source discovery only after CI passes.

- [ ] **Step 5: Commit documentation**

Run:

```powershell
git add README.md NEWS.md TODO.md docs/next-milestone-scope.md docs/next-milestone-prompt.md
git commit -m "docs: record milestone 3 guardrails"
```

Expected: commit succeeds.

## Task 8: Final Verification

**Files:**
- No new code files beyond prior tasks.

- [ ] **Step 1: Run the test suite**

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

- [ ] **Step 3: Verify workflow file parses as YAML**

Run:

```powershell
Rscript -e "yaml::read_yaml('.github/workflows/validate.yml'); message('Workflow YAML parsed')"
```

Expected: `Workflow YAML parsed`.

- [ ] **Step 4: Review git diff**

Run:

```powershell
git status --short
git log --oneline -5
```

Expected: working tree is clean after milestone commits, and recent commits correspond to CI, checklist, validation, headline overflow, and docs.

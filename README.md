# Ebola Outbreak Monitoring Dashboard

This project is a lightweight R Shiny dashboard for manually curated public Ebola outbreak counts from official and humanitarian sources.

## Data Interpretation

The dashboard tracks publicly reported Ebola outbreak counts from official and humanitarian sources. Most case counts are cumulative and tied to report cutoff dates, not individual symptom-onset dates. Daily incident values shown in the dashboard are derived by differencing cumulative public counts and should be interpreted as reported increments rather than true epidemiologic incidence. Counts may change because of reclassification, deduplication, delayed reporting, or changes in case definitions.

The rows in `data/` are manually reviewed public-source records. Review source notes and validation output before using the dashboard for analysis or communication.

## Setup

This project uses `renv` for a project-local R package library. From the project root, restore dependencies with:

```r
renv::restore()
```

The project currently disables the `renv` sandbox in `.Rprofile` because the sandbox can hang in this Windows/Codex environment. Packages are still installed into the project-local `renv` library and locked in `renv.lock`.

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

## Curation Conventions

Milestone 0.2 uses official/public rows entered by hand. Prefer WHO Disease Outbreak News, WHO AFRO outbreak pages, Ministry of Health statements, CDC advisories, and UN agency operational updates. Media reports may be listed in `data/news_highlights.csv` for context, but do not use them to update `data/outbreak_counts.csv` unless the underlying official count source is also reviewed.

Use `data_cutoff_date` for the date stated by the source as the count reference date. If a single source reports different cutoff dates for different countries or classifications, enter separate rows with the cutoff date that belongs to each count.

Use the source's stated denominator for `case_classification`: `suspected` deaths remain suspected deaths, `confirmed` deaths remain confirmed deaths, and `all` should only be used when the source clearly reports an all-classification total.

Do not add zero rows for countries, classifications, or dates that are absent from a report. Missing report days are unknown, not zero.

Keep `notes` specific enough for a reviewer to find the sentence or table that supports the row.

## Validation Rules

`R/validate_counts.R` checks all three manual CSVs. It verifies required columns, parseable dates, nonnegative integer counts, HTTP(S) URLs, absence of sample `example.org` URLs, allowed count types, allowed case classifications, allowed metrics, duplicate rows, duplicate source/country/classification/metric/cutoff combinations, duplicate source-log identifiers, and count URLs that are missing from `data/source_log.csv`. Negative derived increments are printed as warnings because they can reflect reclassification or deduplication and should remain reviewable.

## First Milestone Scope

The first milestone uses manual CSV entry only. Automated source discovery, scraping, GitHub Actions, deployment, and a curated queryable news database are planned for future milestones after the manual review workflow is trusted.

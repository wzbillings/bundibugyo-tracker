# Ebola Outbreak Monitoring Dashboard

This project is a lightweight R Shiny dashboard for manually curated public Ebola outbreak counts from official and humanitarian sources.

## Data Interpretation

The dashboard tracks publicly reported Ebola outbreak counts from official and humanitarian sources. Most case counts are cumulative and tied to report cutoff dates, not individual symptom-onset dates. Daily incident values shown in the dashboard are derived by differencing cumulative public counts and should be interpreted as reported increments rather than true epidemiologic incidence. Counts may change because of reclassification, deduplication, delayed reporting, or changes in case definitions.

The example rows in `data/` are sample development data. Replace them with reviewed counts before using the dashboard for analysis or communication.

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

## Validation Rules

`R/validate_counts.R` checks that required columns exist, dates parse correctly, counts are nonnegative integers, source URLs are present, `count_type` values are allowed, duplicate rows are flagged, duplicate source/country/classification/metric/cutoff combinations are flagged, and negative derived increments are printed as warnings.

## First Milestone Scope

The first milestone uses manual CSV entry only. Automated source discovery, scraping, GitHub Actions, deployment, and a curated queryable news database are planned for future milestones after the manual review workflow is trusted.

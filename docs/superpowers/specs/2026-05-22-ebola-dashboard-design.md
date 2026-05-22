# Ebola Outbreak Monitoring Dashboard Design

## Goal

Build a lightweight R Shiny dashboard for manually curated public Ebola outbreak counts for the 2026 Democratic Republic of the Congo / Uganda Bundibugyo Ebola outbreak. The first milestone prioritizes a transparent local workflow over automation: users enter and review epidemiologic counts in CSV files, run validation, and then view the dashboard locally.

The dashboard must clearly label counts as publicly reported values from official and humanitarian reports. Derived daily values must be described as reported increments from cumulative public reports, not true symptom-onset or infection-date incidence.

## Scope For Milestone 0.1

Milestone 0.1 includes:

- A working local R Shiny app.
- Manual CSV data entry files with example rows.
- Data cleaning and validation scripts.
- Country-level cumulative and derived reported-increment plots.
- Interactive filtering by source, country, case classification, metric, and date range.
- Source log and news highlights views.
- Persistent caveats and data-quality notes.
- A README explaining the manual update workflow and interpretation limits.

Milestone 0.1 excludes:

- Automated updates to epidemiologic case-count data.
- ReliefWeb or WHO source discovery automation.
- PDF extraction of case counts.
- Google Sheets integration.
- Automated deployment.

## Project Structure

```text
ebola-dashboard/
  app.R
  R/
    clean_counts.R
    make_epicurve_data.R
    validate_counts.R
  data/
    outbreak_counts.csv
    news_highlights.csv
    source_log.csv
  raw_reports/
  www/
  README.md
```

## Data Model

`data/outbreak_counts.csv` is the core manually curated epidemiologic table. Version 0.1 requires these fields:

```text
source_name
source_url
publication_date
data_cutoff_date
country
case_classification
metric
count_type
count
notes
```

Optional fields from the fuller schema may be included later without changing the dashboard contract:

```text
report_id
data_cutoff_time
admin1
health_zone
entered_by
entered_at
```

`data/news_highlights.csv` stores contextual updates and must remain separate from epidemiologic counts unless a count is explicitly curated into `outbreak_counts.csv` with source provenance.

`data/source_log.csv` tracks reviewed official or humanitarian sources. In milestone 0.1 this file is manually edited.

## Data Processing

`R/clean_counts.R` will expose a function that reads or accepts count data and standardizes:

- Date columns using `lubridate`.
- Country names.
- Case classifications.
- Metrics.
- Count types.
- Integer counts.

`R/make_epicurve_data.R` will expose a function that derives incident reported increments from cumulative rows by sorting within:

```text
source_name, country, case_classification, metric
```

The function must not fill missing dates with zero. Negative increments are preserved and flagged because they may reflect reclassification, deduplication, delayed reporting, or changing case definitions.

## Validation

`R/validate_counts.R` will run from the command line and check:

- Required columns exist.
- Dates parse correctly.
- Counts are nonnegative integers.
- Source URLs are present.
- `count_type` is `cumulative` or `incident`.
- Duplicate rows are flagged.
- Duplicate source/country/classification/metric/cutoff-date combinations are flagged.
- Negative derived increments are flagged but not removed.

The script should exit with a nonzero status for hard schema/data failures. Warnings may be printed for reviewable issues such as negative derived increments.

## Dashboard Views

The Shiny UI will use `bslib` for responsive layout and mobile-friendly cards, filters, and panels.

### Overview

Headline cards show latest available values from the currently selected filters where appropriate:

- Latest data cutoff date.
- DRC cumulative suspected cases.
- DRC cumulative confirmed cases.
- DRC deaths.
- Uganda cumulative suspected/confirmed cases.
- Uganda deaths.
- Affected health zones if available in later data.

### Interactive Filters

The main filters are:

- Source.
- Country.
- Case classification.
- Metric.
- Date range.

Source filtering is required because users need to compare or isolate counts from specific official or humanitarian reports.

### Cumulative Curve

Use Plotly-backed interactive line plots for cumulative counts by country and classification. Tooltips should show source, cutoff date, country, classification, metric, and count.

### Reported-Increment Epicurve

Use Plotly-backed interactive bar plots for derived reported increments. The plot must display a visible caveat:

```text
Daily values are derived from changes in cumulative public reports and may reflect reporting artifacts.
```

### Source Log

Use an interactive table for source name, title, publication date, data cutoff date when available, URL, review status, and notes.

### News Highlights

Show recent highlights from `data/news_highlights.csv` as a responsive table or compact cards. News items are context only and do not update the case-count table unless manually curated.

### Caveats Panel

The dashboard must persistently include:

- Public counts may reflect reporting date, not onset date.
- Recent counts are provisional.
- Suspected, probable, and confirmed classifications may be revised.
- Negative daily increments can occur after reclassification or deduplication.
- Missing report days should not be interpreted as zero cases.
- Country-level curves hide subnational heterogeneity.

## Visual And Interaction Design

The app should feel like a practical public-health monitoring workspace rather than a marketing page. The first screen should be the dashboard itself. It should use a compact responsive layout:

- Headline cards at the top.
- Plot panels below cards.
- Source and news panels below plots.
- A persistent caveats panel.

On mobile, cards and panels stack into a single column. Plotly controls and Shiny filters should remain usable without horizontal scrolling where possible.

## Testing And Verification

Before calling the milestone complete:

- Run `Rscript R/validate_counts.R`.
- Source `R/clean_counts.R` and `R/make_epicurve_data.R` in R and verify sample data produces expected columns.
- Launch the Shiny app locally if required packages are installed.
- Confirm the dashboard labels derived increments as reported increments, not onset-date incidence.

## Future Work

After the manual workflow is trusted, later milestones may add:

- ReliefWeb API source discovery.
- WHO, WHO AFRO, CDC, ECDC, Africa CDC, and Ministry source metadata checks.
- GitHub Actions for validation.
- GitHub Actions for source-log discovery only.
- shinyapps.io deployment.
- Google Sheets or another review-friendly data-entry backend.

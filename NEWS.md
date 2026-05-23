# NEWS

## 0.2.0 - 2026-05-23

Milestone 4 adds a reviewed source-discovery queue while keeping reviewed sources and epidemiologic counts manually curated.

### Candidate Queue

- Added `data/source_candidates.csv` as a separate queue for unreviewed or review-tracked candidate source metadata.
- Kept candidate rows separate from reviewed `data/source_log.csv` entries until a human promotes them manually.
- Recorded candidate review state with explicit queue statuses and promotion history fields.

### Validation

- Extended `R/validate_counts.R` to validate candidate queue columns, timestamps, URL quality, duplicate identifiers, normalized duplicate URLs, and review-state rules.
- Kept the reviewed count provenance guardrails unchanged, including normalized `(source_name, source_url)` matching against `data/source_log.csv`.
- Added regression tests for candidate queue validation and dashboard loading.

### Dashboard

- Added a read-only `Candidate Source Queue` table to the dashboard for reviewer context.
- Kept queue edits out of the Shiny UI so random app visitors cannot update review state.
- Preserved existing headline cards, plots, source log, and news views.

### Documentation

- Updated README workflow guidance for the reviewed source-discovery queue and the planned `0.2.0` merge-tag release.
- Prepared milestone 5 scope notes, human-in-the-loop checklist, and next-agent handoff prompt for public deployment hardening.

## 0.1.0 - 2026-05-23

Milestone 3 adds CI and stricter manual curation guardrails before any source discovery or deployment work.

### CI

- Added GitHub Actions validation for the R test suite and curated CSV validation script.
- Restored dependencies in CI from `renv.lock`.

### Curation

- Added a manual reviewer checklist for CSV updates.
- Required count rows to match reviewed source-log entries by normalized `(source_name, source_url)` pair.
- Normalized source-log URLs before duplicate checks.
- Prepared milestone 4 scope, next-agent prompt, and human-in-the-loop handoff checklist.

### Dashboard

- Added a visible headline overflow indicator when more than six current summary strata match the active filters.

## 0.0.3 - 2026-05-23

Documentation cleanup, milestone 3 handoff, and environment alignment verification.

- Updated README milestone, license, and disclaimer sections.
- Consolidated milestone 3 scope so the detailed implementation plan is the source of truth.
- Rewrote the next-agent prompt as a concise handoff.
- Added the milestone 3 implementation plan under `docs/superpowers/plans/`.
- Confirmed the default local `Rscript` launcher now uses R 4.6.0.
- Confirmed `renv::status()` reports the project is in a consistent state under R 4.6.0.
- Re-ran the test suite and curated CSV validation successfully under R 4.6.0.

## 0.0.2 - 2026-05-23

Milestone 2 replaces the milestone 1 sample workflow with a first reviewed public-source dataset and stronger manual curation guardrails.

### Data

- Replaced development-only `example.org` rows with manually curated official/public rows from WHO Disease Outbreak News DON602, WHO Disease Outbreak News DON603, the WHO IHR Emergency Committee statement, and the CDC response statement.
- Preserved the source-reported distinction between suspected deaths and confirmed deaths instead of forcing deaths into an `all` classification.
- Updated `source_log.csv` and `news_highlights.csv` so contextual highlights remain separate from epidemiologic counts.

### Validation

- Expanded validation from the counts CSV to all three manual CSVs.
- Added checks for HTTP(S) URLs, sample `example.org` URLs, allowed case classifications, allowed metrics, missing required dates, source-log duplicate identifiers, and count URLs missing from the source log.
- Added regression tests for URL edge cases, missing curation dates, and source/news validator behavior.

### Dashboard

- Replaced hard-coded DRC/Uganda death headline cards with dynamic headline cards derived from the latest cumulative rows.
- Made source and news tables sort newest-first and show clickable source links.
- Hardened table rendering by escaping data-derived display fields while preserving generated links.

### Documentation

- Added manual curation conventions to the README.
- Added the milestone 2 implementation plan under `docs/superpowers/plans/`.

## 0.0.1 - 2026-05-22

Milestone 1 established the local-first manual CSV dashboard.

### Initial Dashboard

- Added an R Shiny app with a `bslib` dashboard layout, Plotly cumulative and reported-increment plots, DT source/news tables, filters, headline cards, and caveats.
- Added manual CSV files for outbreak counts, source metadata, and contextual news highlights.
- Added R modules for cleaning counts, deriving reported increments from cumulative reports, and validating the counts CSV.
- Added tests for cleaning, increment derivation, validation, and app sourcing.
- Documented setup, interpretation limits, manual update workflow, and first-milestone scope in the README.

### Scope Boundaries

- Kept epidemiologic counts manually curated.
- Treated derived daily values as reported increments from cumulative public reports, not onset-date incidence.
- Preserved negative increments as reviewable reporting artifacts.
- Kept missing report days distinct from zero-case days.

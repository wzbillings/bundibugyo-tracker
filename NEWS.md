# NEWS

## 0.2.1 - 2026-05-23

Documentation cleanup and milestone 0.3 handoff.

- Updated README milestone, license, and disclaimer sections.
- Consolidated milestone 0.3 scope so the detailed implementation plan is the source of truth.
- Rewrote the next-agent prompt as a concise handoff.
- Added the milestone 0.3 implementation plan under `docs/superpowers/plans/`.

## 0.0.2 - 2026-05-23

Milestone 0.2 replaces the milestone 0.1 sample workflow with a first reviewed public-source dataset and stronger manual curation guardrails.

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
- Added the milestone 0.2 implementation plan under `docs/superpowers/plans/`.

## 0.0.1 - 2026-05-22

Milestone 0.1 established the local-first manual CSV dashboard.

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

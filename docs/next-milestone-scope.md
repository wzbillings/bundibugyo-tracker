# Next Milestone Scoping Notes

## Recommended Milestone 0.3

**Theme:** CI and curation guardrails.

Milestone 0.2 made the manual workflow real by replacing sample rows with reviewed official/public source records. The next safest milestone is not source discovery yet; it is making sure future manual edits cannot quietly break tests, validation, or source provenance.

## Proposed 0.3 Goals

1. Add GitHub Actions for the existing R test suite and CSV validation script.
2. Add a concise reviewer checklist for manual CSV entry.
3. Tighten source provenance validation by matching count rows to `source_log.csv` on both `source_url` and `source_name`.
4. Normalize duplicate URL checks in `source_log.csv`.
5. Review the dynamic headline card cap and decide whether to show all latest strata, show top priority strata, or add an overflow indicator.

## Proposed 0.3 Non-Goals

- No automated case-count extraction.
- No PDF scraping.
- No inferred zero-case rows for missing report days.
- No deployment work unless CI is already green.
- No database migration yet.

## Suggested Task Breakdown

### Task 1: GitHub Actions Validation

- Add a workflow that checks out the repo, sets up R, restores `renv`, and runs `Rscript tests/testthat.R`.
- Add the count/source/news CSV validation command: `Rscript R/validate_counts.R`.
- Document expected CI behavior in `README.md`.

### Task 2: Reviewer Checklist

- Add a short checklist under `docs/` for manual source review and CSV entry.
- Include rules for cutoff dates, classification denominators, source URLs, notes, and news/count separation.

### Task 3: Provenance Validation

- Extend validation so every count row has a matching source-log row by URL and source name.
- Add tests for URL/name mismatch, whitespace-normalized matching, and valid matches.

### Task 4: Source URL Normalization Cleanup

- Normalize source-log URLs before duplicate checks.
- Add regression tests for duplicate URLs that differ only by surrounding whitespace.

### Task 5: Dashboard Headline Review

- Decide how the dashboard should behave when more than six latest strata exist.
- Either document the cap, add an overflow indicator, or revise the card layout.

## Recommended Milestone 0.4

After 0.3, consider source discovery into `source_log.csv` only. Discovery should identify candidate source URLs and metadata, but it should not update `outbreak_counts.csv` or extract case counts automatically.

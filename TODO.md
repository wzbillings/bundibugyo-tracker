# TODO

## Next Milestone Candidate: 0.3 - CI And Curation Guardrails

Goal: make the manual workflow harder to break before adding source discovery or deployment.

- [ ] Add GitHub Actions validation for `Rscript tests/testthat.R`.
- [ ] Add GitHub Actions validation for `Rscript R/validate_counts.R`.
- [ ] Document CSV data-entry rules in a compact reviewer checklist.
- [ ] Validate count `(source_url, source_name)` pairs against `data/source_log.csv`.
- [ ] Normalize source-log duplicate URL checks before comparison.
- [ ] Decide whether headline cards should show more than six latest rows or include a visible overflow indicator.

## Later Milestones

- [ ] Add ReliefWeb/WHO source discovery into `data/source_log.csv` only.
- [ ] Add a detected-updates tab that separates machine-discovered source candidates from human-reviewed highlights.
- [ ] Design a curated queryable news database while keeping contextual news separate from epidemiologic counts.
- [ ] Add shinyapps.io deployment after CI and manual validation are trusted.
- [ ] Consider a review-friendly data entry backend after CSV workflow constraints are better understood.

## Deferred From Milestone 0.2

- [ ] Do not automate case-count extraction yet.
- [ ] Do not scrape PDFs for epidemiologic counts yet.
- [ ] Do not infer zero rows for missing report days.
- [ ] Do not merge media-reported context into `data/outbreak_counts.csv` unless the underlying official source is reviewed.

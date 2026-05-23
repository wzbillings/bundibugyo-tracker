# TODO

## Next Milestone Candidate: Milestone 5 - Public Deployment Hardening

Goal: make the dashboard safe to host publicly without changing the manual curation model.

- [ ] Choose the first hosting target, likely shinyapps.io or Posit Connect.
- [ ] Add deployment documentation and required environment assumptions.
- [ ] Add visible public-facing release metadata and validation status in the app.
- [ ] Add a stronger public disclaimer near the top of the app.
- [ ] Decide whether public source/news tables should use the current full view or a reduced default view.
- [ ] Add a pre-deploy checklist that requires tests and CSV validation to pass.
- [ ] Use `docs/milestone-5-human-in-loop-tasks.md` to confirm maintainer decisions before implementation.

## Completed Milestone 4

- [x] Added `data/source_candidates.csv` as a candidate-source review queue.
- [x] Kept candidate sources separate from reviewed `data/source_log.csv` rows until manual promotion.
- [x] Added a read-only dashboard review table for candidate sources.
- [x] Extended `R/validate_counts.R` and tests to cover the candidate queue.
- [x] Kept `data/outbreak_counts.csv` manually curated only.

## Later Milestones

- [ ] Add a detected-updates tab that separates machine-discovered source candidates from human-reviewed highlights.
- [ ] Design a curated queryable news database while keeping contextual news separate from epidemiologic counts.
- [ ] Add shinyapps.io deployment after CI and manual validation are trusted.
- [ ] Consider a review-friendly data entry backend after CSV workflow constraints are better understood.

## Deferred From Milestone 2

- [ ] Do not automate case-count extraction yet.
- [ ] Do not scrape PDFs for epidemiologic counts yet.
- [ ] Do not infer zero rows for missing report days.
- [ ] Do not merge media-reported context into `data/outbreak_counts.csv` unless the underlying official source is reviewed.

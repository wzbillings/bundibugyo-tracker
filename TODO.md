# TODO

## Next Milestone Candidate: Milestone 4 - Reviewed Source Discovery Queue

Goal: discover candidate official or humanitarian source updates without writing epidemiologic counts automatically.

- [ ] Add source discovery into a candidate queue or source-log staging file only.
- [ ] Keep discovered sources separate from reviewed `data/source_log.csv` rows until a human marks them reviewed.
- [ ] Add a dashboard or report view for unreviewed candidate sources if it remains lightweight.
- [ ] Do not update `data/outbreak_counts.csv` from source discovery.

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

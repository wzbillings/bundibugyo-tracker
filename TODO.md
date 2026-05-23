# TODO

## Next Milestone Candidate: Milestone 6 - Review-Friendly Data Maintenance

Goal: reduce maintainer friction around the manual CSV workflow while preserving human review, public read-only hosting, and the separation between reviewed counts, reviewed sources, contextual news, and candidate-source discovery.

- [ ] Decide whether the first maintenance pass should stay fully CSV-native or introduce a lightweight reviewer helper around the CSV workflow.
- [ ] Add review-friendly helper output such as row-validation support, a reviewer summary report, or stricter stale-data warnings.
- [ ] Keep deployment and hosting behavior read-only from the public app.
- [ ] Preserve the manual candidate-source promotion workflow and reviewed count governance model.
- [ ] Use `docs/milestone-6-human-in-loop-tasks.md` to confirm maintainer decisions before implementation.

## Completed Milestone 5

- [x] Added a public disclaimer banner and visible release metadata in the app.
- [x] Reused curated-data validation at app startup and surfaced validation status in the UI.
- [x] Reduced the default public source/news table views while keeping repository data open.
- [x] Added a repo-tracked `VERSION` file plus `shinyapps.io` deployment and pre-deploy checklist docs.
- [x] Added a scripted `shinyapps.io` deployment path that reads secrets from local environment variables.

## Later Milestones

- [ ] Consider Google Sheets, Airtable, or another review-friendly backend only if CSV editing becomes the bottleneck.
- [ ] Design a curated queryable news database while keeping contextual news separate from epidemiologic counts.
- [ ] Add richer public change-history or corrected-count views once the data model stabilizes.
- [ ] Continue planning for independent self-hosting alongside the maintainer's R/Quarto website.

## Deferred From Earlier Milestones

- [ ] Do not automate case-count extraction yet.
- [ ] Do not scrape PDFs for epidemiologic counts yet.
- [ ] Do not infer zero rows for missing report days.
- [ ] Do not merge media-reported context into `data/outbreak_counts.csv` unless the underlying official source is reviewed.

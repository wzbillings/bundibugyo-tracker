# Ebola Outbreak Monitoring Dashboard

This project is a lightweight R Shiny dashboard for manually curated public Ebola outbreak counts from official and humanitarian sources.

## Data Interpretation

The dashboard tracks publicly reported Ebola outbreak counts from official and humanitarian sources. Most case counts are cumulative and tied to report cutoff dates, not individual symptom-onset dates. Daily incident values shown in the dashboard are derived by differencing cumulative public counts and should be interpreted as reported increments rather than true epidemiologic incidence. Counts may change because of reclassification, deduplication, delayed reporting, or changes in case definitions.

The reviewed rows in `data/source_log.csv`, `data/outbreak_counts.csv`, and `data/news_highlights.csv` are manually curated public-source records. `data/source_candidates.csv` is a separate review queue for unreviewed candidate source metadata and does not drive epidemiologic counts. Review source notes and validation output before using the dashboard for analysis or communication.

## Setup

This project uses `renv` for a project-local R package library. From the project root, restore dependencies with:

```r
renv::restore()
```

The project currently disables the `renv` sandbox in `.Rprofile` because the sandbox can hang in this Windows/Codex environment. Packages are still installed into the project-local `renv` library and locked in `renv.lock`.

Public deployment guidance for the Shiny app now lives in `docs/shinyapps-deployment.md`, and the release gate checklist lives in `docs/pre-deploy-checklist.md`.

## Manual Update Workflow

1. Record newly discovered candidate source metadata in `data/source_candidates.csv`.
2. Review an official or humanitarian situation report and decide whether to reject, defer, or promote the candidate manually.
3. Add promoted reviewed source metadata to `data/source_log.csv`.
4. Add any reviewed epidemiologic counts to `data/outbreak_counts.csv`.
5. Add contextual reviewed headlines to `data/news_highlights.csv`.
6. Run validation:

```r
Rscript R/validate_counts.R
```

The same test and validation commands are also run by GitHub Actions on pull requests and pushes. CI restores packages from `renv.lock`, runs `Rscript tests/testthat.R`, and then runs `Rscript R/validate_counts.R`.

7. Start the app:

```r
shiny::runApp()
```

## Curation Conventions

Use `docs/manual-reviewer-checklist.md` as the quick review checklist before changing any CSV file.

Use `data/source_candidates.csv` to queue discovered source metadata for human review. Candidate rows are metadata only, remain separate from reviewed `data/source_log.csv` rows, and do not update the dashboard counts until a human promotes the source and adds any reviewed counts manually.

Milestone 2 uses official/public rows entered by hand. Prefer WHO Disease Outbreak News, WHO AFRO outbreak pages, Ministry of Health statements, CDC advisories, and UN agency operational updates. Media reports may be listed in `data/news_highlights.csv` for context, but do not use them to update `data/outbreak_counts.csv` unless the underlying official count source is also reviewed.

Use `data_cutoff_date` for the date stated by the source as the count reference date. If a single source reports different cutoff dates for different countries or classifications, enter separate rows with the cutoff date that belongs to each count.

Use the source's stated denominator for `case_classification`: `suspected` deaths remain suspected deaths, `confirmed` deaths remain confirmed deaths, and `all` should only be used when the source clearly reports an all-classification total.

Do not add zero rows for countries, classifications, or dates that are absent from a report. Missing report days are unknown, not zero.

Keep `notes` specific enough for a reviewer to find the sentence or table that supports the row.

## Validation Rules

`R/validate_counts.R` checks the reviewed count, reviewed source, news highlight, and candidate-source queue CSVs. It verifies required columns, parseable dates, nonnegative integer counts, HTTP(S) URLs, absence of sample `example.org` URLs, allowed count types, allowed case classifications, allowed metrics, duplicate rows, duplicate source/country/classification/metric/cutoff combinations, duplicate source-log identifiers, normalized duplicate source-log URLs, candidate queue review-state rules, and count `(source_name, source_url)` pairs that are missing from `data/source_log.csv`. Negative derived increments are printed as warnings because they can reflect reclassification or deduplication and should remain reviewable.

## First Milestone Description

The first milestone established the local-first dashboard workflow. It introduced the R Shiny app, manually edited CSV files for outbreak counts, source metadata, and contextual news highlights, and the first validation and test coverage for cleaning counts, deriving reported increments, and loading the app. The goal was to make a transparent manual review loop usable before adding automation.

## Second Milestone Description

The second milestone replaced development-only sample rows with reviewed public-source records from WHO, CDC, and related official or humanitarian sources. It strengthened the manual curation rules, expanded validation across all CSV inputs, preserved source-reported case classifications, made source and news tables easier to review, and hardened table rendering for data-derived display fields.

## Third Milestone Description

The third milestone added CI and curation guardrails before source discovery or deployment. It added GitHub Actions for the R test suite and CSV validation script, documented a compact reviewer checklist for manual data entry, tightened provenance checks between `outbreak_counts.csv` and `source_log.csv`, normalized source URL duplicate checks, and added a visible overflow indicator when more current strata exist than the dashboard headline cards display. This milestone is planned as version tag `0.1.0` unless incremental fixes are needed first.

## Fourth Milestone Description

The fourth milestone added a reviewed source-discovery queue. It records candidate official or humanitarian source URLs and metadata for human review in `data/source_candidates.csv`, validates the queue alongside the existing reviewed CSVs, and exposes a read-only dashboard review table. It does not automate case-count extraction, scrape PDFs for counts, infer zero rows for missing report days, migrate to a database, deploy the app, or update `data/outbreak_counts.csv` from discovered sources. This milestone is planned as version tag `0.2.0` unless incremental fixes are needed first.

## Sixth Milestone Candidate

The next milestone should focus on review-friendly data maintenance after the public deployment hardening pass. It should reduce maintainer friction around the manual CSV workflow without changing the reviewed-source promotion model, introducing public write-back, or collapsing contextual news into epidemiologic counts. See `docs/next-milestone-scope.md` and `docs/milestone-6-human-in-loop-tasks.md` for the current milestone 6 handoff package.

## Future Roadmap

After milestone 5, see `docs/future-roadmap.md` for the current milestone 6 maintenance candidate and later roadmap themes.

## License

This code is licensed under the GNU Affero General Public License v3.0. In brief, AGPL-3.0 allows use, copying, modification, and redistribution under copyleft terms, and it includes source-sharing obligations for modified versions made available over a network. See `LICENSE.md` for the full license text.

## Disclaimer

This project is an independent, unofficial software project for monitoring and summarizing publicly available information. It is not produced, reviewed, endorsed, or approved by the World Health Organization, the U.S. Centers for Disease Control and Prevention, any Ministry of Health, the maintainer’s employer, or any other public-health authority unless explicitly stated.

The dashboard and its outputs are provided for informational and exploratory purposes only. They are not medical advice, public-health guidance, epidemiological certification, operational direction, or an official situation report. The app may contain errors, omissions, delays, misclassified events, duplicated reports, incorrect geocoding, outdated information, software defects, or derived estimates that differ from official counts.

Most of the code in this project was written with substantial assistance from a large language model. A human maintainer reviewed generated code, exercised the application, and checked core functionality, but the project has not undergone the formal validation, quality assurance, peer review, security review, accessibility review, or publication processes used for official public-health reporting systems.

Users should verify all data, summaries, visualizations, and derived values against the original cited sources and, where relevant, against official public-health authorities before using them for research, communication, operational planning, policy, clinical judgment, travel decisions, resource allocation, or any other decision-making purpose.

Use of this project and any associated dashboard, code, data products, or outputs is at the user’s own risk. To the maximum extent permitted by applicable law, the maintainer disclaims responsibility and liability for any decisions, actions, omissions, losses, damages, or consequences arising from use of, reliance on, or inability to use the project or its outputs.

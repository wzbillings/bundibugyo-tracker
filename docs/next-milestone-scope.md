# Next Milestone Scoping Notes

## Completed Milestone 5

**Theme:** Public deployment hardening and first `shinyapps.io` release preparation.

Milestone 5 hardened the public Shiny app shell without changing the repo-backed manual curation model. It added a top-of-app disclaimer banner, visible release metadata, startup validation status, reduced public default source/news table views, a repo-tracked `VERSION` file, a `shinyapps.io` deployment script, and maintainer deployment docs. The candidate queue remains read-only in the app and does not drive epidemiologic counts.

## Recommended Milestone 6

**Theme:** Review-friendly data maintenance.

Milestone 6 should reduce maintainer friction around the manual CSV workflow while preserving human review and the existing separation between reviewed counts, reviewed source metadata, contextual news, and candidate-source discovery.

## Current State

- Manual CSV files in `data/` remain the source of truth.
- `data/source_candidates.csv` stores unreviewed or review-tracked candidate source metadata only.
- `data/source_log.csv` stores reviewed source metadata only.
- `data/outbreak_counts.csv` stores manually curated epidemiologic count rows only.
- `data/news_highlights.csv` stores contextual headlines that do not drive counts.
- The hosted/public app shell is read-only and surfaces a disclaimer banner plus release metadata.
- CI still runs `Rscript tests/testthat.R` and `Rscript R/validate_counts.R`.

## In Scope For Milestone 6

- Reduce manual CSV editing friction while keeping final review decisions human-controlled.
- Add reviewer-oriented helpers such as row-validation support, a reviewer summary report, or stricter stale-data checks.
- Improve maintainers' visibility into candidate promotions, recently changed counts, and validation warnings.
- Keep deployment portability in mind while refining the maintainer workflow.

## Non-Goals For Milestone 6

- No automatic case-count extraction.
- No scheduler-driven updates.
- No write access from the hosted app back into repository data.
- No replacement of the human promotion workflow for candidate sources.
- No forced migration away from CSV-backed reviewed inputs unless a later milestone explicitly approves it.

## Likely Implementation Shape

Prefer a small maintainer-experience pass over the existing scripts and data workflow. A good first pass is a lightweight reviewer helper around the current CSV files, clearer validation/reporting output, and documentation updates that capture what was learned from the first public deployment.

## Acceptance Criteria

- A maintainer can complete a routine reviewed-data update with less friction than in milestone 5.
- Review-focused helper output remains clearly separate from public dashboard output.
- CI and local validation remain the confidence gate before deployment.
- `Rscript tests/testthat.R` passes.
- `Rscript R/validate_counts.R` passes.
- `.github/workflows/validate.yml` remains parseable locally.

## Human Decisions Before Implementation

See `docs/milestone-6-human-in-loop-tasks.md` for the current maintainer checklist before assigning milestone 6.

## Roadmap After Milestone 6

Later milestone candidates remain tracked in `docs/future-roadmap.md`, including longer-term self-hosting and richer reviewer tooling.

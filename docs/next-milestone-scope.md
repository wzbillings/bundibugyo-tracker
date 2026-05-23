# Next Milestone Scoping Notes

## Completed Milestone 4

**Theme:** Reviewed source discovery queue.

Milestone 4 added a CSV-backed candidate-source review queue before any deployment or automated discovery pipeline. It introduced `data/source_candidates.csv`, extended validation to candidate-source metadata and review-state rules, added lightweight tests for the new queue behavior, and exposed a read-only candidate review table in the dashboard without changing the manual curation model for reviewed sources or outbreak counts.

Milestone 4 is prepared for merge as version tag `0.2.0`. The implementation source of truth for the release is the current app, tests, and queue workflow documentation in this repository.

## Recommended Milestone 5

**Theme:** Public deployment hardening and first live deployment.

Milestone 5 should make the dashboard safe to host publicly without changing the repo-backed manual curation model. The work should focus on deployment readiness, public-facing caveats, visible release metadata, a stronger public review checklist, and the first live deployment to a maintainer-approved hosting target.

Milestone 5 should also preserve a clear path toward later independent self-hosting outside a Posit-managed environment, ideally alongside the maintainer's own R/Quarto website. Avoid infrastructure choices that tightly couple the app to Posit-only hosting features when a more portable option is available.

## Current State

- Manual CSV files in `data/` remain the source of truth.
- `data/source_candidates.csv` stores unreviewed or review-tracked candidate source metadata only.
- `data/source_log.csv` stores reviewed source metadata only.
- `data/outbreak_counts.csv` stores manually curated epidemiologic count rows only.
- `data/news_highlights.csv` stores contextual headlines that do not drive counts.
- CI runs `Rscript tests/testthat.R` and `Rscript R/validate_counts.R`.
- Count rows must match reviewed source-log entries by normalized `(source_name, source_url)` pair.
- The dashboard candidate queue is read-only and cannot update queue state.

## In Scope For Milestone 5

- Choose the first hosting target and complete the first live deployment.
- Add deployment documentation and required environment assumptions.
- Prefer deployment assumptions that can later be reproduced on independently managed infrastructure, including a future self-hosted environment alongside an R/Quarto website.
- Add visible public-facing metadata in the app, such as app version, latest data cutoff, latest source publication date, and validation status.
- Add a stronger public disclaimer near the top of the app, not only in repository docs.
- Decide whether public source and news tables should appear exactly as they do now or with a reduced default view.
- Add a pre-deploy checklist that requires tests and CSV validation to pass.

## Non-Goals For Milestone 5

- No database migration.
- No automatic case-count extraction.
- No scheduler-driven updates.
- No write access from the hosted app back into repository data.
- No change to the reviewed-source promotion workflow established in milestone 4.

## Likely Implementation Shape

Prefer a small deployment-hardening pass that keeps the existing Shiny app and CSV-backed workflow intact. A likely first pass is updated deployment docs, a small amount of top-of-app metadata and disclaimer UI, and a release checklist that treats CI and local validation as deployment gates.

## Acceptance Criteria

- A maintainer can deploy the app from a clean checkout using documented steps.
- The first public deployment is live on the selected hosting target.
- The hosted app makes data caveats and source provenance visible before users interpret plots.
- CI and local validation remain the source of confidence before deployment.
- `Rscript tests/testthat.R` passes.
- `Rscript R/validate_counts.R` passes.
- `.github/workflows/validate.yml` remains parseable locally.

## Human Decisions Before Implementation

See `docs/milestone-5-human-in-loop-tasks.md` for the current maintainer checklist to complete before assigning milestone 5.

## Roadmap After Milestone 5

Future milestone candidates are tracked in `docs/future-roadmap.md`, with milestone 6 currently framed as review-friendly data maintenance after public deployment is stable.

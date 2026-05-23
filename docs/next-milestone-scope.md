# Next Milestone Scoping Notes

## Completed Milestone 3

**Theme:** CI and curation guardrails.

Milestone 3 made the manual CSV workflow harder to break before any source discovery, scraping, deployment, or database work. It added CI for tests and CSV validation, added a manual reviewer checklist, tightened source provenance validation to exact reviewed source identity, normalized source-log URL duplicate checks, and added a visible dashboard signal when headline cards hide additional current strata.

Milestone 3 is planned as version tag `0.1.0` unless incremental fixes are needed first. The detailed implementation source of truth was `docs/superpowers/plans/2026-05-23-ebola-dashboard-milestone-0-3.md`.

## Recommended Milestone 4

**Theme:** Reviewed source discovery queue.

Milestone 4 should identify candidate official or humanitarian source updates for human review without writing epidemiologic counts automatically. The work should create a clear separation between machine-discovered candidates, human-reviewed source-log entries, contextual news highlights, and manually curated epidemiologic counts.

## Current State

- Manual CSV files in `data/` remain the source of truth.
- `data/source_log.csv` contains reviewed source metadata.
- `data/outbreak_counts.csv` contains manually curated epidemiologic count rows.
- `data/news_highlights.csv` contains contextual headlines that do not drive counts.
- CI runs `Rscript tests/testthat.R` and `Rscript R/validate_counts.R`.
- Count rows must match reviewed source-log entries by normalized `(source_name, source_url)` pair.

## In Scope For Milestone 4

- Add a candidate-source queue or staging file for discovered source metadata.
- Keep discovered candidates separate from reviewed `data/source_log.csv` rows until a human reviewer promotes them.
- Prefer official and humanitarian sources such as WHO Disease Outbreak News, WHO AFRO pages, Ministry of Health statements, CDC advisories, UN agency updates, and ReliefWeb pages that link to official or humanitarian source material.
- Add validation for the candidate queue if a new CSV is introduced.
- Add lightweight tests for candidate parsing, validation, and any dashboard/report view added in this milestone.
- Add documentation for the candidate review workflow and promotion rules.

## Non-Goals For Milestone 4

- No automated case-count extraction.
- No PDF or webpage scraping into `data/outbreak_counts.csv`.
- No inferred zero rows for missing report days.
- No automatic promotion from discovered candidate to reviewed source-log entry.
- No use of media reports to update epidemiologic counts unless the underlying official count source is reviewed by a human.
- No database migration.
- No deployment unless explicitly rescoped later.
- No hard `renv::status()` CI gate unless R runtime and lockfile expectations have been intentionally reconciled.

## Likely Implementation Shape

Prefer a small, reviewable CSV-backed workflow for milestone 4. A likely first pass is `data/source_candidates.csv` plus one focused R module for candidate validation or normalization, tests under `tests/testthat/`, and a compact dashboard or report view only if it remains lightweight. Do not add a scheduler, background job, database, or count extraction pipeline in this milestone.

## Acceptance Criteria

- Candidate sources can be recorded without changing reviewed source-log rows or epidemiologic counts.
- Candidate rows have enough metadata for a human reviewer to decide whether to promote, reject, or defer the source.
- Any new candidate CSV is validated by local tests and, if appropriate, by `R/validate_counts.R` or a clearly documented companion validator.
- Documentation explains the human review path from candidate to reviewed source-log entry.
- `Rscript tests/testthat.R` passes.
- `Rscript R/validate_counts.R` passes.
- `.github/workflows/validate.yml` remains parseable locally.

## Human Decisions Before Implementation

See `docs/milestone-4-human-in-loop-tasks.md` for the maintainer checklist to complete before assigning milestone 4.

## Roadmap After Milestone 4

Milestone 4 should not absorb public hosting or broader data maintenance work. Future milestone candidates are tracked in `docs/future-roadmap.md`, with milestone 5 currently framed as public deployment hardening once the reviewed source-discovery queue is stable.

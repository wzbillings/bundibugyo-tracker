# Next Milestone Scoping Notes

## Recommended Milestone 0.3

**Theme:** CI and curation guardrails.

Milestone 0.3 should make the manual CSV workflow harder to break before any source discovery, scraping, deployment, or database work begins. The project direction remains a transparent Ebola outbreak monitoring dashboard that can eventually support source discovery, a review queue, and deployment, but automation should first discover candidate sources for human review rather than write epidemiologic counts.

## Scope

Milestone 0.3 is the stabilization gate after milestone 0.2's reviewed public-source seed data. It should add CI for tests and CSV validation, add a manual reviewer checklist, tighten source provenance validation to exact reviewed source identity, normalize source-log URL duplicate checks, and add a visible dashboard signal when headline cards hide additional current strata.

The detailed implementation source of truth is `docs/superpowers/plans/2026-05-23-ebola-dashboard-milestone-0-3.md`.

## Non-Goals

- No automated case-count extraction.
- No PDF or webpage scraping for epidemiologic counts.
- No inferred zero rows for missing report days.
- No ReliefWeb, WHO, CDC, or news source discovery yet.
- No database migration.
- No deployment unless explicitly rescoped later.
- No hard `renv::status()` CI gate while the known R runtime / lockfile drift remains unresolved.

## Acceptance Criteria

- CI runs `Rscript tests/testthat.R` and `Rscript R/validate_counts.R`.
- Maintainers have a compact reviewer checklist for CSV edits.
- Count rows must match reviewed source-log entries by normalized `(source_name, source_url)` pair.
- Source-log duplicate URL checks ignore surrounding whitespace.
- Headline cards visibly indicate when more current strata exist than are displayed.
- Local tests and curated CSV validation pass.

## Recommended Milestone 0.4

After 0.3, consider a reviewed source-discovery queue. It should identify candidate official or humanitarian source URLs and metadata for human review only. It should not update `outbreak_counts.csv`, extract case counts, or mark discovered sources as reviewed without a human step.

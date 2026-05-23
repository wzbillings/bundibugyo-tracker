# Future Roadmap

This roadmap starts after milestone 4. It is intentionally directional: each milestone should still get its own scoped implementation plan before code changes begin.

## Guiding Principles

- Keep epidemiologic counts manually curated until there is a reviewed governance process for any automation.
- Keep contextual news separate from `data/outbreak_counts.csv`.
- Prefer small, auditable CSV-backed workflows before adding databases, schedulers, or services.
- Use CI and validation as gates before public communication or deployment.
- Make every public-facing view clearly state that counts are public reported values, not official case surveillance data.

## Milestone 5 Candidate: Public Deployment Hardening

**Goal:** make the dashboard safe to host publicly without changing the manual curation model.

Recommended scope:

- Choose the first hosting target, likely shinyapps.io or Posit Connect.
- Add deployment documentation and required environment assumptions.
- Keep `data/*.csv` as repo-backed reviewed inputs.
- Add visible public-facing release metadata: app version, latest data cutoff, latest source publication date, and validation status.
- Add a stronger public disclaimer near the top of the app, not only in repository docs.
- Decide whether the public app should expose source/news tables exactly as-is or with a reduced default view.
- Add a pre-deploy checklist that requires tests and CSV validation to pass.

Non-goals:

- No database migration.
- No automatic count extraction.
- No scheduler-driven updates.
- No write access from the hosted app back into repository data.

Acceptance criteria:

- A maintainer can deploy the app from a clean checkout using documented steps.
- The hosted app makes data caveats and source provenance visible before users interpret plots.
- CI and local validation remain the source of confidence before deployment.

## Milestone 6 Candidate: Review-Friendly Data Maintenance

**Goal:** reduce manual CSV editing friction while preserving human review.

Possible directions:

- Add CSV templates or an R helper that validates a proposed row before it is appended manually.
- Add a lightweight reviewer report showing new candidate sources, reviewed source-log rows, count rows, and validation warnings together.
- Consider Google Sheets, Airtable, or another review-friendly input backend only if CSV editing becomes the bottleneck.
- Add stricter validation for required text fields, source statuses, candidate promotion history, and stale data warnings.

Non-goals:

- Do not replace the manual review decision with an automated approval path.
- Do not couple source discovery directly to epidemiologic counts.

## Later Candidates

- Curated queryable news/context database that remains separate from epidemiologic counts.
- Historical data versioning and changelog views for corrected or reclassified counts.
- Subnational geography once source reports are consistent enough to support it.
- More formal source review states and reviewer attribution if multiple maintainers begin curating data.
- Public API or static data export after the data model stabilizes.

## Readiness Gates Before Larger Automation

Do not add automatic count extraction, database migration, or scheduled production ingestion until these are true:

- The candidate-source queue has a clear human promotion workflow.
- Public deployment has a stable disclaimer, provenance display, and validation gate.
- Maintainers have reviewed several update cycles and know which parts of CSV editing are actually painful.
- Negative increments, source corrections, and reclassifications have documented review behavior.

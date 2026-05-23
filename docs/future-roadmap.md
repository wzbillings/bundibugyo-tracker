# Future Roadmap

This roadmap starts after milestone 5. It is intentionally directional: each milestone should still get its own scoped implementation plan before code changes begin.

## Guiding Principles

- Keep epidemiologic counts manually curated until there is a reviewed governance process for any automation.
- Keep contextual news separate from `data/outbreak_counts.csv`.
- Prefer small, auditable CSV-backed workflows before adding databases, schedulers, or services.
- Use CI and validation as gates before public communication or deployment.
- Make every public-facing view clearly state that counts are public reported values, not official case surveillance data.

## Milestone 6 Candidate: Review-Friendly Data Maintenance

**Goal:** reduce maintainer friction around the CSV workflow while preserving human review and the public read-only deployment model.

Recommended scope:

- Add review-friendly helper output such as row-validation support, a reviewer summary report, or stricter stale-data warnings.
- Improve visibility into new candidate sources, recently promoted sources, and count rows changed since the last release.
- Keep `data/*.csv` as repo-backed reviewed inputs.
- Capture lessons learned from the first public deployment without introducing hosted write-back or automation.

Non-goals:

- No automatic count extraction.
- No scheduler-driven updates.
- No write access from the hosted app back into repository data.
- No replacement of the human candidate-promotion workflow.

Acceptance criteria:

- A maintainer can complete a normal reviewed-data update with less friction than in milestone 5.
- Review-focused helper output remains clearly separate from public dashboard output.
- CI and local validation remain the source of confidence before deployment.

## Milestone 7 Candidate: Self-Hosting And Operational Portability

**Goal:** make the hosted deployment easier to migrate off Posit-managed infrastructure and closer to an independently managed Shiny/Quarto setup.

Possible directions:

- Make startup, configuration, and deployment assumptions easier to reproduce on a non-Posit host.
- Review whether the app should live alongside a Quarto website or behind a small reverse-proxy setup.
- Add operational notes for backups, package restore, and host-level environment configuration.

Non-goals:

- Do not re-architect the data model purely for hosting convenience.
- Do not add production automation before the manual review workflow is mature.

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

## Long-Term Hosting Direction

The long-term preference is to self-host the app independently of a Posit-backed server, ideally in a setup that can live alongside the maintainer's own R/Quarto website. Near-term deployment decisions should therefore preserve portability:

- avoid unnecessary dependence on Posit-specific operational features when a portable alternative is reasonable
- keep startup, configuration, and asset assumptions documented in a way that can be reproduced on non-Posit infrastructure
- prefer repository-level docs and app-level metadata/disclaimer behavior that will still make sense after a future hosting migration

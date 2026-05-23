# Milestone 6 Human-In-The-Loop Tasks

Complete or explicitly defer these maintainer decisions before assigning milestone 6.

## Review-Friendly Maintenance Scope

- Confirm that milestone 6 should focus on reducing manual CSV editing friction while preserving human review.
- Confirm that the hosted app should remain read-only during milestone 6.
- Confirm that milestone 6 still excludes automated case-count extraction, scheduler-driven updates, and write-back into repository data.

## Data Entry Workflow Decisions

- Decide whether the first review-friendly maintenance pass should stay fully CSV-native or introduce a lightweight helper around the CSV workflow.
- Decide whether milestone 6 should prioritize:
  - row-validation helpers for maintainers
  - a reviewer summary report
  - stricter stale-data and required-text validation
- Confirm whether any experimental reviewer helper may write repository files automatically, or whether all final CSV edits must still be intentional maintainer actions.

## Reviewer Reporting Decisions

- Decide whether a reviewer-facing report should live as:
  - a generated local report
  - a new dashboard tab
  - a separate maintainer script output
- Decide which review signals are most valuable in the first pass:
  - new candidate sources awaiting review
  - recently promoted sources
  - count rows added since the last release
  - validation warnings such as negative derived increments
  - stale-data warnings

## Deployment Follow-Up

- Confirm whether the first `shinyapps.io` deployment behaved well enough to keep the current hosting setup for milestone 6.
- Note any real-world hosting friction that should influence future self-hosting design.
- Decide whether secret-handling guidance should expand into repository-wide agent/developer instructions during milestone 6.

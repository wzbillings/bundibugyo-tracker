# Milestone 4 Human-In-The-Loop Decisions

This file records the maintainer decisions and boundaries that were used to complete milestone 4.

## Release And CI

- Milestone 4 was implemented on a dedicated feature branch before release tagging.
- Local verification for the milestone remains:
  - `Rscript tests/testthat.R`
  - `Rscript R/validate_counts.R`
  - local YAML parsing of `.github/workflows/validate.yml`

## Source Discovery Boundaries Adopted

- Candidate discovery output remains source metadata only.
- Milestone 4 does not extract case counts, infer zero rows, or edit `data/outbreak_counts.csv`.
- Milestone 4 defines the queue and manual review workflow first and does not depend on live public API integration.
- Preferred early candidate sources remain WHO Disease Outbreak News, WHO AFRO pages, CDC advisories, UN agency operational updates, Ministry of Health statements, and ReliefWeb records that point to official or humanitarian material.

## Candidate Review Workflow Adopted

- Candidate rows live in `data/source_candidates.csv`.
- The queue columns are:
  - `candidate_id`
  - `discovered_at`
  - `source_name`
  - `title`
  - `url`
  - `publication_date`
  - `source_type`
  - `country`
  - `keywords`
  - `discovery_method`
  - `review_status`
  - `review_notes`
  - `reviewed_at`
  - `promoted_source_id`
- Allowed candidate `review_status` values are:
  - `queued`
  - `reviewed`
  - `promoted`
  - `rejected`
  - `deferred`
- Promoted candidates are copied manually into `data/source_log.csv`; milestone 4 does not auto-write reviewed source-log rows.

## Dashboard And Documentation Decisions Adopted

- Milestone 4 includes an in-app candidate review table.
- The table label is `Candidate Source Queue`.
- The queue view is explicitly read-only and must not imply that candidate rows are official, verified, or count-bearing before human review.
- Random app visitors cannot update queue state through the dashboard; queue edits remain repository-managed CSV changes only.

## Follow-On Guidance

- Start milestone 5 from `docs/next-milestone-scope.md`.
- Keep the candidate queue and reviewed-source workflow intact while planning public deployment hardening.

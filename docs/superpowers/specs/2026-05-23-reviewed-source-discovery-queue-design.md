# Milestone 4 Reviewed Source Discovery Queue Design

## Goal

Add a lightweight reviewed source-discovery queue that records candidate official or humanitarian source metadata for human review without changing manually curated epidemiologic counts.

## Scope

### In Scope

- Add a separate CSV-backed queue for discovered source candidates.
- Validate candidate-source metadata with the existing local validation workflow.
- Add lightweight tests for candidate parsing, validation, and any new app helpers or views.
- Add an in-app review table that clearly labels candidate rows as unreviewed metadata, not reviewed count-bearing sources.
- Document the promotion workflow from candidate queue to reviewed `data/source_log.csv`.

### Non-Goals

- No automatic case-count extraction.
- No automatic writes to `data/outbreak_counts.csv`.
- No inferred zero rows for missing report days.
- No automatic promotion from candidate queue to reviewed `data/source_log.csv`.
- No database migration, deployment, scheduler, or background job.
- No hard `renv::status()` CI gate.

## Conservative Assumptions

The milestone 4 human-in-the-loop checklist still lists pre-implementation decisions, so this design adopts the recommended conservative defaults:

- Candidate rows live in `data/source_candidates.csv`.
- Candidate fields are `candidate_id`, `discovered_at`, `source_name`, `title`, `url`, `publication_date`, `source_type`, `country`, `keywords`, `discovery_method`, `review_status`, `review_notes`, `reviewed_at`, and `promoted_source_id`.
- Allowed candidate `review_status` values are `queued`, `reviewed`, `promoted`, `rejected`, and `deferred`.
- Promotion remains manual: a human copies reviewed metadata into `data/source_log.csv`.
- Milestone 4 defines the queue and review workflow first and does not call live public APIs.
- The in-app label should emphasize that candidate sources are unreviewed and do not drive epidemiologic counts.

## Architecture

Milestone 4 extends the current CSV-first workflow rather than introducing a new subsystem. The candidate queue is a fourth manual data file that sits alongside `data/source_log.csv`, `data/outbreak_counts.csv`, and `data/news_highlights.csv`, but remains logically separate from the reviewed-source and count pipelines.

Validation continues to flow through `R/validate_counts.R`, which already serves as the repo's central curation gate. Candidate validation should be added as a focused companion validator within the same script so the existing `Rscript R/validate_counts.R` command continues to cover the full manual workflow.

The app remains a single-file Shiny dashboard for now. Milestone 4 adds one compact table surface for candidate review and keeps the rest of the dashboard behavior unchanged. The candidate table is informational only and must not imply that candidate rows are official, verified, or count-bearing.

## Data Model

`data/source_candidates.csv` should store one row per discovered candidate source.

### Required Fields

- `candidate_id`: stable queue identifier.
- `discovered_at`: timestamp for when the candidate row entered the queue.
- `source_name`: public publisher or source label.
- `title`: public title of the source document or page.
- `url`: canonical candidate URL.
- `publication_date`: source publication date when known.
- `source_type`: coarse source category consistent with the reviewed source log where practical.
- `country`: affected country or semicolon-delimited country list.
- `keywords`: reviewer-friendly terms for triage.
- `discovery_method`: how the candidate entered the queue, such as manual search or curated feed review.
- `review_status`: one of the allowed queue statuses.
- `review_notes`: human review decision notes or triage rationale.
- `reviewed_at`: timestamp for human review when the row leaves `queued`.
- `promoted_source_id`: reviewed `source_log.csv` identifier after manual promotion, otherwise blank.

### State Rules

- `queued` rows may have blank `reviewed_at` and `promoted_source_id`.
- `reviewed`, `rejected`, and `deferred` rows require `reviewed_at`.
- `promoted` rows require both `reviewed_at` and `promoted_source_id`.
- Candidate URLs should be normalized for whitespace during validation and duplicate detection.
- Candidate rows stay separate from `data/source_log.csv` even after promotion; the queue records the review history, while `source_log.csv` remains the reviewed source-of-truth list.

## Validation Design

Add a candidate validator to `R/validate_counts.R` with behavior parallel to the existing source-log and news validators.

### Candidate Validation Checks

- Required columns exist.
- `url` values are present, HTTP(S), and not `example.org`.
- `publication_date` is parseable when present.
- `discovered_at` is required and parseable as a timestamp.
- `reviewed_at` is parseable when present.
- `review_status` is one of the allowed values.
- `candidate_id` values are unique.
- Normalized candidate URLs are unique within the queue unless a future milestone explicitly allows versioned duplicates.
- Status-dependent fields follow the state rules above.

Validation should not require a candidate row to map to `data/source_log.csv`, because queued and rejected candidates are intentionally separate from reviewed sources.

## App Design

Add a compact candidate review table to the dashboard.

### Presentation

- Use a title such as `Candidate Source Queue`.
- Add a short subtitle or caption that states the rows are unreviewed or review-tracked source metadata and do not update epidemiologic counts until a human promotes them.
- Sort newest discovery timestamps first.
- Show the most review-relevant columns first, likely `discovered_at`, `source_name`, `title`, `publication_date`, `link`, `source_type`, `country`, `discovery_method`, `review_status`, and `review_notes`.
- Reuse the existing table-link formatter and HTML escaping pattern so candidate rows render safely.

### Behavior

- The view is read-only.
- No write actions, promotion buttons, or mutation controls in milestone 4.
- Existing plots, filters, headline cards, and count logic should remain unchanged.

## Human Review Workflow

1. Add a discovered source candidate to `data/source_candidates.csv`.
2. Run `Rscript tests/testthat.R` and `Rscript R/validate_counts.R`.
3. Review the candidate in the dashboard or CSV.
4. Mark the candidate as `reviewed`, `rejected`, `deferred`, or `promoted`, adding `review_notes` and `reviewed_at`.
5. If promoted, manually add the reviewed source row to `data/source_log.csv` and record the new `source_id` in `promoted_source_id`.
6. Add any contextual headline to `data/news_highlights.csv` only if appropriate.
7. Add epidemiologic counts to `data/outbreak_counts.csv` only after human review of the promoted source.

## Error Handling

- Invalid candidate rows should fail local validation with explicit messages that match the current validator style.
- Duplicate IDs or normalized URLs should be blocking errors because they undermine review traceability.
- Missing review metadata for non-queued states should be blocking errors because they weaken the audit trail.
- Candidate rows should not be allowed to silently influence count plots, headline cards, or provenance validation.

## Testing Strategy

Add tests at two layers:

- Validator tests for valid candidate fixtures, invalid status values, malformed URLs, duplicate IDs, duplicate normalized URLs, and missing status-dependent review fields.
- App-load tests for candidate queue loading and rendering helpers, with emphasis on safe link rendering and the presence of the new candidate table output.

Regression risk is moderate because the validator command and app file both widen in scope. Existing count, source-log, and news behavior should remain covered by the current tests and by the full validation run.

## Acceptance Mapping

- Candidate sources can be recorded without changing reviewed sources or count rows: handled by separate `data/source_candidates.csv` and a read-only app table.
- Candidate rows have enough metadata for promotion, rejection, or deferral: handled by the required fields and status rules.
- New candidate CSV is validated by local tests and the existing validation command: handled by adding candidate validation to `R/validate_counts.R` and test coverage.
- Documentation explains the review path: handled by README, milestone docs, and the workflow section above.
- Verification commands remain the same: `Rscript tests/testthat.R`, `Rscript R/validate_counts.R`, and local workflow YAML parsing.

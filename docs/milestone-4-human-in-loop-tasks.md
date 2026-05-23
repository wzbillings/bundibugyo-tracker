# Milestone 4 Human-In-The-Loop Tasks

Complete or explicitly defer these maintainer tasks before assigning the next agent to milestone 4.

## Release And CI

- Confirm the `0.1.0` tag points to the milestone 3 guardrails commit after it is pushed.
- Confirm GitHub Actions runs successfully for the pushed milestone 3 branch or tag.
- Decide whether milestone 4 should branch from `main` after merging milestone 3, or from the `0.1.0` tag if milestone 3 will remain unmerged for a while.

## Source Discovery Boundaries

- Confirm the first candidate sources to support. Recommended starting set: WHO Disease Outbreak News, WHO AFRO outbreak pages, CDC advisories, UN agency operational updates, Ministry of Health statements, and ReliefWeb records that link to official or humanitarian sources.
- Confirm whether milestone 4 may call public APIs such as ReliefWeb, or whether it should only define the queue and manual entry workflow first.
- Confirm that discovery output must remain source metadata only: no extracted case counts, no inferred zeros, and no automatic edits to `data/outbreak_counts.csv`.

## Candidate Review Workflow

- Decide whether candidate rows should live in `data/source_candidates.csv` or another staging file name.
- Decide the minimum candidate fields before implementation. Recommended fields: `candidate_id`, `discovered_at`, `source_name`, `title`, `url`, `publication_date`, `source_type`, `country`, `keywords`, `discovery_method`, `review_status`, `review_notes`, `reviewed_at`, and `promoted_source_id`.
- Decide the allowed candidate `review_status` values. Recommended values: `queued`, `reviewed`, `promoted`, `rejected`, and `deferred`.
- Decide whether promoted candidates are copied manually into `data/source_log.csv` or whether milestone 4 should include a helper that prepares a reviewer-approved source-log row without writing it automatically.

## Dashboard And Documentation

- Decide whether milestone 4 should add an in-app candidate review table, a separate report, or only CSV validation plus documentation.
- Provide any preferred labels for the candidate queue so the UI does not imply sources are official, verified, or count-bearing before human review.
- Review `docs/next-milestone-prompt.md` and adjust any local constraints before starting the next agent.

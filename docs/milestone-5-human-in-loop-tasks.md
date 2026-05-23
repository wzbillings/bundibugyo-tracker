# Milestone 5 Human-In-The-Loop Tasks

Complete or explicitly defer these maintainer tasks before assigning the next agent to milestone 5.

## Release And Branching

- Confirm the `0.2.0` tag should target the merge commit for PR #3 after milestone 4 is accepted.
- Confirm GitHub Actions runs successfully on `main` after the milestone 4 merge.
- Branch milestone 5 from updated `main` unless there is a specific reason to branch from the `0.2.0` tag.

## Hosting Decision

- Choose the first hosting target. Recommended starting options:
  - shinyapps.io for the fastest first public deployment
  - Posit Connect if there is already an available managed environment
- Confirm that milestone 5 should include the first live deployment, not only deployment hardening documentation and UI safeguards.
- Note the long-term hosting direction: the app should eventually be self-hostable independently of a Posit-backed server, preferably alongside the maintainer's own R/Quarto website.
- Prefer hosting and deployment steps that minimize lock-in to Posit-only platform features unless there is a clear milestone 5 need.

## Public App Boundaries

- Confirm that hosted app users must not be able to edit `data/source_candidates.csv`, `data/source_log.csv`, `data/outbreak_counts.csv`, or `data/news_highlights.csv`.
- Confirm that milestone 5 should keep `data/*.csv` as repo-backed reviewed inputs with no database migration.
- Confirm that milestone 5 still excludes automated case-count extraction, scheduler-driven updates, and write-back from the hosted app into repository data.

## Public Presentation Decisions

- Decide which release metadata should be visible in the app by default. Recommended minimum set:
  - app version
  - latest count cutoff date
  - latest reviewed source publication date
  - validation status
- Decide whether public source and news tables should remain fully visible by default or ship with a reduced default view.
- Review the current disclaimer language and note whether milestone 5 should:
  - reuse it near the top of the app
  - shorten it for the app shell
  - keep the full repository disclaimer unchanged

## Deployment Inputs

- Confirm whether any hosting secrets, account identifiers, or deployment configuration should stay outside the repository.
- Confirm whether a pre-deploy checklist should live in the README, a dedicated deployment doc, or both.
- Confirm which deployment details should be documented specifically to preserve a later migration path to independent self-hosting.
- Review `docs/next-milestone-prompt.md` and adjust any local constraints before starting the next agent.

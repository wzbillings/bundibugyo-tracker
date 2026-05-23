# Milestone 5 Human-In-The-Loop Tasks

Complete or explicitly defer these maintainer tasks before assigning the next agent to milestone 5.
Comments marked with "ZB" indicate my notes added during a manual review.

## Release And Branching

- Confirm the `0.2.0` tag should target the merge commit for PR #3 after milestone 4 is accepted.
	- ZB: confirmed that this is correct, and it appears to be already done.
- Confirm GitHub Actions runs successfully on `main` after the milestone 4 merge.
	- ZB: confirmed, we never merge a PR unless the CI checks pass. Update any documentation you need to note that I will
		not merge PRs until the CI checks pass.
- Branch milestone 5 from updated `main` unless there is a specific reason to branch from the `0.2.0` tag.
	- ZB: correct, branch from main.
	- ZB: note that milestone 5 will target version 0.3.0 tag and release as the merge commit
		for merging the milestone 5 branch PR into main.
	- ZB: any incremental changes will target a current patch tag (increment the third digit), and
		any post-merge checks and updates will target 0.3.X patch versions.

## Hosting Decision

- Choose the first hosting target. Recommended starting options:
  - shinyapps.io for the fastest first public deployment
  - Posit Connect if there is already an available managed environment
  - ZB: we will target a shinyapps.io release for the first hosting target. By the
	time we are ready to independently host and deal with the more complex needs that
	posit connect supports, we should be ready to migrate to hosting on my website,
	however that needs to happen.
- Confirm that milestone 5 should include the first live deployment, not only deployment hardening documentation and UI safeguards.
	ZB: milestone 5 should include the first live deployment.
- Note the long-term hosting direction: the app should eventually be self-hostable independently of a Posit-backed server, preferably alongside the maintainer's own R/Quarto website.
	ZB: correct, do not make simplifying infrastructure changes if they will make this long-term goal more difficult.
- Prefer hosting and deployment steps that minimize lock-in to Posit-only platform features unless there is a clear milestone 5 need.
	ZB: correct. lock-in features are approved only as necessary to host an MVP on shinyapps.io, there should be
	minimal friction with the change to self-hosting on my site in the future.

## Public App Boundaries

- Confirm that hosted app users must not be able to edit `data/source_candidates.csv`, `data/source_log.csv`, `data/outbreak_counts.csv`, or `data/news_highlights.csv`.
	ZB: confirmed. The app should act as an epidemic dashboard with news sources for visitors, only the dev team (right now just me)
	should be able to edit any data.
- Confirm that milestone 5 should keep `data/*.csv` as repo-backed reviewed inputs with no database migration.
	ZB: confirmed, automatic data integrating is targeted for a future milestone after an MVP is launched.
- Confirm that milestone 5 still excludes automated case-count extraction, scheduler-driven updates, and write-back from the hosted app into repository data.
	ZB: confirmed, automatic data integration is targeted for a post-MVP future milestone.

## Public Presentation Decisions

- Decide which release metadata should be visible in the app by default. Recommended minimum set:
  - app version (ZB: approved)
  - latest count cutoff date (ZB: approved)
  - latest reviewed source publication date (ZB: approved)
  - validation status (ZB: approved)
  - ZB: refer to any online epi dashboards or standards you can find to determine what should be shown in the UI.
  - ZB: for a future milestone, we will have an agent act as a professional UI/UX reviewer.
- Decide whether public source and news tables should remain fully visible by default or ship with a reduced default view.
	ZB: all data will be open source and accessible, users will just not have write access.
	ZB: we will curate what is initially displayed to the most useful public-facing information, but direct users
		to the GitHub source for open source other information.
- Review the current disclaimer language and note whether milestone 5 should:
  - reuse it near the top of the app
  - shorten it for the app shell
  - keep the full repository disclaimer unchanged

## Deployment Inputs

- Confirm whether any hosting secrets, account identifiers, or deployment configuration should stay outside the repository.
	ZB: yes, all secrets should avoid being hosted on Git since the repo is public and will always be open source.
	ZB: attempt to git vaccinate following usethis protocols and standard data safety protocols in the next milestone, and update
		all agent instructions so that protecting secret information is always in the dev instructions.
- Confirm whether a pre-deploy checklist should live in the README, a dedicated deployment doc, or both.
	ZB: pre-deploy checklist does not need to live in the README, which is a public-facing introduction. Code tasks
		should live in the docs that are not intended to be public facing (but are still open source).
- Confirm which deployment details should be documented specifically to preserve a later migration path to independent self-hosting.
	ZB: I am not an expert in this area and prefer the next agent to provide and recommend options for this.
- Review `docs/next-milestone-prompt.md` and adjust any local constraints before starting the next agent.
	ZB: reviewed and no edits needed.

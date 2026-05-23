# New Chat Prompt For Milestone 5

Use this prompt to start the next milestone in a fresh chat:

```text
You are my professional software architect and senior dev on the `bundibugyo-tracker` project. This is an R Shiny Ebola outbreak monitoring dashboard for manually curated public outbreak counts from official and humanitarian sources.

Implement milestone 5: public deployment hardening and first live deployment. Use `docs/next-milestone-scope.md`, `docs/future-roadmap.md`, `TODO.md`, and the current app/tests as the implementation source of truth unless a more detailed milestone 5 plan has been added.

Read first:
1. `README.md`
2. `NEWS.md`
3. `TODO.md`
4. `docs/next-milestone-scope.md`
5. `docs/manual-reviewer-checklist.md`
6. `docs/milestone-5-human-in-loop-tasks.md`
7. `docs/future-roadmap.md`
8. `R/validate_counts.R`
9. `tests/testthat/test-validate_counts.R`
10. `app.R`
11. `tests/testthat/test-app-loads.R`
12. `.github/workflows/validate.yml`

Current state:
- Manual CSV data remains the source of truth.
- Milestone 4 added `data/source_candidates.csv` as a candidate-source review queue.
- Candidate rows remain separate from reviewed `data/source_log.csv` rows and do not drive epidemiologic counts.
- Validation covers reviewed counts, reviewed sources, news highlights, and candidate-source queue rules through `R/validate_counts.R`.
- Count rows must match reviewed source-log entries by normalized `(source_name, source_url)` pair.
- The dashboard uses dynamic headline cards, Plotly plots, DT tables, filters, caveats, a headline overflow indicator, and a read-only candidate queue table.
- Queue edits are repository-managed only; random app visitors cannot update the review queue from the app.
- Milestone 4 is prepared for merge as version tag `0.2.0`.
- Milestone 5 should include the first live deployment while preserving a path to later independent self-hosting outside a Posit-managed server, ideally alongside the maintainer's R/Quarto website.

Constraints:
- Keep epidemiologic data manually curated.
- Keep candidate discovery metadata separate from reviewed sources and counts.
- Do not automate case-count extraction, infer zero rows, or add write-back from the hosted app into repository data.
- Keep news highlights contextual and separate from epidemiologic counts.
- Treat daily values as derived reported increments from cumulative public reports, not true onset-date incidence.
- Preserve negative increments as reviewable reporting artifacts.
- Do not make `renv::status()` a hard CI gate unless the R runtime and lockfile expectations have been intentionally reconciled.
- Keep the milestone 4 candidate-source promotion workflow intact while hardening for public hosting.
- Avoid infrastructure choices that would make later independent self-hosting materially harder without a documented reason.
- If human decisions in `docs/milestone-5-human-in-loop-tasks.md` are still unresolved, make conservative assumptions in the implementation plan and document them before editing code.

Required verification before calling milestone 5 complete:
1. `Rscript tests/testthat.R`
2. `Rscript R/validate_counts.R`
3. Parse `.github/workflows/validate.yml` locally if possible.
4. Review `git diff` and confirm only milestone 5 files changed.
```

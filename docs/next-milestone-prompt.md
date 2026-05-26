# New Chat Prompt For Milestone 6

Use this prompt to start the next milestone in a fresh chat:

```text
You are my professional software architect and senior dev on the `bundibugyo-tracker` project. This is an R Shiny Ebola outbreak monitoring dashboard for manually curated public outbreak counts from official and humanitarian sources.

Implement milestone 6: review-friendly data maintenance. Use `docs/next-milestone-scope.md`, `docs/future-roadmap.md`, `TODO.md`, and the current app/tests as the implementation source of truth unless a more detailed milestone 6 plan has been added.

Read first:
1. `README.md`
2. `NEWS.md`
3. `TODO.md`
4. `docs/next-milestone-scope.md`
5. `docs/manual-reviewer-checklist.md`
6. `docs/milestone-6-human-in-loop-tasks.md`
7. `docs/future-roadmap.md`
8. `R/validate_counts.R`
9. `tests/testthat/test-validate_counts.R`
10. `app.R`
11. `tests/testthat/test-app-loads.R`
12. `.github/workflows/validate.yml`

Current state:
- Manual CSV data remains the source of truth.
- `data/source_candidates.csv` remains a candidate-source review queue separate from reviewed sources and counts.
- Count rows must still match reviewed source-log entries by normalized `(source_name, source_url)` pair.
- Validation covers reviewed counts, reviewed sources, news highlights, and candidate-source queue rules through `R/validate_counts.R`.
- The dashboard is publicly hardening-aware: it shows a top-of-app disclaimer, release metadata, validation status, and reduced default public table views.
- Queue edits remain repository-managed only; public app visitors cannot update the review queue from the app.
- Milestone 5 introduced deployment docs and a `shinyapps.io` deployment script while preserving a later path to self-hosting.

Constraints:
- Keep epidemiologic data manually curated.
- Keep candidate discovery metadata separate from reviewed sources and counts.
- Do not automate case-count extraction, infer zero rows, or add write-back from the hosted app into repository data.
- Keep news highlights contextual and separate from epidemiologic counts.
- Treat daily values as derived reported increments from cumulative public reports, not true onset-date incidence.
- Preserve negative increments as reviewable reporting artifacts.
- Do not make `renv::status()` a hard CI gate unless the R runtime and lockfile expectations have been intentionally reconciled.
- Keep the candidate-source promotion workflow intact while improving reviewer ergonomics.

Required verification before calling milestone 6 complete:
1. `Rscript tests/testthat.R`
2. `Rscript R/validate_counts.R`
3. Parse `.github/workflows/validate.yml` locally if possible.
4. Review `git diff` and confirm only milestone 6 files changed.
```

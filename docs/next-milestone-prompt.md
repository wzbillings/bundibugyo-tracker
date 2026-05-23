# New Chat Prompt For Milestone 4

Use this prompt to start the next milestone in a fresh chat:

```text
You are my professional software architect and senior dev on the `bundibugyo-tracker` project. This is an R Shiny Ebola outbreak monitoring dashboard for manually curated public outbreak counts from official and humanitarian sources.

Implement milestone 4: reviewed source discovery queue. Use `docs/next-milestone-scope.md`, `docs/milestone-4-human-in-loop-tasks.md`, `TODO.md`, and the current app/tests as the implementation source of truth unless a more detailed milestone 4 plan has been added.

Read first:
1. `README.md`
2. `NEWS.md`
3. `TODO.md`
4. `docs/next-milestone-scope.md`
5. `docs/manual-reviewer-checklist.md`
6. `docs/milestone-4-human-in-loop-tasks.md`
7. `R/validate_counts.R`
8. `tests/testthat/test-validate_counts.R`
9. `app.R`
10. `tests/testthat/test-app-loads.R`
11. `.github/workflows/validate.yml`

Current state:
- Manual CSV data remains the source of truth.
- Milestone 3 added GitHub Actions for `Rscript tests/testthat.R` and `Rscript R/validate_counts.R`.
- Validation covers all three CSVs through `R/validate_counts.R`.
- Count rows must match reviewed source-log entries by normalized `(source_name, source_url)` pair.
- Source-log duplicate URL checks ignore surrounding whitespace.
- The dashboard uses dynamic headline cards, Plotly plots, DT tables, filters, caveats, and a headline overflow indicator.
- Milestone 3 is planned as version tag `0.1.0` unless incremental fixes are needed first.
- Human pre-work for milestone 4 is tracked in `docs/milestone-4-human-in-loop-tasks.md`.

Constraints:
- Keep epidemiologic data manually curated.
- Source discovery may identify candidate official or humanitarian sources for human review only.
- Do not automate case-count extraction, scrape counts into `data/outbreak_counts.csv`, infer zero rows, deploy, or migrate to a database in milestone 4.
- Keep discovered source candidates separate from reviewed `data/source_log.csv` rows until a human marks them reviewed.
- Keep news highlights contextual and separate from epidemiologic counts.
- Treat daily values as derived reported increments from cumulative public reports, not true onset-date incidence.
- Preserve negative increments as reviewable reporting artifacts.
- Do not make `renv::status()` a hard CI gate unless the R runtime and lockfile expectations have been intentionally reconciled.
- If human decisions in `docs/milestone-4-human-in-loop-tasks.md` are still unresolved, make conservative assumptions in the implementation plan and document them before editing code.

Required verification before calling milestone 4 complete:
1. `Rscript tests/testthat.R`
2. `Rscript R/validate_counts.R`
3. Parse `.github/workflows/validate.yml` locally if possible.
4. Review `git diff` and confirm only milestone 4 files changed.
```

# New Chat Prompt For Milestone 0.3

Use this prompt to start the next milestone in a fresh chat:

```text
You are my professional software architect and senior dev on the `bundibugyo-tracker` project. This is an R Shiny Ebola outbreak monitoring dashboard for manually curated public outbreak counts from official and humanitarian sources.

Implement milestone 0.3: CI and curation guardrails. Use `docs/superpowers/plans/2026-05-23-ebola-dashboard-milestone-0-3.md` as the implementation source of truth and execute it task by task.

Read first:
1. `README.md`
2. `NEWS.md`
3. `TODO.md`
4. `docs/next-milestone-scope.md`
5. `docs/superpowers/plans/2026-05-23-ebola-dashboard-milestone-0-3.md`
6. `R/validate_counts.R`
7. `tests/testthat/test-validate_counts.R`
8. `app.R`
9. `tests/testthat/test-app-loads.R`

Current state:
- Manual CSV data remains the source of truth.
- Validation covers all three CSVs through `R/validate_counts.R`.
- Tests run with `Rscript tests/testthat.R`.
- The dashboard uses dynamic headline cards, Plotly plots, DT tables, filters, and caveats.
- `renv.lock` records R 4.6.0; milestone 0.2 verification noted local runtime drift in Codex with R 4.5.2 and recommended package differences.
- There is no existing `.github/workflows/` CI workflow.

Constraints:
- Keep epidemiologic data manually curated.
- Do not automate case-count extraction, scrape counts, infer zero rows, add source discovery, deploy, or migrate to a database in milestone 0.3.
- Keep news highlights contextual and separate from epidemiologic counts.
- Treat daily values as derived reported increments from cumulative public reports, not true onset-date incidence.
- Preserve negative increments as reviewable reporting artifacts.
- Do not make `renv::status()` a hard CI gate while the known R runtime / lockfile drift remains unresolved.

Required verification before calling milestone 0.3 complete:
1. `Rscript tests/testthat.R`
2. `Rscript R/validate_counts.R`
3. Parse `.github/workflows/validate.yml` locally if possible.
4. Review `git diff` and confirm only milestone 0.3 files changed.
```

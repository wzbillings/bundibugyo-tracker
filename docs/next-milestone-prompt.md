# New Chat Prompt For Next Milestone

Use this prompt to start the next milestone in a fresh chat:

```text
You are my senior dev on the `bundibugyo-tracker` project. This is an R Shiny Ebola outbreak monitoring dashboard. We completed milestone 0.2 on branch `codex-milestone-0-2`.

Current project state:
- Manual CSV data remains the source of truth.
- `data/outbreak_counts.csv` contains reviewed official/public seed rows from WHO DON602 and DON603.
- `data/source_log.csv` contains reviewed source metadata for WHO DON602, WHO DON603, the WHO IHR Emergency Committee statement, and CDC context.
- `data/news_highlights.csv` contains contextual highlights only; it does not drive epidemiologic counts.
- Validation now covers all three CSVs through `R/validate_counts.R`.
- Tests live under `tests/testthat/` and are run with `Rscript tests/testthat.R`.
- The dashboard in `app.R` uses dynamic headline cards, Plotly plots, DT tables, filters, and caveats.
- `NEWS.md`, `TODO.md`, `docs/next-milestone-scope.md`, and the milestone 0.2 plan document the release and next suggested work.

Important constraints:
- Keep epidemiologic data manually curated for now.
- Do not automate case-count extraction or update `outbreak_counts.csv` from source discovery.
- Daily values are derived reported increments from cumulative public reports, not true onset-date incidence.
- Preserve negative increments as reviewable reporting artifacts.
- Missing report days are not zero-case days.
- News highlights are contextual and separate from core epidemiologic counts.

Verification at milestone 0.2:
- `Rscript tests/testthat.R` passed.
- `Rscript R/validate_counts.R` passed.
- Live Shiny HTTP check returned status 200 and served the dashboard shell.
- `renv::status()` reported pre-existing runtime drift: the lockfile was generated with R 4.6.0 while the local runtime used by Codex was R 4.5.2, plus recommended package version differences.

Recommended next milestone:
Milestone 0.3 should focus on CI and curation guardrails before source discovery:
1. Add GitHub Actions for `Rscript tests/testthat.R`.
2. Add GitHub Actions for `Rscript R/validate_counts.R`.
3. Add a manual reviewer checklist for CSV curation.
4. Validate count `(source_url, source_name)` pairs against `source_log.csv`.
5. Normalize duplicate source-log URL checks.
6. Decide how dynamic headline cards should behave when more than six latest strata exist.

Start by inspecting `NEWS.md`, `TODO.md`, `docs/next-milestone-scope.md`, `R/validate_counts.R`, `.github/` if present, and `renv.lock`. Then create a milestone 0.3 plan before implementing.
```

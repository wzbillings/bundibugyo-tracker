# Pre-Deploy Checklist

Use this checklist before every public deployment of the dashboard.

## Required Validation

- Run `Rscript tests/testthat.R`.
- Run `Rscript R/validate_counts.R`.
- Run `Rscript -e "parsed <- yaml::read_yaml('.github/workflows/validate.yml'); stopifnot('on' %in% names(parsed)); message('Workflow YAML parsed')"`
- Review warnings from `R/validate_counts.R`, especially negative derived increments.
- Review `git diff --name-only` and confirm only intended milestone or patch files changed.

## Curated Data Review

- Confirm `data/outbreak_counts.csv` remains manually curated.
- Confirm candidate rows in `data/source_candidates.csv` are still separate from reviewed rows in `data/source_log.csv`.
- Confirm no app code adds write-back, scheduler-driven updates, or automatic case-count extraction.
- Confirm the app banner, metadata cards, and caveats still match the current public disclaimer and provenance expectations.

## Deployment Readiness

- Confirm `VERSION` matches the intended release.
- Confirm `NEWS.md` describes the release before any tag is created.
- Confirm `README.md` still points readers to the repository disclaimer and manual workflow.
- Confirm `SHINYAPPS_NAME`, `SHINYAPPS_TOKEN`, and `SHINYAPPS_SECRET` are available outside the repository.
- Confirm `rsconnect` is installed locally. If needed, run `Rscript -e "renv::restore(packages = 'rsconnect', prompt = FALSE)"`.

## Deployment

- Run `Rscript scripts/deploy_shinyapps.R`.
- Confirm the hosted URL loads.
- Confirm the hosted app shows the expected version, latest count cutoff date, latest reviewed source publication date, and validation status.
- Confirm the top-of-app disclaimer banner links to the README disclaimer.

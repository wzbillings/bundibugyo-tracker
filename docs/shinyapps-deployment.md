# `shinyapps.io` Deployment Runbook

This project's first public hosting target is `shinyapps.io`. The goal is to keep the deployment lightweight while preserving a later migration path to independently managed hosting.

## Portable Assumptions

- The deployed app stays read-only.
- Repository CSV files remain the source of truth.
- Runtime metadata comes from repo-tracked files: `VERSION`, `data/*.csv`, and `README.md`.
- Deployment secrets stay outside the repository.
- The deployment bundle is intentionally small and limited to `app.R`, `VERSION`, `README.md`, `renv.lock`, `R/`, `data/`, and `www/`.

## One-Time Local Setup

1. Restore project dependencies:

   ```powershell
   Rscript -e "renv::restore(prompt = FALSE)"
   ```

2. Ensure `rsconnect` is available:

   ```powershell
   Rscript -e "renv::restore(packages = 'rsconnect', prompt = FALSE)"
   ```

3. Create a `shinyapps.io` account if you do not already have one.
4. In the `shinyapps.io` dashboard, create or open a token for the account that will host this app.

## Recommended Secret Handling

Store deployment secrets in a user-level `.Renviron` file or another local secret store that is not committed to git.

Example user-level `.Renviron` entries:

```text
SHINYAPPS_NAME=your-account-name
SHINYAPPS_TOKEN=your-token
SHINYAPPS_SECRET=your-secret
SHINYAPPS_APP_NAME=bundibugyo-tracker
```

After editing `.Renviron`, restart the R session or terminal before deploying.

## Deployment Command

Run the scripted deploy from the repository root:

```powershell
Rscript scripts/deploy_shinyapps.R
```

The script will:

- read `SHINYAPPS_NAME`, `SHINYAPPS_TOKEN`, and `SHINYAPPS_SECRET`
- use `SHINYAPPS_APP_NAME` if provided, otherwise default to `bundibugyo-tracker`
- register the account with `rsconnect::setAccountInfo()`
- deploy the app bundle to `shinyapps.io`

## Interactive Fallback

If you prefer to set the account once interactively before using the scripted deploy:

```powershell
Rscript -e "rsconnect::setAccountInfo(name = Sys.getenv('SHINYAPPS_NAME'), token = Sys.getenv('SHINYAPPS_TOKEN'), secret = Sys.getenv('SHINYAPPS_SECRET'))"
```

Then run:

```powershell
Rscript scripts/deploy_shinyapps.R
```

## Post-Deploy Checks

After a deploy completes:

1. Open the hosted app URL.
2. Confirm the disclaimer banner appears above the charts.
3. Confirm the banner link opens the README disclaimer.
4. Confirm the app version matches `VERSION`.
5. Confirm the latest count cutoff date and latest reviewed source publication date match the current CSV data.
6. Confirm the validation status is `Passed` or `Passed with warnings`.
7. Confirm the source log and news tables show the reduced default public view.

## Future Self-Hosting Notes

These deployment choices are intended to minimize lock-in:

- no database or hosted write-back service is required
- no Posit-only runtime feature is required for data refresh
- the same repo files can later be served from another Shiny host or alongside a Quarto website
- the public disclaimer and metadata behavior live in app code, not only in platform settings

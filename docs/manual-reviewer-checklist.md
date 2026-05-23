# Manual Reviewer Checklist

Use this checklist before editing `data/outbreak_counts.csv`, `data/source_log.csv`, or `data/news_highlights.csv`.

## Source Eligibility

- Prefer WHO Disease Outbreak News, WHO AFRO outbreak pages, Ministry of Health statements, CDC advisories, and UN agency operational updates.
- Treat media reports as contextual news only unless the article links to an official count source that you also review.
- Do not use automatically discovered sources until a human has reviewed them.

## Source Log Entry

- Add one `data/source_log.csv` row per reviewed source.
- Use the source's public title, publication date, URL, source type, country list, keywords, review status, and notes.
- Set `review_status` to `reviewed` only after the source has been read by a human.
- Keep `url` as the canonical source URL, without surrounding whitespace.

## Count Entry

- Add epidemiologic counts only to `data/outbreak_counts.csv`.
- Use `data_cutoff_date` for the source-stated count reference date.
- If one source reports different cutoff dates for different countries, classifications, or metrics, enter separate rows.
- Preserve the source's denominator for `case_classification`: suspected stays suspected, confirmed stays confirmed, and `all` is only for an all-classification total.
- Do not infer zero rows for countries, classifications, metrics, or dates that are absent from a report.
- Keep `notes` specific enough for another reviewer to find the supporting sentence, table, or paragraph.

## News Highlight Entry

- Add contextual headlines to `data/news_highlights.csv`, not to `data/outbreak_counts.csv`.
- Use highlights to preserve response, policy, operations, or epidemiologic context.
- Do not let news highlights drive dashboard counts.

## Validation

- Run `Rscript tests/testthat.R`.
- Run `Rscript R/validate_counts.R`.
- Review warnings about negative derived increments; they may be valid reporting artifacts but should remain visible.

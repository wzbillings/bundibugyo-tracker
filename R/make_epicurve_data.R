library(dplyr)

make_epicurve_data <- function(counts) {
  counts %>%
    filter(count_type == "cumulative") %>%
    arrange(
      source_name,
      country,
      case_classification,
      metric,
      data_cutoff_date,
      publication_date
    ) %>%
    group_by(source_name, country, case_classification, metric) %>%
    mutate(
      previous_count = lag(count),
      previous_cutoff_date = lag(data_cutoff_date),
      reported_increment = if_else(is.na(previous_count), count, count - previous_count),
      days_since_previous_report = as.integer(data_cutoff_date - previous_cutoff_date),
      missing_previous_report = FALSE,
      negative_increment = reported_increment < 0
    ) %>%
    ungroup()
}

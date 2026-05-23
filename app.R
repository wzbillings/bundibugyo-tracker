load_package <- function(package) {
  suppressPackageStartupMessages(
    suppressWarnings(
      library(package, character.only = TRUE)
    )
  )
}

load_package("shiny")
load_package("bslib")
load_package("dplyr")
load_package("DT")
load_package("ggplot2")
load_package("plotly")

suppressWarnings(source("R/clean_counts.R"))
suppressWarnings(source("R/make_epicurve_data.R"))

counts <- read_counts("data/outbreak_counts.csv")
epicurve <- make_epicurve_data(counts)
source_log <- read_source_log("data/source_log.csv")
news_highlights <- read_news_highlights("data/news_highlights.csv")
source_candidates <- read_source_candidates("data/source_candidates.csv")

all_choice <- "All"
count_dates <- range(counts$data_cutoff_date, na.rm = TRUE)
max_headline_summary_cards <- 6

select_choices <- function(values) {
  c(all_choice, sort(unique(as.character(values))))
}

filter_for_choice <- function(data, column, choice) {
  if (identical(choice, all_choice)) {
    data
  } else {
    data %>% filter(.data[[column]] == choice)
  }
}

format_latest_value <- function(data) {
  if (nrow(data) == 0 || all(is.na(data$count))) {
    return("No data")
  }

  latest_date <- max(data$data_cutoff_date, na.rm = TRUE)
  latest_rows <- data %>%
    filter(data_cutoff_date == latest_date)

  if (nrow(latest_rows) == 0 || all(is.na(latest_rows$count))) {
    return("No data")
  }

  format(max(latest_rows$count, na.rm = TRUE), big.mark = ",")
}

format_latest_date <- function(data) {
  if (nrow(data) == 0 || all(is.na(data$data_cutoff_date))) {
    return("No data")
  }

  format(max(data$data_cutoff_date, na.rm = TRUE), "%Y-%m-%d")
}

format_link <- function(url) {
  paste0("<a href=\"", htmltools::htmlEscape(url, attribute = TRUE), "\" target=\"_blank\" rel=\"noopener noreferrer\">Open</a>")
}

escape_table_display_fields <- function(data, exclude = character()) {
  fields <- setdiff(names(data), exclude)

  data %>%
    mutate(across(all_of(fields), ~ as.character(htmltools::htmlEscape(.x, attribute = FALSE))))
}

candidate_queue_table_data <- function(data) {
  data %>%
    arrange(desc(discovered_at), source_name) %>%
    mutate(
      discovered_at = format(discovered_at, "%Y-%m-%d %H:%M:%S UTC"),
      publication_date = format(publication_date, "%Y-%m-%d"),
      link = format_link(url)
    ) %>%
    select(
      discovered_at,
      source_name,
      title,
      link,
      publication_date,
      source_type,
      country,
      discovery_method,
      review_status,
      review_notes,
      promoted_source_id
    ) %>%
    escape_table_display_fields(exclude = "link")
}

latest_summary_rows <- function(data) {
  if (nrow(data) == 0) {
    return(data.frame(label = character(), value = character(), cutoff = character()))
  }

  data %>%
    filter(count_type == "cumulative") %>%
    group_by(country, case_classification, metric) %>%
    arrange(desc(data_cutoff_date), desc(publication_date), .by_group = TRUE) %>%
    slice_head(n = 1) %>%
    ungroup() %>%
    mutate(
      label = paste(country, case_classification, metric, sep = " - "),
      value = format(count, big.mark = ","),
      cutoff = format(data_cutoff_date, "%Y-%m-%d")
    ) %>%
    arrange(country, metric, case_classification)
}

headline_card <- function(title, output_id) {
  bslib::card(
    class = "dashboard-card",
    bslib::card_body(
      tags$div(class = "card-title", title),
      tags$div(class = "card-value", textOutput(output_id, inline = TRUE))
    )
  )
}

headline_summary_card <- function(label, value, cutoff) {
  bslib::card(
    class = "dashboard-card",
    bslib::card_body(
      tags$div(class = "card-title", label),
      tags$div(class = "card-value", value),
      tags$div(class = "card-caption", paste("Cutoff", cutoff))
    )
  )
}

headline_overflow_text <- function(total_rows, visible_rows) {
  hidden_rows <- total_rows - visible_rows
  if (hidden_rows <= 0) {
    return(character())
  }

  paste0("+", hidden_rows, " more strata")
}

headline_overflow_card <- function(total_rows, visible_rows) {
  overflow_text <- headline_overflow_text(total_rows, visible_rows)
  if (length(overflow_text) == 0) {
    return(NULL)
  }

  bslib::card(
    class = "dashboard-card",
    bslib::card_body(
      tags$div(class = "card-title", "Additional current strata"),
      tags$div(class = "card-value", overflow_text),
      tags$div(class = "card-caption", "Use filters or tables to review hidden strata")
    )
  )
}

caveats <- c(
  "Public counts may reflect reporting date, not onset date.",
  "Recent counts are provisional.",
  "Suspected, probable, and confirmed classifications may be revised.",
  "Negative daily increments can occur after reclassification or deduplication.",
  "Missing report days should not be interpreted as zero cases.",
  "Country-level curves hide subnational heterogeneity."
)

ui <- bslib::page_fluid(
  theme = bslib::bs_theme(version = 5, bootswatch = "flatly"),
  tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")),
  h2("Ebola Outbreak Monitoring Dashboard"),
  p("Manually curated public counts from reviewed official and humanitarian reports."),
  uiOutput("headline_cards"),
  bslib::card(
    bslib::card_header("Filters"),
    bslib::card_body(
      div(
        class = "row filter-row",
        div(class = "col-md-2", selectInput("source", "Source", select_choices(counts$source_name), selectize = FALSE)),
        div(class = "col-md-2", selectInput("country", "Country", select_choices(counts$country), selectize = FALSE)),
        div(class = "col-md-2", selectInput("classification", "Case classification", select_choices(counts$case_classification), selectize = FALSE)),
        div(class = "col-md-2", selectInput("metric", "Metric", select_choices(counts$metric), selectize = FALSE)),
        div(class = "col-md-4", dateRangeInput("date_range", "Date range", start = count_dates[[1]], end = count_dates[[2]], min = count_dates[[1]], max = count_dates[[2]]))
      )
    )
  ),
  bslib::layout_columns(
    col_widths = c(6, 6),
    bslib::card(
      bslib::card_header("Cumulative Public Reports"),
      plotlyOutput("cumulative_plot", height = "390px")
    ),
    bslib::card(
      bslib::card_header("Reported Increments"),
      bslib::card_body(
        tags$p(
          class = "increment-caveat",
          "Daily values are derived from changes in cumulative public reports and may reflect reporting artifacts."
        ),
        plotlyOutput("increment_plot", height = "340px")
      )
    )
  ),
  bslib::layout_columns(
    col_widths = c(4, 4, 4),
    bslib::card(
      bslib::card_header("Source Log"),
      DTOutput("source_log_table")
    ),
    bslib::card(
      bslib::card_header("News Highlights"),
      DTOutput("news_highlights_table")
    ),
    bslib::card(
      bslib::card_header("Candidate Source Queue"),
      bslib::card_body(
        tags$p(
          class = "increment-caveat",
          "Read-only review metadata only. Candidate rows do not update outbreak counts until a human promotes them."
        ),
        DTOutput("candidate_queue_table")
      )
    )
  ),
  bslib::card(
    class = "caveat-panel",
    bslib::card_header("Caveats"),
    bslib::card_body(tags$ul(lapply(caveats, tags$li)))
  )
)

server <- function(input, output, session) {
  filtered_counts <- reactive({
    req(input$date_range)

    counts %>%
      filter_for_choice("source_name", input$source) %>%
      filter_for_choice("country", input$country) %>%
      filter_for_choice("case_classification", input$classification) %>%
      filter_for_choice("metric", input$metric) %>%
      filter(
        data_cutoff_date >= input$date_range[[1]],
        data_cutoff_date <= input$date_range[[2]]
      )
  })

  filtered_epicurve <- reactive({
    req(input$date_range)

    epicurve %>%
      filter_for_choice("source_name", input$source) %>%
      filter_for_choice("country", input$country) %>%
      filter_for_choice("case_classification", input$classification) %>%
      filter_for_choice("metric", input$metric) %>%
      filter(
        data_cutoff_date >= input$date_range[[1]],
        data_cutoff_date <= input$date_range[[2]]
      )
  })

  output$latest_cutoff <- renderText(format_latest_date(filtered_counts()))

  output$headline_cards <- renderUI({
    summary_rows <- latest_summary_rows(filtered_counts())

    if (nrow(summary_rows) == 0) {
      return(bslib::card(bslib::card_body("No data match the current filters.")))
    }

    visible_summary_rows <- min(nrow(summary_rows), max_headline_summary_cards)

    summary_cards <- lapply(seq_len(visible_summary_rows), function(index) {
      headline_summary_card(
        summary_rows$label[[index]],
        summary_rows$value[[index]],
        summary_rows$cutoff[[index]]
      )
    })

    overflow_card <- headline_overflow_card(nrow(summary_rows), visible_summary_rows)
    if (!is.null(overflow_card)) {
      summary_cards <- c(summary_cards, list(overflow_card))
    }

    do.call(
      bslib::layout_columns,
      c(
        list(
          col_widths = c(12, rep(4, length(summary_cards))),
          headline_card("Latest cutoff", "latest_cutoff")
        ),
        summary_cards
      )
    )
  })

  output$cumulative_plot <- renderPlotly({
    plot_data <- filtered_counts() %>%
      filter(count_type == "cumulative")

    validate(need(nrow(plot_data) > 0, "No cumulative data match the current filters."))

    plot_data <- plot_data %>%
      mutate(
        series = paste(country, case_classification, metric, sep = " - "),
        tooltip = paste0(
          "Source: ", source_name,
          "<br>Cutoff date: ", data_cutoff_date,
          "<br>Country: ", country,
          "<br>Classification: ", case_classification,
          "<br>Metric: ", metric,
          "<br>Count: ", count
        )
      )

    plot <- ggplot(
      plot_data,
      aes(
        x = data_cutoff_date,
        y = count,
        color = series,
        group = interaction(source_name, country, case_classification, metric),
        text = tooltip
      )
    ) +
      geom_line(linewidth = 0.8) +
      geom_point(size = 2) +
      labs(x = "Data cutoff date", y = "Cumulative count", color = "Series") +
      theme_minimal(base_size = 12)

    ggplotly(plot, tooltip = "text") %>%
      layout(legend = list(orientation = "h", y = -0.2))
  })

  output$increment_plot <- renderPlotly({
    plot_data <- filtered_epicurve()

    validate(need(nrow(plot_data) > 0, "No reported-increment data match the current filters."))

    plot_data <- plot_data %>%
      mutate(
        series = paste(country, case_classification, metric, sep = " - "),
        tooltip = paste0(
          "Source: ", source_name,
          "<br>Cutoff date: ", data_cutoff_date,
          "<br>Country: ", country,
          "<br>Classification: ", case_classification,
          "<br>Metric: ", metric,
          "<br>Reported increment: ", reported_increment
        )
      )

    plot <- ggplot(
      plot_data,
      aes(
        x = data_cutoff_date,
        y = reported_increment,
        fill = series,
        text = tooltip
      )
    ) +
      geom_col(position = "dodge") +
      labs(x = "Data cutoff date", y = "Reported increment", fill = "Series") +
      theme_minimal(base_size = 12)

    ggplotly(plot, tooltip = "text") %>%
      layout(legend = list(orientation = "h", y = -0.2))
  })

  output$source_log_table <- renderDT({
    table_data <- source_log %>%
      arrange(desc(publication_date), source_name) %>%
      mutate(link = format_link(url)) %>%
      select(source_name, title, publication_date, link, review_status, notes) %>%
      escape_table_display_fields(exclude = "link")

    datatable(
      table_data,
      escape = FALSE,
      rownames = FALSE,
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })

  output$news_highlights_table <- renderDT({
    table_data <- news_highlights %>%
      arrange(desc(date), source) %>%
      mutate(link = format_link(url)) %>%
      select(date, source, title, link, summary, category, is_official) %>%
      escape_table_display_fields(exclude = "link")

    datatable(
      table_data,
      escape = FALSE,
      rownames = FALSE,
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })

  output$candidate_queue_table <- renderDT({
    datatable(
      candidate_queue_table_data(source_candidates),
      escape = FALSE,
      rownames = FALSE,
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })
}

shinyApp(ui = ui, server = server)

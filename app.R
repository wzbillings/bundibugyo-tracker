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

all_choice <- "All"
count_dates <- range(counts$data_cutoff_date, na.rm = TRUE)

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

headline_card <- function(title, output_id) {
  bslib::card(
    class = "dashboard-card",
    bslib::card_body(
      tags$div(class = "card-title", title),
      tags$div(class = "card-value", textOutput(output_id, inline = TRUE))
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
  bslib::layout_columns(
    col_widths = c(12, 6, 6, 6, 6, 6, 6),
    headline_card("Latest cutoff", "latest_cutoff"),
    headline_card("DRC suspected cases", "drc_suspected_cases"),
    headline_card("DRC confirmed cases", "drc_confirmed_cases"),
    headline_card("DRC deaths", "drc_deaths"),
    headline_card("Uganda suspected cases", "uganda_suspected_cases"),
    headline_card("Uganda confirmed cases", "uganda_confirmed_cases"),
    headline_card("Uganda deaths", "uganda_deaths")
  ),
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
    col_widths = c(7, 5),
    bslib::card(
      bslib::card_header("Source Log"),
      DTOutput("source_log_table")
    ),
    bslib::card(
      bslib::card_header("News Highlights"),
      DTOutput("news_highlights_table")
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

  headline_subset <- function(country, classification, metric) {
    filtered_counts() %>%
      filter(
        count_type == "cumulative",
        .data$country == .env$country,
        .data$case_classification %in% .env$classification,
        .data$metric == .env$metric
      )
  }

  output$latest_cutoff <- renderText(format_latest_date(filtered_counts()))
  output$drc_suspected_cases <- renderText(format_latest_value(
    headline_subset("Democratic Republic of the Congo", "suspected", "cases")
  ))
  output$drc_confirmed_cases <- renderText(format_latest_value(
    headline_subset("Democratic Republic of the Congo", "confirmed", "cases")
  ))
  output$drc_deaths <- renderText(format_latest_value(
    headline_subset("Democratic Republic of the Congo", "all", "deaths")
  ))
  output$uganda_suspected_cases <- renderText(format_latest_value(
    headline_subset("Uganda", "suspected", "cases")
  ))
  output$uganda_confirmed_cases <- renderText(format_latest_value(
    headline_subset("Uganda", "confirmed", "cases")
  ))
  output$uganda_deaths <- renderText(format_latest_value(
    headline_subset("Uganda", "all", "deaths")
  ))

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
      select(source_name, title, publication_date, url, review_status, notes)

    datatable(
      table_data,
      rownames = FALSE,
      options = list(pageLength = 5, scrollX = TRUE)
    )
  })

  output$news_highlights_table <- renderDT({
    table_data <- news_highlights %>%
      select(date, source, title, url, summary, category, is_official)

    datatable(
      table_data,
      rownames = FALSE,
      options = list(pageLength = 5, scrollX = TRUE)
    )
  })
}

shinyApp(ui = ui, server = server)

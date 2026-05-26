required_env_var <- function(name) {
  value <- Sys.getenv(name, unset = NA_character_)
  if (is.na(value) || trimws(value) == "") {
    stop(
      "Missing required environment variable: ",
      name,
      call. = FALSE
    )
  }

  trimws(value)
}

optional_env_var <- function(name, default = NULL) {
  value <- Sys.getenv(name, unset = NA_character_)
  if (is.na(value) || trimws(value) == "") {
    return(default)
  }

  trimws(value)
}

ensure_package_installed <- function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    stop(
      "Package '",
      package,
      "' is required. Install it with renv::restore(packages = '",
      package,
      "') or install.packages('",
      package,
      "').",
      call. = FALSE
    )
  }
}

ensure_app_files <- function(paths) {
  missing_paths <- paths[!file.exists(paths)]
  if (length(missing_paths) > 0) {
    stop(
      "Missing deployment file(s): ",
      paste(missing_paths, collapse = ", "),
      call. = FALSE
    )
  }

  invisible(paths)
}

ensure_package_installed("rsconnect")

account_name <- required_env_var("SHINYAPPS_NAME")
token <- required_env_var("SHINYAPPS_TOKEN")
secret <- required_env_var("SHINYAPPS_SECRET")
app_name <- optional_env_var("SHINYAPPS_APP_NAME", default = "bundibugyo-tracker")

app_files <- c(
  "app.R",
  "VERSION",
  "README.md",
  "renv.lock",
  "R",
  "data",
  "www"
)
ensure_app_files(app_files)

rsconnect::setAccountInfo(
  name = account_name,
  token = token,
  secret = secret
)

message("Deploying app '", app_name, "' to shinyapps.io account '", account_name, "'.")

rsconnect::deployApp(
  appDir = ".",
  appFiles = app_files,
  appName = app_name,
  account = account_name,
  launch.browser = FALSE
)

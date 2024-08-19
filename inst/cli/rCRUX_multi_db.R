cli_args <- commandArgs(trailingOnly = TRUE)

num_args <- length(cli_args)

if (!(num_args %in% c(1, 2))) {
  message("\n\n")
  message("usage: Rscript --vanilla rCRUX_multi_db.R </path/to/config.yml> [path/to/rCRUX]")
  message("  - The 1st argument is the path to a YAML file containing the parameters.")
  message("  - The 2nd argument is an optional path to a local rCRUX repository.")
  message("    Use this if you want to run a local (development) version of rCRUX.")
  quit(save = "no", status = 1)
}

if (num_args == 2) {
  devtools::load_all(cli_args[[2]])
} else {
  library(rCRUX)
}

log_file <- Sys.getenv("RCRUX_LOG_FILE")
if (log_file != "") {
  lg$config(list(
    appenders = list(json = lgr::AppenderJson$new(file = log_file)),
    threshold = "all",
    propagate = FALSE
  ))
}


config <- yaml::read_yaml(cli_args[[1]])

print(str(config))
lg$debug("config", what = config)

collated_output_directory <- do.call(
  what = run_multi_db_pipeline,
  args = config
)

lg$info("Done")
message("\n\nAll done!!")
message(stringr::str_glue("Output directory: {config$output_directory_path}"))
message(stringr::str_glue("Output directory (collated): {collated_output_directory}"))

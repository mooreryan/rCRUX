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
  devtools::load_all(cli_args[[2]], quiet = TRUE)
} else {
  library(rCRUX, quietly = TRUE)
}

config <- yaml::read_yaml(cli_args[[1]])

# Create the directory before doing any logging.  It is possible that the user
# will want to redirect the JSON log to a file located in the output directory
# of the pipeline itself, and this directory is likely to not exist before the
# pipeline is run.  Thus, we must create the output directory BEFORE doing any
# logging.
if (!dir.exists(config$output_directory_path)) {
  dir.create(
    config$output_directory_path,
    recursive = TRUE,
    mode = "0750",
    showWarnings = FALSE
  )
}

logfile <- Sys.getenv("RCRUX_LOG")
if (logfile != "") {
  rcrux_logger$add_appender(
    lgr::AppenderJson$new(file = logfile),
    name = "json"
  )
}

rcrux_logger$set_threshold("all")

# This check is repeated here because we want the note about local rCRUX to be
# included in the specified logfile.
if (num_args == 2) {
  rcrux_logger$info("Using a local rCRUX installation.", path = cli_args[[2]])
}

rcrux_logger$info("Starting rCRUX pipeline")

rcrux_logger$debug("Pipeline config", config = config)

collated_output_directory <- do.call(
  what = run_multi_db_pipeline,
  args = config
)

rcrux_logger$info(
  "rCRUX pipeline done",
  output_directory = config$output_directory_path,
  collated_output_directory = collated_output_directory
)

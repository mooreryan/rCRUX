set_up <- function() {
  output_directory_path_top <- tempfile()
  dir.create(
    output_directory_path_top,
    recursive = TRUE, mode = "0750"
  )
  output_directory_path <- file.path(
    output_directory_path_top,
    "16S"
  )

  blast_db_path <- file.path(
    system.file(
      package = "rCRUX",
      file.path("mock-db", "blastdb")
    ),
    "mock-db"
  )

  # These are the params that will be turned into a yaml file.
  params <- list(
    forward_primer_seq = "AGAGGAGCGCGGAATTCC",
    reverse_primer_seq = "TACCTTGTTACGACTT",
    metabarcode_name = "Nitrospira",
    output_directory_path = output_directory_path,
    accession_taxa_sql_path = system.file(
      package = "rCRUX",
      file.path("mock-db", "taxonomizr-ncbi-db-small.sql")
    ),
    blast_db_path = blast_db_path,
    args_get_seeds_local = list(
      minimum_length = 5,
      maximum_length = 900,
      num_threads = 1
    ),
    args_blast_seeds = list(
      expand_vectors = TRUE,
      minimum_length = 5,
      maximum_length = 900,
      num_threads = 1
    )
  )

  params_yml_path <- tempfile()

  rcrux_package_path <- system.file(package = "rCRUX", "..")

  list(
    output_directory_path = output_directory_path,
    params = params,
    params_yml_path = params_yml_path,
    rcrux_package_path = rcrux_package_path
  )
}

test_that("rCRUX.R CLI program works", {
  conf <- set_up()

  # Write the params.
  yaml::write_yaml(conf$params, conf$params_yml_path)

  # This is the CLI script.
  cli_script_file_path <- system.file(
    package = "rCRUX",
    "cli",
    "rCRUX.R"
  )

  # Actually run the CLI program.
  system2(
    command = file.path(R.home("bin"), "Rscript"),
    args = c(
      "--vanilla",
      cli_script_file_path,
      conf$params_yml_path,
      conf$rcrux_package_path
    )
  )

  # Then snapshot the files.
  files_to_snapshot <- list.files(
    path = conf$output_directory_path,
    full.names = TRUE,
    recursive = TRUE,
    include.dirs = FALSE,
    all.files = FALSE
  )
  expect_snapshot({
    files_to_snapshot %>%
      purrr::map_vec(function(filename) {
        stringr::str_replace(
          string = filename, pattern = "^/.*/16S", replacement = "./16S"
        )
      }) %>%
      print()
  })
})


test_that("rCRUX.R CLI program writes a JSONL log file if the env var is set", {
  conf <- set_up()

  # Write the params.
  yaml::write_yaml(conf$params, conf$params_yml_path)

  # This is the CLI script.
  cli_script_file_path <- system.file(
    package = "rCRUX",
    "cli",
    "rCRUX.R"
  )

  # JSON log file
  json_logfile <- file.path(conf$output_directory_path, "LOG.jsonl")

  # The log file doesn't exist before the program is run.
  testthat::expect_false(file.exists(json_logfile))

  # Actually run the CLI program.
  system2(
    command = file.path(R.home("bin"), "Rscript"),
    args = c(
      "--vanilla",
      cli_script_file_path,
      conf$params_yml_path,
      conf$rcrux_package_path
    ),
    env = c(stringr::str_glue("RCRUX_LOG={json_logfile}"))
  )

  # The log file exists after the program  is run.
  testthat::expect_true(file.exists(json_logfile))
})

test_that("rCRUX_multi_db.R CLI program works", {
  output_directory_path_top <- tempfile()
  dir.create(
    output_directory_path_top,
    recursive = TRUE, mode = "0750"
  )
  output_directory_path <- file.path(
    output_directory_path_top,
    "16S"
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
    parallel_jobs = 2,
    blast_db_paths = sapply(1:4, function(n) {
      file.path(
        system.file(
          package = "rCRUX",
          file.path(
            "mock-db",
            "mock-db-sequences-split"
          )
        ),
        stringr::str_glue("mock-db-sequences.part_00{n}")
      )
    }),
    args_get_seeds_local_multi_db = list(
      minimum_length = 5,
      maximum_length = 900,
      num_threads = 1
    ),
    args_blast_seeds_multi_db = list(
      expand_vectors = TRUE,
      minimum_length = 5,
      maximum_length = 900,
      num_threads = 1
    )
  )

  # Write the params.
  params_yml_path <- tempfile()
  yaml::write_yaml(params, params_yml_path)

  # This is the CLI script.
  cli_script_file_path <- system.file(
    package = "rCRUX",
    "cli",
    "rCRUX_multi_db.R"
  )

  rcrux_package_path <- system.file(package = "rCRUX", "..")

  # Actually run the CLI program.
  system2(
    command = "Rscript",
    args = c(
      "--vanilla",
      cli_script_file_path,
      params_yml_path,
      rcrux_package_path
    )
  )

  system2(
    command = "ls",
    args = c(
      file.path(
        output_directory_path,
        "*"
      )
    )
  )

  # Then snapshot the files.
  files_to_snapshot <- list.files(
    path = output_directory_path,
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

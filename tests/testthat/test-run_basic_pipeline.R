# Pass in the unique ID and it returns a function that that will call
# expect_snapshot_file, but with a unique ID appended to the name of the file.
# Use this to keep the file snapshots unique to the individual test even with a
# single test file.
expect_snapshot_file_factory <- function(id) {
  function(path) {
    name <- stringr::str_glue("{id}__{basename(path)}")
    testthat::expect_snapshot_file(path = path, name = name)
  }
}

# WARNING: Many of the test directories created in the tests are removed upon
# test completion.  Do NOT change these to a named directory that you don't
# want to lose.


# MARK: Basic test

# This is a very basic smoke test.  We don't check any of the assumptions of the
# "wrapped" code, or even that it works as intended, because the function under
# test here is "just" a simple wrapper of the local seeds single BLAST DB
# pipeline and we are not adding any logic to that pipeline other than argument
# handling to be used in the CLI script.
test_that("run_basic_pipeline works", {
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

  accession_taxa_sql_path <- system.file(
    package = "rCRUX",
    "mock-db/taxonomizr-ncbi-db-small.sql"
  )

  # Primers
  # Nitrospira F probe, Bacteria 1492R
  forward_primer_seq <- "AGAGGAGCGCGGAATTCC"
  reverse_primer_seq <- "TACCTTGTTACGACTT"

  metabarcode_name <- "Nitrospira"

  run_basic_pipeline(
    forward_primer_seq = forward_primer_seq,
    reverse_primer_seq = reverse_primer_seq,
    metabarcode_name = metabarcode_name,
    output_directory_path = output_directory_path,
    accession_taxa_sql_path = accession_taxa_sql_path,
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

  # Clean up the output directory
  if (dir.exists(output_directory_path_top)) {
    unlink(output_directory_path_top, recursive = TRUE)
  }
})

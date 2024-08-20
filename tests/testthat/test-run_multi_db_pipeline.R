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

test_that("run_multi_db_pipeline works even when some DBs have no hits", {
  output_directory_path_top <- tempfile()
  dir.create(
    output_directory_path_top,
    recursive = TRUE, mode = "0750"
  )


  output_directory_path <- file.path(
    output_directory_path_top,
    "16S"
  )

  blast_db_path <- system.file(
    package = "rCRUX", "mock-db/mock-db-sequences-split"
  )

  blast_db_paths <- paste0(
    file.path(blast_db_path, "mock-db-sequences.part_00"),
    1:4
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

  parallel_jobs <- 2

  collated_output_dir <- run_multi_db_pipeline(
    forward_primer_seq = forward_primer_seq,
    reverse_primer_seq = reverse_primer_seq,
    metabarcode_name = metabarcode_name,
    output_directory_path = output_directory_path,
    accession_taxa_sql_path = accession_taxa_sql_path,
    blast_db_paths = blast_db_paths,
    parallel_jobs = parallel_jobs,
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

  files_to_snapshot <- list.files(
    path = collated_output_dir,
    full.names = TRUE,
    recursive = TRUE,
    include.dirs = FALSE,
    all.files = FALSE
  )
  lapply(
    files_to_snapshot,
    expect_snapshot_file_factory("ec8bc5bc-89c4-49a2-8ff1-d203f0bbfbc0")
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

# MARK: Single BLAST DB

test_that("run_multi_db_pipeline with a single blast DB gives an early error", {
  output_directory_path_top <- tempfile()
  dir.create(
    output_directory_path_top,
    recursive = TRUE, mode = "0750"
  )


  output_directory_path <- file.path(
    output_directory_path_top,
    "16S"
  )

  blast_db_path <- system.file(
    package = "rCRUX", "mock-db/mock-db-sequences-split"
  )

  blast_db_paths <- c(file.path(blast_db_path, "mock-db-sequences.part_001"))

  accession_taxa_sql_path <- system.file(
    package = "rCRUX",
    "mock-db/taxonomizr-ncbi-db-small.sql"
  )

  # Primers
  # Nitrospira F probe, Bacteria 1492R
  forward_primer_seq <- "AGAGGAGCGCGGAATTCC"
  reverse_primer_seq <- "TACCTTGTTACGACTT"

  metabarcode_name <- "Nitrospira"

  parallel_jobs <- 2

  expect_error(
    run_multi_db_pipeline(
      forward_primer_seq = forward_primer_seq,
      reverse_primer_seq = reverse_primer_seq,
      metabarcode_name = metabarcode_name,
      output_directory_path = output_directory_path,
      accession_taxa_sql_path = accession_taxa_sql_path,
      blast_db_paths = blast_db_paths,
      parallel_jobs = parallel_jobs,
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
    ),
    regexp = "be used with two or more"
  )

  expect_error(
    run_multi_db_pipeline(
      forward_primer_seq = forward_primer_seq,
      reverse_primer_seq = reverse_primer_seq,
      metabarcode_name = metabarcode_name,
      output_directory_path = output_directory_path,
      accession_taxa_sql_path = accession_taxa_sql_path,
      blast_db_paths = blast_db_paths[[1]],
      parallel_jobs = parallel_jobs,
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
    ),
    regexp = "be used with two or more"
  )



  # Clean up the output directory
  if (dir.exists(output_directory_path_top)) {
    unlink(output_directory_path_top, recursive = TRUE)
  }
})

# MARK: No hits

test_that("run_multi_db_pipeline fails if there are no hits to any DB", {
  output_directory_path_top <- tempfile()
  dir.create(
    output_directory_path_top,
    recursive = TRUE, mode = "0750"
  )


  output_directory_path <- file.path(
    output_directory_path_top,
    "16S"
  )

  blast_db_path <- system.file(
    package = "rCRUX", "mock-db/mock-db-sequences-split"
  )

  blast_db_paths <- paste0(
    file.path(blast_db_path, "mock-db-sequences.part_00"),
    1:4
  )

  accession_taxa_sql_path <- system.file(
    package = "rCRUX",
    "mock-db/taxonomizr-ncbi-db-small.sql"
  )

  # Primers
  forward_primer_seq <- "GTGTGTGTGTGTGTGTGT"
  reverse_primer_seq <- "GTGTGTGTGTGTGTGT"

  metabarcode_name <- "Nitrospira"

  parallel_jobs <- 2

  expect_error(
    run_multi_db_pipeline(
      forward_primer_seq = forward_primer_seq,
      reverse_primer_seq = reverse_primer_seq,
      metabarcode_name = metabarcode_name,
      output_directory_path = output_directory_path,
      accession_taxa_sql_path = accession_taxa_sql_path,
      blast_db_paths = blast_db_paths,
      parallel_jobs = parallel_jobs,
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
      ),
      regexp = "none of the BLAST DBs had any hits"
    )
  )

  # Clean up the output directory
  if (dir.exists(output_directory_path_top)) {
    unlink(output_directory_path_top, recursive = TRUE)
  }
})

# MARK: One DB w/hits

test_that("run_multi_db_pipeline works with hits to only a single DB works", {
  output_directory_path_top <- tempfile()
  dir.create(
    output_directory_path_top,
    recursive = TRUE, mode = "0750"
  )


  output_directory_path <- file.path(
    output_directory_path_top,
    "16S"
  )

  blast_db_path <- system.file(
    package = "rCRUX", "mock-db/mock-db-sequences-split"
  )

  blast_db_paths <- paste0(
    file.path(blast_db_path, "mock-db-sequences.part_00"),
    c(1, 4)
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

  parallel_jobs <- 2

  collated_output_dir <- run_multi_db_pipeline(
    forward_primer_seq = forward_primer_seq,
    reverse_primer_seq = reverse_primer_seq,
    metabarcode_name = metabarcode_name,
    output_directory_path = output_directory_path,
    accession_taxa_sql_path = accession_taxa_sql_path,
    blast_db_paths = blast_db_paths,
    parallel_jobs = parallel_jobs,
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

  files_to_snapshot <- list.files(
    path = collated_output_dir,
    full.names = TRUE,
    recursive = TRUE,
    include.dirs = FALSE,
    all.files = FALSE
  )
  lapply(
    files_to_snapshot,
    expect_snapshot_file_factory("94e25cf9-fa25-4acd-849f-ac1f5923c7fe")
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

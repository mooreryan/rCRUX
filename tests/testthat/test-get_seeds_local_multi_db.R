test_that("get_seeds_local_multi_db gives the same output as manually running get_seeds_local", {
  output_directory_path_top <- tempdir()

  blast_db_path <- system.file(
    package = "rCRUX", "mock-db/mock-db-sequences-split"
  )

  blast_db_paths <- paste0(
    file.path(blast_db_path, "mock-db-sequences.part_00"),
    1:3
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

  tbl <- get_seeds_local_multi_db(
    # Note that this argument is plural wheras the `get_seeds_local` is
    # singular.
    blast_db_paths = blast_db_paths,
    forward_primer_seq = forward_primer_seq,
    reverse_primer_seq = reverse_primer_seq,
    output_directory_path = file.path(
      output_directory_path_top,
      "16S"
    ),
    metabarcode_name = metabarcode_name,
    accession_taxa_sql_path = accession_taxa_sql_path,
    minimum_length = 5,
    maximum_length = 900,
    num_threads = 1
  )

  # Test oracle: run each DB path individually

  get_seeds_local_wrapper <- function(n) {
    # Set up the out directory.
    output_directory_path <- file.path(
      output_directory_path_top, paste0("oracle_16S_", n)
    )
    dir.create(output_directory_path, showWarnings = FALSE)

    get_seeds_local(
      forward_primer_seq = forward_primer_seq,
      reverse_primer_seq = reverse_primer_seq,
      output_directory_path = output_directory_path,
      metabarcode_name = metabarcode_name,
      accession_taxa_sql_path = accession_taxa_sql_path,
      blast_db_path = blast_db_paths[[n]],
      minimum_length = 5,
      maximum_length = 900,
      return_table = TRUE,
      num_threads = 1
    )
  }

  tbl_oracle <- dplyr::bind_rows(
    get_seeds_local_wrapper(1),
    get_seeds_local_wrapper(2),
    get_seeds_local_wrapper(3)
  ) %>%
    dplyr::distinct()

  expect_equal(tbl, tbl_oracle)
})

# The following are valid args to the `get_seeds_local` function, so it is
# likely a user might make the mistake of passing these args to this function as
# well.  So we explicitly check that these are not passed by the user.

test_that("get_seeds_local_multi_db throws if return_table is given", {
  expect_error(
    get_seeds_local_multi_db(
      blast_db_paths = "",
      output_directory_path = "",
      return_table = TRUE
    ),
    "arguments.*not allowed.*return_table"
  )
})

test_that("get_seeds_local_multi_db throws if blast_db_path is given", {
  expect_error(
    get_seeds_local_multi_db(
      blast_db_paths = "",
      output_directory_path = "",
      blast_db_path = ""
    ),
    "arguments.*not allowed.*blast_db_path"
  )
})

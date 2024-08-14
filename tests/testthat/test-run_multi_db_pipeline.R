test_that("run_multi_db_pipeline works", {
  output_directory_path_top <- tempdir()
  output_directory_path <- file.path(
    output_directory_path_top,
    "16S"
  )

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

  output_file_names <- run_multi_db_pipeline(
    forward_primer_seq = forward_primer_seq,
    reverse_primer_seq = reverse_primer_seq,
    metabarcode_name = metabarcode_name,
    output_directory_path = output_directory_path,
    accession_taxa_sql_path = accession_taxa_sql_path,
    blast_db_paths = blast_db_paths,
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

  lapply(output_file_names, expect_snapshot_file)
})

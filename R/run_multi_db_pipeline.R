# List further to the right in the arguments will be given precedence.
merge_lists <- function(...) {
  Reduce(modifyList, list(...))
}

run_multi_db_pipeline <- function(
    # General arguments
    forward_primer_seq,
    reverse_primer_seq,
    metabarcode_name,
    output_directory_path,
    accession_taxa_sql_path,
    blast_db_paths,
    # A list of arguments that is passed only to get_seeds_local_multi_db
    args_get_seeds_local_multi_db,
    # A list of arguments that is passed only to blast_seeds_multi_db
    args_blast_seeds_multi_db) {
  # Get seeds
  seeds_tbl <- do.call(
    what = get_seeds_local_multi_db,
    args = merge_lists(
      args_get_seeds_local_multi_db,
      list(
        forward_primer_seq = forward_primer_seq,
        reverse_primer_seq = reverse_primer_seq,
        metabarcode_name = metabarcode_name,
        output_directory_path = output_directory_path,
        accession_taxa_sql_path = accession_taxa_sql_path,
        blast_db_paths = blast_db_paths
      )
    )
  )

  # Write the seeds_tbl CSV to a temporary file.
  seeds_tbl_path <- tempfile()
  readr::write_csv(x = seeds_tbl, file = seeds_tbl_path)

  # BLAST seeds
  output_file_names <- do.call(
    what = blast_seeds_multi_db,
    args = merge_lists(
      args_blast_seeds_multi_db,
      list(
        seeds_output_path = seeds_tbl_path,
        metabarcode_name = metabarcode_name,
        output_directory_path = output_directory_path,
        accession_taxa_sql_path = accession_taxa_sql_path,
        blast_db_paths = blast_db_paths
      )
    )
  )

  # TODO: get the collated outdir from blast_seeds
  derep_and_clean_db(
    output_directory_path = file.path(
      output_directory_path,
      "db_all"
    ),
    summary_path = file.path(
      output_directory_path, "db_all", "blast_seeds_output", "summary.csv"
    ),
    metabarcode_name = metabarcode_name
  )

  # TODO: merge in the output file names from the derep_and_clean_db step.
  output_file_names
}

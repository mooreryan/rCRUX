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
    parallel_jobs,
    # A list of arguments that is passed only to get_seeds_local_multi_db
    args_get_seeds_local_multi_db,
    # A list of arguments that is passed only to blast_seeds_multi_db
    args_blast_seeds_multi_db) {
  # Fail fast if there is only a single blast db path given.
  if (length(blast_db_paths) <= 1) {
    stop("run_multi_db_pipeline should only be used with two or more BLAST DBs")
  }

  # Get seeds
  result <- do.call(
    what = get_seeds_local_multi_db,
    args = merge_lists(
      args_get_seeds_local_multi_db,
      list(
        forward_primer_seq = forward_primer_seq,
        reverse_primer_seq = reverse_primer_seq,
        metabarcode_name = metabarcode_name,
        output_directory_path = output_directory_path,
        accession_taxa_sql_path = accession_taxa_sql_path,
        blast_db_paths = blast_db_paths,
        parallel_jobs = parallel_jobs
      )
    )
  )
  seeds_tbl <- result$collated_table

  # If none of the BLAST DBs found any seeds, then fail.
  if (length(blast_db_paths) == 0) {
    stop("When searching for seeds, none of the BLAST DBs had any hits.")
  }

  # Write the seeds_tbl CSV to a temporary file.
  seeds_tbl_path <- tempfile()
  readr::write_csv(x = seeds_tbl, file = seeds_tbl_path)

  # BLAST seeds
  collated_output_dir <- do.call(
    what = blast_seeds_multi_db,
    args = merge_lists(
      args_blast_seeds_multi_db,
      list(
        seeds_output_path = seeds_tbl_path,
        metabarcode_name = metabarcode_name,
        output_directory_path = output_directory_path,
        accession_taxa_sql_path = accession_taxa_sql_path,
        blast_db_paths = blast_db_paths,
        parallel_jobs = parallel_jobs
      )
    )
  )

  # The derep and clean step outputs directly into the collated directory
  # created in the previous step.
  derep_and_clean_db(
    output_directory_path = collated_output_dir,
    summary_path = file.path(
      collated_output_dir, "blast_seeds_output", "summary.csv"
    ),
    metabarcode_name = metabarcode_name
  )

  # Return the collated directory path.
  collated_output_dir
}

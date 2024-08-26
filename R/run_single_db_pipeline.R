# List further to the right in the arguments will be given precedence.
merge_lists <- function(...) {
  Reduce(modifyList, list(...))
}

run_single_db_pipeline <- function(
    # General arguments
    forward_primer_seq,
    reverse_primer_seq,
    metabarcode_name,
    output_directory_path,
    accession_taxa_sql_path,
    blast_db_path,
    # A list of arguments that is passed only to get_seeds_local
    args_get_seeds_local,
    # A list of arguments that is passed only to blast_seeds
    args_blast_seeds) {
  # These paths are "known" values given the get_seeds_local and blast_seeds
  # functions.  If those change, this will also need to be changed.
  seeds_output_path <- file.path(
    output_directory_path,
    "get_seeds_local",
    stringr::str_glue(
      "{metabarcode_name}_filtered_get_seeds_local_output_with_taxonomy.csv"
    )
  )
  summary_path <- file.path(
    output_directory_path,
    "blast_seeds_output",
    "summary.csv"
  )

  # Get seeds
  do.call(
    what = get_seeds_local,
    args = merge_lists(
      args_get_seeds_local,
      list(
        forward_primer_seq = forward_primer_seq,
        reverse_primer_seq = reverse_primer_seq,
        metabarcode_name = metabarcode_name,
        output_directory_path = output_directory_path,
        accession_taxa_sql_path = accession_taxa_sql_path,
        blast_db_path = blast_db_path
      )
    )
  )

  # BLAST seeds
  do.call(
    what = blast_seeds,
    args = merge_lists(
      args_blast_seeds,
      list(
        seeds_output_path = seeds_output_path,
        metabarcode_name = metabarcode_name,
        output_directory_path = output_directory_path,
        accession_taxa_sql_path = accession_taxa_sql_path,
        blast_db_path = blast_db_path
      )
    )
  )

  derep_and_clean_db(
    output_directory_path = output_directory_path,
    summary_path = summary_path,
    metabarcode_name = metabarcode_name
  )

  NULL
}

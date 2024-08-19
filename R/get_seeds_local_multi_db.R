get_seeds_local_multi_db <- function(
    blast_db_paths,
    output_directory_path,
    parallel_jobs,
    ...) {
  check_forbidden_args(
    additional_args = list(...),
    forbidden_args = c("blast_db_path", "return_table")
  )


  tables <- parallel::mclapply(
    X = seq_along(blast_db_paths),
    FUN = function(n) {
      blast_db_path <- blast_db_paths[[n]]

      lg$trace("blast_db_path from get_seeds_local_multi_db", what = blast_db_path)

      message("working on blast_db_path: ", blast_db_path)

      out_path <- create_sub_output_directory(output_directory_path, n)

      # This will error if no BLAST hits are found, so it must be wrapped in a
      # try block.  We warn the user and return an empty tibble.
      rlang::try_fetch(
        get_seeds_local(
          blast_db_path = blast_db_path,
          output_directory_path = out_path,
          return_table = TRUE,
          ...
        ),
        error = function(condition) {
          message(
            stringr::str_glue(
              "There was an issue in get_seeds_local: {condition}.\n",
              "It is likely that this DB split (i: {n}) had no BLAST hits,\n",
              "in which case it is a normal occurence."
            )
          )
          tibble::tibble()
        }
      )
    },
    mc.preschedule = FALSE,
    mc.cores = parallel_jobs,
    mc.allow.recursive = FALSE
  )
  with_hits <- sapply(tables, function(tbl) nrow(tbl) > 0)
  tables <- tables[with_hits]

  collated_table <- tables %>%
    Reduce(f = dplyr::bind_rows, x = .) %>%
    dplyr::distinct()

  blast_db_paths_with_hits <- blast_db_paths[with_hits]

  list(
    collated_table = collated_table,
    blast_db_paths_with_hits = blast_db_paths_with_hits
  )
}

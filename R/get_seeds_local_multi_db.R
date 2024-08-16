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

      message("working on blast_db_path: ", blast_db_path)

      out_path <- create_sub_output_directory(output_directory_path, n)

      get_seeds_local(
        blast_db_path = blast_db_path,
        output_directory_path = out_path,
        return_table = TRUE,
        ...
      )
    },
    mc.preschedule = FALSE,
    mc.cores = parallel_jobs,
    mc.allow.recursive = FALSE
  )

  tables %>%
    Reduce(f = dplyr::bind_rows, x = .) %>%
    dplyr::distinct()
}

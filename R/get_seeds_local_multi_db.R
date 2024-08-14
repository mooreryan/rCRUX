get_seeds_local_multi_db <- function(
    blast_db_paths,
    output_directory_path,
    ...) {
  check_forbidden_args(
    additional_args = list(...),
    forbidden_args = c("blast_db_path", "return_table")
  )

  tables <- lapply(seq_along(blast_db_paths), function(n) {
    blast_db_path <- blast_db_paths[[n]]

    message("working on blast_db_path: ", blast_db_path)

    out_path <- file.path(output_directory_path, paste0("db_", n))
    dir.create(out_path, recursive = TRUE, mode = "0750", showWarnings = FALSE)

    get_seeds_local(
      blast_db_path = blast_db_path,
      output_directory_path = out_path,
      return_table = TRUE,
      ...
    )
  })

  tables %>%
    Reduce(f = dplyr::bind_rows, x = .) %>%
    dplyr::distinct()
}

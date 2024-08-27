check_forbidden_args <- function(additional_args, forbidden_args) {
  forbidden_present <-
    forbidden_args[forbidden_args %in% names(additional_args)]

  if (length(forbidden_present) > 0) {
    stop(
      "The following arguments are not allowed: ",
      paste(forbidden_present, collapse = ", ")
    )
  }
}

#' Create a subdirectory for multi DB pipeline output.
#'
#' This function creates a named subdirectory within the specified path for
#' storing output files.  If the output directory already exists, no action is
#' taken, and the name of the directory is still returned.  (I.e., it is safe to
#' call on a directory that already exists.)
#'
#' @param path The path where the subdirectory should be created
#' @param n The index of the DB split
#'
#' @return The path of the (possibly) created subdirectory
create_sub_output_directory <- function(path, n) {
  out_path <- file.path(path, paste0("db_", n))
  dir.create(out_path, recursive = TRUE, mode = "0750", showWarnings = FALSE)
  out_path
}

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

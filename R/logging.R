# Make the logger globally available as `rcrux_logger` when the package is
# loaded.
.onLoad <- function(...) {
  assign(
    "rcrux_logger",
    lgr::get_logger("rCRUX"),
    envir = parent.env(environment())
  )
}

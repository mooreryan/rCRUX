.onLoad <- function(...) {
  assign("lg", lgr::get_logger("rCRUX"), envir = parent.env(environment()))
}

trace <- function(msg) {
  # This value is obscure but the default for caller is get_caller(-7),
  # so just roll with it.
  lg$trace(c(msg, head(sys.calls(), -1)), caller = lgr::get_caller(-9))
}

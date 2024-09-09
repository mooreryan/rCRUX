# Make the logger globally available as `rcrux_logger` when the package is
# loaded.
.onLoad <- function(...) {
  assign(
    "rcrux_logger",
    lgr::get_logger("rCRUX"),
    envir = parent.env(environment())
  )
}

get_logfile_lock <- function() {
  get0("rcrux_logfile_lock", envir = globalenv(), mode = "character")
}


assign_logfile_lock <- function() {
  lockfile <- tempfile("rcrux_log_", fileext = ".lock")

  assign("rcrux_logfile_lock", value = lockfile, envir = globalenv())

  lockfile
}


make_log_function <- function(log_fn) {
  function(...) {
    logfile_lock <- get_logfile_lock()

    # The user has not specified a lockfile for the log.  So, just log and be
    # done with it.
    if (is.null(logfile_lock)) {
      log_fn(...)
      return(invisible(NULL))
    }

    # User has specified a lock file, so try to acquire the lock.  Timeout after
    # 120 seconds.
    lock <- filelock::lock(logfile_lock, timeout = 120 * 1000)

    # Then, log while holding the lock.
    # logger::log_level(FYI, ...)
    log_fn(...)

    # `lock` will be NULL if a timeout occured and it was unable to aquire the
    # lock.
    if (!is.null(lock)) {
      # Finally, release the lock so another thread can go ahead with its work.
      #
      # `unlock` always returns TRUE, so hide the return value.
      filelock::unlock(lock) |> invisible()
    }

    invisible(NULL)
  }
}

# Set up logging facade.
rcrux_log_fatal <- make_log_function(logger::log_fatal)
rcrux_log_error <- make_log_function(logger::log_error)
rcrux_log_warn <- make_log_function(logger::log_warn)
rcrux_log_info <- make_log_function(logger::log_info)
rcrux_log_debug <- make_log_function(logger::log_debug)
rcrux_log_trace <- make_log_function(logger::log_trace)

set_up_logger <- function() {
  logger::log_threshold(logger::INFO)
  logger::log_formatter(logger::formatter_json)

  logfile <- Sys.getenv("RCRUX_LOG")
  if (logfile != "") {
    logger::log_threshold(logger::TRACE, index = 2)

    logfile |>
      logger::appender_file() |>
      logger::log_appender(index = 2)

    logger::log_layout(logger::layout_json_parser(), index = 2)
  }
}

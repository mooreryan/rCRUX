rcrux_logger_namespace <- "rCRUX"

.onLoad <- function(...) {
  # JSON formatter for logger is set on package load because the log message
  # formatter is specific to the way rCRUX does logging calls.
  logger::log_formatter(
    logger::formatter_json,
    namespace = rcrux_logger_namespace
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


# NOTE: If there is a step that requires a ton of very short system calls that
# are surrounded by log calls, then this locking scheme could potentially become
# a choke point in a parallel program.
#
# NOTE: If these start having a noticable affect on timing, check and see if
# eagerly building the messages is the issue.  If so, you may need to change it
# to accept a thunk instead.

make_log_function <- function(log_fn) {
  function(msg, extra) {
    logfile_lock <- get_logfile_lock()

    # The user has not specified a lockfile for the log.  So, just log and be
    # done with it.
    if (is.null(logfile_lock)) {
      log_fn(msg, extra)
      return(invisible(NULL))
    }

    # User has specified a lock file, so try to acquire the lock.  Timeout after
    # 120 seconds.
    lock <- filelock::lock(logfile_lock, timeout = 120 * 1000)

    # Then, log while holding the lock.
    # logger::log_level(FYI, ...)
    log_fn(msg, extra)

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

# The default of `.topcall = sys.call(-1)` gives most log lines a `fn` value of
# `log_fn`.  Setting it to `-2`, gives most log calls the name of the function
# from which the logging function was called.  However, if the logger is called
# directly from a script not in a function, it gives NA.  It's good enough for
# now.

rcrux_log_fatal <- make_log_function(function(msg, details = NA) {
  logger::log_fatal(
    msg = msg,
    details = details,
    .topcall = sys.call(-2),
    namespace = rcrux_logger_namespace
  )
})
rcrux_log_error <- make_log_function(function(msg, details = NA) {
  logger::log_error(
    msg = msg,
    details = details,
    .topcall = sys.call(-2),
    namespace = rcrux_logger_namespace
  )
})
rcrux_log_warn <- make_log_function(function(msg, details = NA) {
  logger::log_warn(
    msg = msg,
    details = details,
    .topcall = sys.call(-2),
    namespace = rcrux_logger_namespace
  )
})
rcrux_log_info <- make_log_function(function(msg, details = NA) {
  logger::log_info(
    msg = msg,
    details = details,
    .topcall = sys.call(-2),
    namespace = rcrux_logger_namespace
  )
})
rcrux_log_debug <- make_log_function(function(msg, details = NA) {
  logger::log_debug(
    msg = msg,
    details = details,
    .topcall = sys.call(-2),
    namespace = rcrux_logger_namespace
  )
})
rcrux_log_trace <- make_log_function(function(msg, details = NA) {
  logger::log_trace(
    msg = msg,
    details = details,
    .topcall = sys.call(-2),
    namespace = rcrux_logger_namespace
  )
})

set_up_logger <- function() {
  logger::log_threshold(logger::INFO, namespace = rcrux_logger_namespace)
  logger::log_formatter(
    logger::formatter_json,
    namespace = rcrux_logger_namespace
  )

  logfile <- Sys.getenv("RCRUX_LOG")
  if (logfile != "") {
    logger::log_threshold(
      logger::TRACE,
      namespace = rcrux_logger_namespace, index = 2
    )

    logfile |>
      logger::appender_file() |>
      logger::log_appender(namespace = rcrux_logger_namespace, index = 2)

    logger::log_layout(
      logger::layout_json_parser(),
      namespace = rcrux_logger_namespace, index = 2
    )
  }
}

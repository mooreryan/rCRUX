rcrux_logger_namespace <- "rCRUX"

.onLoad <- function(...) {
  # Use more precision for the timestamps in the logger.
  options(digits.secs = 6)

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
  function(msg, details = NULL) {
    logfile_lock <- get_logfile_lock()

    # The user has not specified a lockfile for the log.  So, just log and be
    # done with it.
    if (is.null(logfile_lock)) {
      log_fn(msg = msg, details = details)
      return(invisible(NULL))
    }

    # User has specified a lock file, so try to acquire the lock.  Timeout after
    # 120 seconds.
    lock <- filelock::lock(logfile_lock, timeout = 120 * 1000)

    # Then, log while holding the lock.
    # logger::log_level(FYI, ...)
    log_fn(msg = msg, details = details)

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

# The default of `.topcall = sys.call(-1)` gives most log lines a `fn` value of
# `log_fn`.  Setting it to `-2`, gives most log calls the name of the function
# from which the logging function was called.  However, if the logger is called
# directly from a script not in a function, it gives NA.  It's good enough for
# now.

# The tedious `details` stuff is there to keep the logs looking a little nicer
# when `details` aren't provided.  Could be there is a nicer way to handle it in
# `logger` package itself.
wrap_logger <- function(log_fn) {
  function(msg, details = NULL) {
    if (is.null(details)) {
      log_fn(
        msg = msg,
        # .topcall = sys.call(1),
        namespace = rcrux_logger_namespace
      )
    } else {
      log_fn(
        msg = msg,
        details = details,
        # .topcall = sys.call(1),
        namespace = rcrux_logger_namespace
      )
    }
  }
}

# Set up logging facade.

rcrux_log_fatal <- logger::log_fatal %>%
  wrap_logger() %>%
  make_log_function()

rcrux_log_error <- logger::log_error %>%
  wrap_logger() %>%
  make_log_function()

rcrux_log_warn <- logger::log_warn %>%
  wrap_logger() %>%
  make_log_function()

rcrux_log_info <- logger::log_info %>%
  wrap_logger() %>%
  make_log_function()

rcrux_log_debug <- logger::log_debug %>%
  wrap_logger() %>%
  make_log_function()

rcrux_log_trace <- logger::log_trace %>%
  wrap_logger() %>%
  make_log_function()

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
      logger::layout_json_parser(fields = c(
        "time", "level", "ns", "ans", "topenv", "node", "arch",
        "os_name", "os_release", "os_version", "pid", "user", "r_version"
      )),
      namespace = rcrux_logger_namespace, index = 2
    )
  }
}


## TODO: methods
## TODO: headers
## TODO: options
## TODO: can we save to file?

#' Asynchronous HTTP GET request
#'
#' Start an HTTP GET request in the background, and report its completion
#' via a deferred.
#'
#' @param url URL to connect to.
#' @param headers HTTP headers to send.
#' @return Deferred object.
#'
#' @family asyncronous HTTP calls
#' @export
#' @importFrom curl new_handle handle_setheaders
#' @examples
#' dx <- http_get("https://httpbin.org/status/200")$
#'   then(~ .$status_code)
#' await(dx)

http_get <- function(url, headers = character()) {
  assert_that(is_string(url))
  handle <- new_handle(url = url)
  handle_setheaders(handle, .list = headers)
  make_deferred_http(handle)
}

#' Asynchronous HTTP HEAD request
#'
#' @inheritParams http_get
#' @return Deferred object.
#'
#' @family asyncronous HTTP calls
#' @export
#' @importFrom curl handle_setopt
#' @examples
#' dx <- http_head("https://httpbin.org/status/200")$
#'   then(~ .$status_code)
#' await(dx)
#'
#' # Check a list of URLs in parallel
#' urls <- c("https://r-project.org", "https://httpbin.org")
#' dx <- when_all(.list = lapply(urls, http_head))$
#'   then(~ lapply(., "[[", "status_code"))
#' await(dx)

http_head <- function(url, headers = character()) {
  assert_that(is_string(url))
  handle <- new_handle(url = url)
  handle_setheaders(handle, .list = headers)
  handle_setopt(handle, customrequest = "HEAD", nobody = TRUE)
  make_deferred_http(handle)
}

make_deferred_http <- function(handle) {
  deferred$new(function(resolve, reject) {
    force(resolve)
    force(reject)
    get_default_event_loop()$run_http(handle, function(err, res) {
      if (is.null(err)) resolve(res) else reject(err)
    })
  })
}

#' Throw R errors for HTTP errors
#'
#' Status codes below 400 are considered successful, others will trigger
#' errors. Note that this is different from the `httr` package, which
#' considers the 3xx status code errors as well.
#'
#' @param resp HTTP response from [http_get()], [http_head()], etc.
#' @return The HTTP response invisibly, if it is considered successful.
#'   Otherwise an error is thrown.
#'
#' @export
#' @examples
#' dx <- http_get("https://httpbin.org/status/404")$
#'   then(http_stop_for_status)
#'
#' tryCatch(await(dx), error = function(e) e)

http_stop_for_status <- function(resp) {
  if (!is.integer(resp$status_code)) stop("Not an HTTP response")
  if (resp$status_code < 400) return(invisible(resp))
  stop("HTTP error")
}

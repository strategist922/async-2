
#' Retry an asynchronous function a number of times
#'
#' Keeps trying until the function's deferred value resolves without
#' error, or `times` tries have been performed.
#'
#' @param task An asynchronous function.
#' @param times Number of tries.
#' @param ... Arguments to pass to `task`.
#' @return Deferred value for the operation with retries.
#'
#' @family async control flow
#' @export
#' @examples
#' ## Try a download at most 5 times
#' dx <- async_retry(
#'   function() http_get("https://httpbin.org"),
#'   times = 5
#' )$then(~ .$status_code)
#'
#' await(dx)

async_retry <- function(task, times, ...) {
  task <- async(task)
  force(times)

  deferred$new(function(resolve, reject) {

    xresolve <- function(value) resolve(value)
    xreject  <- function(reason) {
      times <<- times - 1
      if (times > 0) {
        task(...)$then(xresolve, xreject)
      } else {
        reject(reason)
      }
    }

    task(...)$then(xresolve, xreject)
  })
}

#' Make an asynchronous funcion retryable
#'
#' @param task An asynchronous function.
#' @param times Number of tries.
#' @return Asynchronous retryable function.
#'
#' @family async control flow
#' @export
#' @examples
#' ## Create a downloader that retries five times
#' http_get_5 <- async_retryable(http_get, times = 5)
#' dx <- http_get("https://httpbin.org/get?q=1")$
#'   then(~ rawToChar(.$content))
#' cat(await(dx))

async_retryable <- function(task, times) {
  task <- async(task)
  force(times)
  function(...) {
    async_retry(task, times, ...)
  }
}

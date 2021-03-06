% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/retry.R
\name{async_retry}
\alias{async_retry}
\title{Retry an asynchronous function a number of times}
\usage{
async_retry(task, times, ...)
}
\arguments{
\item{task}{An asynchronous function.}

\item{times}{Number of tries.}

\item{...}{Arguments to pass to \code{task}.}
}
\value{
Deferred value for the operation with retries.
}
\description{
Keeps trying until the function's deferred value resolves without
error, or \code{times} tries have been performed.
}
\examples{
## Try a download at most 5 times
dx <- async_retry(
  function() http_get("https://httpbin.org"),
  times = 5
)$then(~ .$status_code)

await(dx)
}
\seealso{
Other async control flow: \code{\link{async_reflect}},
  \code{\link{async_retryable}},
  \code{\link{async_sequence}}, \code{\link{async_until}},
  \code{\link{async_whilst}}
}

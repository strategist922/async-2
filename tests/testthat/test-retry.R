
context("async_retry")

test_that("unsuccessful async_retry", {

  x <- 5
  expect_error(
    await(async_retry(
      function() {
        x <<- x - 1
        if (x) stop("error") else "OK"
      },
      times = 3
    )),
    "error"
  )
})

test_that("successful async_retry", {

  x <- 5
  result <- await(async_retry(
    function() {
      x <<- x - 1
      if (x) stop("error") else "OK"
    },
    times = 5
  ))

  expect_equal(result, "OK")
})

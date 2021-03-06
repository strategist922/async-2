
context("async_every")

test_that("async_every", {

  is_odd <- async(
    function(x) delay(1/1000)$then(function(value) as.logical(x %% 2))
  )

  result <- await(async_every(1:10, is_odd))
  expect_identical(result, FALSE)

  result <- await(async_every(numeric(), is_odd))
  expect_identical(result, TRUE)

  result <- await(async_every(1:10 * 2 + 1, is_odd))
  expect_identical(result, TRUE)
})

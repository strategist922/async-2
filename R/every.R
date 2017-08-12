
#' @export

every <- function(list, async_function, callback) {
  force(list) ; force(async_function) ; force(callback)

  l <- length(list)
  if (l == 0) return(callback(NULL, TRUE))

  lapply(seq_along(list), function(i) {
    async_function(list[[i]], function(err, res) {
      if (!is.null(err)) return(callback(err, NULL))
      if (!res) return(callback(NULL, FALSE))
      l <<- l - 1
      if (l == 0) callback(NULL, TRUE)
    })
  })
}
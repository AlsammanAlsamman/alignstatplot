#' Sequence of numbers including  the end number if it was not reached
#' @description #return a sequence of numbers including last number if
#' it was not included in the sequence
#' @param from start
#' @param to end
#' @param by step
#' @return vector
#' @export
seqWithLast <- function (from, to, by) {
  vec <- do.call(what = seq, args = list(from, to, by))
  if ( tail(vec, 1) != to ) {
    return(c(vec, to))
  } else {
    return(vec)
  }
}

test_that("nucFrequency computes per-position nucleotide proportions", {
  m <- make_biallelic_table()
  nf <- nucFrequency(m)

  expect_s3_class(nf, "data.frame")
  expect_equal(rownames(nf), c("A","C","T","G","N"))
  expect_equal(colnames(nf), colnames(m))
  expect_equal(unname(unlist(nf["A", 1:20])), rep(0.5, 20))
  expect_equal(unname(unlist(nf["G", 1:20])), rep(0.5, 20))
  expect_equal(unname(unlist(nf["A", 21:25])), rep(1, 5))
  expect_true(all(nf["C", ] == 0) && all(nf["T", ] == 0) && all(nf["N", ] == 0))
})

test_that("nucFrequency treats degenerate/ambiguous codes as missing (N)", {
  m <- matrix(c("A","A","R","A"), nrow = 2, dimnames = list(c("s1","s2"), c("N1","N2")))
  nf <- nucFrequency(m)
  expect_equal(unname(nf["N", "N2"]), 0.5)
  expect_equal(unname(nf["A", "N2"]), 0.5)
})

test_that("nucFrequency rejects an empty table", {
  expect_error(nucFrequency(matrix(nrow = 0, ncol = 0)), "non-empty")
  expect_error(nucFrequency(matrix(nrow = 3, ncol = 0)), "non-empty")
})

test_that("getDistanceMatrixTabel returns a named, symmetric, zero-diagonal distance matrix", {
  fx <- make_small_alignment()
  dm <- getDistanceMatrixTabel(fx$SeqInfo, fx$dna)

  expect_equal(dim(dm), c(5, 5))
  expect_equal(rownames(dm), fx$SeqInfo$Name)
  expect_equal(colnames(dm), fx$SeqInfo$Name)
  expect_equal(unname(diag(as.matrix(dm))), rep(0, 5))
  expect_true(isSymmetric(as.matrix(dm)))
  # seq1/seq2 are identical, seq4/seq5 are identical -> distance 0
  expect_equal(dm["seq1","seq2"], 0)
  expect_equal(dm["seq4","seq5"], 0)
})

test_that("getDistanceMatrixTabel rejects a seqInfo/alignment size mismatch", {
  fx <- make_small_alignment()
  expect_error(getDistanceMatrixTabel(fx$SeqInfo[1:2, ], fx$dna), "same set of sequences")
})

test_that("getTree builds an unrooted nj tree with one tip per sequence", {
  fx <- make_small_alignment()
  dm <- getDistanceMatrixTabel(fx$SeqInfo, fx$dna)
  tree <- getTree(dm)

  expect_s3_class(tree, "phylo")
  expect_equal(sort(tree$tip.label), sort(fx$SeqInfo$Name))
  expect_equal(length(tree$tip.label), 5)
})

test_that("getTree rejects a non-square matrix and too few sequences", {
  expect_error(getTree(matrix(1, nrow = 3, ncol = 4)), "square distance matrix")
  expect_error(getTree(matrix(c(0,1,1,0), 2, 2)), "At least 3 sequences")
})

test_that("bundled example alignment produces a full, self-consistent distance/tree pipeline", {
  SeqInfo <- bundled_seq_info()
  dna <- bundled_alignment()
  dm <- getDistanceMatrixTabel(SeqInfo, dna)
  tree <- getTree(dm)

  expect_equal(dim(dm), c(10, 10))
  expect_equal(unname(diag(as.matrix(dm))), rep(0, 10))
  expect_equal(length(tree$tip.label), 10)
})

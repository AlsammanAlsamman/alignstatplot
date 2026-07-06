test_that("readSeq parses a fasta file into a list of sequence objects", {
  fasta <- system.file("extdata", "Example_Small.fasta", package = "alignstatplot")
  fs <- readSeq(fasta)

  expect_type(fs, "list")
  expect_equal(length(fs), 10)
  expect_equal(seqinr::getName(fs)[1:3], c("gene1","gene2","gene3"))
})

test_that("seqAlign rejects an unsupported alignment method (no external binary required)", {
  fasta <- system.file("extdata", "Example_Small.fasta", package = "alignstatplot")
  expect_error(seqAlign(fasta, "NotARealAligner"), "not supported")
})

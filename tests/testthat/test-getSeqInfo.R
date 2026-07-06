test_that("getSeqInfo reads names and lengths from a fasta file", {
  fasta <- system.file("extdata", "Example_Small.fasta", package = "alignstatplot")
  SeqInfo <- getSeqInfo(fasta)

  expect_s3_class(SeqInfo, "data.frame")
  expect_equal(colnames(SeqInfo), c("Name", "Length"))
  expect_equal(nrow(SeqInfo), 10)
  expect_equal(SeqInfo$Name[1:3], c("gene1", "gene2", "gene3"))
  expect_true(all(SeqInfo$Length > 0))
})

test_that("getSeqInfo rejects a missing file with an informative error", {
  expect_error(getSeqInfo("does/not/exist.fasta"), "existing fasta file")
})

test_that("getSeqInfo rejects non-character/multi-element input", {
  expect_error(getSeqInfo(123), "existing fasta file")
  expect_error(getSeqInfo(character(0)), "existing fasta file")
})

test_that("alignment2Fasta converts a DNAbin alignment to a named list of uppercase vectors", {
  fx <- make_small_alignment()
  SeqAligned <- suppressWarnings(alignment2Fasta(fx$dna, fx$SeqInfo))

  expect_type(SeqAligned, "list")
  expect_equal(names(SeqAligned), fx$SeqInfo$Name)
  expect_equal(SeqAligned$seq1, c("A","T","C","G","A","T","C","G"))
  expect_equal(SeqAligned$seq4, c("A","T","C","G","-","T","G","G"))
})

test_that("alignment2Fasta rejects mismatched SeqInfo/alignment sizes", {
  fx <- make_small_alignment()
  expect_error(alignment2Fasta(fx$dna, fx$SeqInfo[1:3, ]), "same set of sequences")
  expect_error(alignment2Fasta(fx$dna, data.frame(x = 1)), "Name.*Length")
})

test_that("alignment2Table rbinds sequences into an N1..Nn matrix", {
  fx <- make_small_alignment()
  SeqAligned <- suppressWarnings(alignment2Fasta(fx$dna, fx$SeqInfo))
  tbl <- alignment2Table(fx$SeqInfo, SeqAligned)

  expect_equal(dim(tbl), c(5, 8))
  expect_equal(rownames(tbl), fx$SeqInfo$Name)
  expect_equal(colnames(tbl), paste0("N", 1:8))
  expect_equal(unname(tbl["seq3", ]), c("A","T","C","G","A","T","G","G"))
})

test_that("alignment2Table rejects a sequence-count / SeqInfo mismatch", {
  fx <- make_small_alignment()
  SeqAligned <- suppressWarnings(alignment2Fasta(fx$dna, fx$SeqInfo))
  expect_error(alignment2Table(fx$SeqInfo[1:2, ], SeqAligned), "same set of sequences")
})

test_that("AlignmentStatsPerSeq computes per-sequence composition and gap stats", {
  fx <- make_small_alignment()
  SeqAligned <- suppressWarnings(alignment2Fasta(fx$dna, fx$SeqInfo))
  stats <- AlignmentStatsPerSeq(fx$SeqInfo, SeqAligned)

  expect_equal(stats$Sequence.Name, fx$SeqInfo$Name)
  expect_equal(stats$Gap, c(0, 0, 0, 1, 1))
  expect_equal(stats$Sequence.Length, c(8, 8, 8, 7, 7))
  expect_equal(stats$GC, c(4, 4, 4, 4, 4))
  expect_equal(stats$GC.Percentage[1], "50.00%")
  expect_equal(stats$Gap.Percentage[4], "12.50%")
})

test_that("AlignmentStatsPerSeq rejects a sequence-count / SeqInfo mismatch", {
  fx <- make_small_alignment()
  SeqAligned <- suppressWarnings(alignment2Fasta(fx$dna, fx$SeqInfo))
  expect_error(AlignmentStatsPerSeq(fx$SeqInfo[1:2, ], SeqAligned), "same set of sequences")
})

test_that("percentFormat formats a fraction as a percentage string", {
  expect_equal(percentFormat(0.5), "50.00%")
  expect_equal(percentFormat(0.125, digits = 1), "12.5%")
})

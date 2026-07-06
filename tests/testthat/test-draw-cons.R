test_that("drawConsWithGenes accepts custom gene/consensus labels and per-element font sizes", {
  fx <- make_small_alignment()
  SeqAligned <- suppressWarnings(alignment2Fasta(fx$dna, fx$SeqInfo))

  pdf(NULL)
  on.exit(dev.off(), add = TRUE)

  expect_no_error(drawConsWithGenes(fx$SeqInfo, SeqAligned))
  expect_no_error(drawConsWithGenes(fx$SeqInfo, SeqAligned,
    geneLabels = paste0("Gene_", seq_len(nrow(fx$SeqInfo))),
    consensusLabel = "MyConsensus",
    cex.SeqLabels = 0.7, cex.ConsLabel = 1.2,
    cex.RulerLabels = 0.5, cex.ConsRulerLabels = 0.8))
})

test_that("drawConsWithGenes rejects a geneLabels length mismatch", {
  fx <- make_small_alignment()
  SeqAligned <- suppressWarnings(alignment2Fasta(fx$dna, fx$SeqInfo))
  pdf(NULL)
  on.exit(dev.off(), add = TRUE)

  expect_error(drawConsWithGenes(fx$SeqInfo, SeqAligned, geneLabels = "only one"),
               "one entry per sequence")
})

test_that("drawConsWithNoGenes accepts custom gene labels and independent font sizes", {
  fx <- make_small_alignment()
  SeqAligned <- suppressWarnings(alignment2Fasta(fx$dna, fx$SeqInfo))

  pdf(NULL)
  on.exit(dev.off(), add = TRUE)

  expect_no_error(drawConsWithNoGenes(fx$SeqInfo, SeqAligned))
  expect_no_error(drawConsWithNoGenes(fx$SeqInfo, SeqAligned,
    geneLabels = paste0("Gene_", seq_len(nrow(fx$SeqInfo))),
    cex.SeqLabels = 1, cex.bpLabels = 0.6))
})

test_that("drawConsWithNoGenes rejects a geneLabels length mismatch", {
  fx <- make_small_alignment()
  SeqAligned <- suppressWarnings(alignment2Fasta(fx$dna, fx$SeqInfo))
  pdf(NULL)
  on.exit(dev.off(), add = TRUE)

  expect_error(drawConsWithNoGenes(fx$SeqInfo, SeqAligned, geneLabels = "only one"),
               "one entry per sequence")
})

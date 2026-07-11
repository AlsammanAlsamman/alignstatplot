test_that("theme_alignstatplot returns a usable ggplot theme", {
  expect_s3_class(theme_alignstatplot(), "theme")
  p <- ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y)) + ggplot2::geom_point() + theme_alignstatplot()
  expect_s3_class(p, "ggplot")
})

test_that("plotConservationTrack renders for default and custom colors", {
  m <- make_biallelic_table()
  pc <- positionConservation(m)
  expect_s3_class(plotConservationTrack(pc), "ggplot")
  expect_s3_class(plotConservationTrack(pc, colors = "red"), "ggplot")
})

test_that("plotConservationTrack rejects malformed input", {
  expect_error(plotConservationTrack(data.frame(x = 1)), "positionConservation")
})

test_that("plotVariantDensity renders and respects windowSize", {
  m <- make_biallelic_table()
  p <- plotVariantDensity(m, windowSize = 5)
  expect_s3_class(p, "ggplot")
  expect_equal(nrow(p$data), ceiling(ncol(m) / 5))
})

test_that("plotVariantDensity rejects a non-positive windowSize", {
  m <- make_biallelic_table()
  expect_error(plotVariantDensity(m, windowSize = 0), "positive number")
})

test_that("plotIdentityDistribution renders for a valid distance matrix", {
  fx <- make_small_alignment()
  dm <- getDistanceMatrixTabel(fx$SeqInfo, fx$dna)
  expect_s3_class(plotIdentityDistribution(dm), "ggplot")
})

test_that("plotIdentityDistribution rejects a non-square matrix and too few sequences", {
  expect_error(plotIdentityDistribution(matrix(1, 2, 3)), "square distance matrix")
  expect_error(plotIdentityDistribution(matrix(0, 1, 1)), "At least 2 sequences")
})

test_that("plotSeqStatsSummary renders a 3-panel patchwork", {
  fx <- make_small_alignment()
  SeqAligned <- suppressWarnings(alignment2Fasta(fx$dna, fx$SeqInfo))
  stats <- AlignmentStatsPerSeq(fx$SeqInfo, SeqAligned)
  p <- plotSeqStatsSummary(stats)
  expect_s3_class(p, "patchwork")
})

test_that("plotSeqStatsSummary rejects a table missing the expected columns", {
  expect_error(plotSeqStatsSummary(data.frame(x = 1)), "AlignmentStatsPerSeq")
})

test_that("plotBaseComposition renders with default and custom colors", {
  m <- make_biallelic_table()
  nf <- nucFrequency(m)
  expect_s3_class(plotBaseComposition(nf), "ggplot")
  expect_s3_class(plotBaseComposition(nf, colors = c(A="black",T="black",C="black",G="black",N="black")), "ggplot")
})

test_that("plotBaseComposition rejects a malformed NucCount", {
  expect_error(plotBaseComposition(matrix(1, 3, 3)), "5 rows")
})

test_that("plotRegionStats renders a 2-panel patchwork", {
  m <- make_biallelic_table()
  pc <- positionConservation(m)
  annoFile <- tempfile(fileext = ".txt")
  writeLines(c("ref region1 1 10 forward", "ref region2 11 25 forward"), annoFile)
  rs <- regionStats(pc, annoFile)
  p <- plotRegionStats(rs)
  expect_s3_class(p, "patchwork")
  unlink(annoFile)
})

test_that("plotRegionStats rejects a table missing the expected columns", {
  expect_error(plotRegionStats(data.frame(x = 1)), "regionStats")
})

test_that("plotSummaryDashboard renders a 4-panel composite end to end", {
  fx <- make_small_alignment()
  SeqAligned <- suppressWarnings(alignment2Fasta(fx$dna, fx$SeqInfo))
  dm <- getDistanceMatrixTabel(fx$SeqInfo, fx$dna)
  p <- plotSummaryDashboard(fx$SeqInfo, SeqAligned, dm, windowSize = 3)
  expect_s3_class(p, "patchwork")
})

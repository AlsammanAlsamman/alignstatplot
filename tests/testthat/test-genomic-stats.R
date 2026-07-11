test_that("positionConservation computes majority allele, conservation, entropy and missingness", {
  m <- make_biallelic_table()
  pc <- positionConservation(m)

  expect_equal(colnames(pc), c("Position","MajorityAllele","Conservation","ShannonEntropy","MissingFrac"))
  expect_equal(nrow(pc), ncol(m))
  # biallelic 50/50 A/G columns: majority is "A" (first max in A,C,T,G order), 1 bit of entropy
  expect_equal(pc$MajorityAllele[1:20], rep("A", 20))
  expect_equal(pc$Conservation[1:20], rep(0.5, 20))
  expect_equal(pc$ShannonEntropy[1:20], rep(1, 20))
  # monomorphic A columns: fully conserved, zero entropy
  expect_equal(pc$MajorityAllele[21:25], rep("A", 5))
  expect_equal(pc$Conservation[21:25], rep(1, 5))
  expect_equal(pc$ShannonEntropy[21:25], rep(0, 5))
  expect_equal(pc$MissingFrac, rep(0, 25))
})

test_that("positionConservation reports NA majority/conservation at fully-missing positions", {
  m <- matrix(c("-","-"), nrow = 2, ncol = 1, dimnames = list(c("s1","s2"), "N1"))
  pc <- positionConservation(m)
  expect_true(is.na(pc$MajorityAllele[1]))
  expect_true(is.na(pc$Conservation[1]))
  expect_equal(pc$MissingFrac[1], 1)
})

test_that("positionConservation rejects an empty table (via nucFrequency's own validation)", {
  expect_error(positionConservation(matrix(nrow = 0, ncol = 0)), "non-empty")
})

test_that("nucDiversityStats computes segregating sites, pi, theta and Ts/Tv on known data", {
  m <- make_biallelic_table()
  ds <- nucDiversityStats(m)

  expect_equal(ds$NumSequences, 6)
  expect_equal(ds$AlignmentLength, 25)
  expect_equal(ds$SegregatingSites, 20)
  expect_equal(ds$NucleotideDiversity, 0.48)
  expect_equal(ds$WattersonsTheta, 20 / sum(1 / 1:5) / 25)
  expect_equal(ds$TsTvRatio, Inf) # every biallelic site here is A/G, a transition
})

test_that("nucDiversityStats rejects fewer than 2 sequences", {
  m <- make_biallelic_table()[1, , drop = FALSE]
  expect_error(nucDiversityStats(m), "at least 2 sequences")
})

test_that("regionStats aggregates conservation/variant rate within annotated regions", {
  m <- make_biallelic_table()
  pc <- positionConservation(m)
  annoFile <- tempfile(fileext = ".txt")
  writeLines(c("ref region1 1 10 forward", "ref region2 11 25 forward"), annoFile)

  rs <- regionStats(pc, annoFile)
  expect_equal(rs$Type, c("region1","region2"))
  expect_equal(rs$NumPositions, c(10, 15))
  expect_equal(rs$MeanConservation[1], 0.5)
  expect_equal(rs$MeanConservation[2], (10 * 0.5 + 5 * 1) / 15)
  expect_equal(rs$VariableSites, c(10, 10))
  expect_equal(rs$VariantRate, c(1, 10 / 15))
  unlink(annoFile)
})

test_that("regionStats rejects a missing annotation file and an unknown referenceName", {
  m <- make_biallelic_table()
  pc <- positionConservation(m)
  annoFile <- tempfile(fileext = ".txt")
  writeLines("ref region1 1 10 forward", annoFile)

  expect_error(regionStats(pc, "does/not/exist.txt"), "existing annotation file")
  expect_error(regionStats(pc, annoFile, referenceName = "nope"), "not found in AnnoFilePath")
  unlink(annoFile)
})

test_that("getBiallelicByFreq locates biallelic positions", {
  m <- make_biallelic_table()
  nf <- nucFrequency(m)
  bi <- getBiallelicByFreq(nf)

  expect_equal(bi, 1:20)
})

test_that("getBiallelicByFreq stops when too few biallelic positions are found", {
  # every column monomorphic -> zero biallelic positions
  m <- matrix("A", nrow = 4, ncol = 5, dimnames = list(paste0("s",1:4), paste0("N",1:5)))
  nf <- nucFrequency(m)
  expect_error(getBiallelicByFreq(nf), "biallelic")
})

test_that("getBiallelicByFreq rejects a malformed NucCount", {
  expect_error(getBiallelicByFreq(matrix(1, nrow = 4, ncol = 3)), "5 rows")
})

test_that("getRefGenotypeForbiallelic picks the majority allele per biallelic site", {
  m <- make_biallelic_table()
  nf <- nucFrequency(m)
  bi <- getBiallelicByFreq(nf)
  ref <- getRefGenotypeForbiallelic(nf, bi)

  # A and G are tied 50/50 at every biallelic site -> which.max keeps the
  # first row with the max value, i.e. "A" (rownames order A,C,T,G).
  expect_equal(ref, rep("A", 20))
})

test_that("getRefGenotypeForbiallelic rejects malformed NucCount / biallelic indices", {
  m <- make_biallelic_table()
  nf <- nucFrequency(m)
  expect_error(getRefGenotypeForbiallelic(matrix(1, 4, 3), 1:2), "5 rows")
  expect_error(getRefGenotypeForbiallelic(nf, 999), "valid column indices")
  expect_error(getRefGenotypeForbiallelic(nf, integer(0)), "valid column indices")
})

test_that("seqRefCommon builds a common reference genotype across multiple references", {
  m <- matrix(c("A","G","A", "A","A","A", "A","A","-"), nrow = 3,
              dimnames = list(c("r1","r2","r3"), c("N1","N2","N3")))
  expect_equal(unname(seqRefCommon(m, "r1")), c("A","A","A"))
  # r1 vs r2 disagree at N1 -> becomes gap in the common reference
  expect_equal(unname(seqRefCommon(m, c("r1","r2"))), c("-","A","A"))
})

test_that("seqRefCommon rejects unknown reference names", {
  m <- matrix("A", 2, 2, dimnames = list(c("r1","r2"), c("N1","N2")))
  expect_error(seqRefCommon(m, "nope"), "not present in rownames")
})

test_that("seqTableToBinary converts to 0/1 relative to a named reference, gaps untouched", {
  m <- matrix(c("A","G","A","-", "A","A","G","-"), nrow = 2, byrow = TRUE,
              dimnames = list(c("ref","query"), c("N1","N2","N3","N4")))
  bin <- seqTableToBinary(m, "ref", RemoveNonRefNuc = FALSE, RefsNames = TRUE)

  expect_equal(unname(unlist(bin["ref", ])), c("1","1","1","-"))
  expect_equal(unname(unlist(bin["query", ])), c("1","0","0","-"))
})

test_that("seqTableToBinary drops positions where the reference itself is a gap", {
  m <- matrix(c("A","-","A","G", "A","A","G","G"), nrow = 2, byrow = TRUE,
              dimnames = list(c("ref","query"), c("N1","N2","N3","N4")))
  bin <- seqTableToBinary(m, c("A","-","A","G"), RemoveNonRefNuc = TRUE, RefsNames = FALSE)
  expect_equal(colnames(bin), c("N1","N3","N4"))
})

test_that("seqTableToBinary rejects mismatched Refs input", {
  m <- matrix("A", 2, 3, dimnames = list(c("r1","r2"), c("N1","N2","N3")))
  expect_error(seqTableToBinary(m, "nope", RefsNames = TRUE), "not present in rownames")
  expect_error(seqTableToBinary(m, c("A","A"), RefsNames = FALSE), "one entry per column")
})

test_that("nucTableFilter drops monomorphic and high-missing columns", {
  m <- make_biallelic_table()
  filt <- nucTableFilter(m, MaxMissPer = 0.2, removeMono = TRUE)
  expect_equal(colnames(filt), colnames(m)[1:20])
})

test_that("nucTableFilter rejects an out-of-range MaxMissPer", {
  m <- make_biallelic_table()
  expect_error(nucTableFilter(m, MaxMissPer = 1.5), "between 0 and 1")
  expect_error(nucTableFilter(m, MaxMissPer = -0.1), "between 0 and 1")
})

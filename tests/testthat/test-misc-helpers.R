test_that("seqWithLast includes the endpoint even when the step doesn't land on it", {
  expect_equal(seqWithLast(1, 10, 3), c(1,4,7,10))
  expect_equal(seqWithLast(1, 8, 3), c(1,4,7,8))
})

test_that("seqWithLast rejects a zero step", {
  expect_error(seqWithLast(1, 10, 0), "non-zero")
})

test_that("getSectorWidth allocates sector width proportional to sequence length", {
  SeqInfo <- data.frame(Name = c("g1","g2"), Length = c(100, 300))
  sw <- getSectorWidth(SeqInfo, ConsLength = 400, ZoomFactor = 1)

  expect_equal(sw$sector, c("g1","g2","Consensus"))
  expect_equal(as.numeric(sw$factor), c(100,300,400) / 800)
})

test_that("getSectorWidth rejects invalid ConsLength/ZoomFactor/SeqInfo", {
  SeqInfo <- data.frame(Name = "g1", Length = 100)
  expect_error(getSectorWidth(SeqInfo, ConsLength = 0, ZoomFactor = 1), "positive number")
  expect_error(getSectorWidth(SeqInfo, ConsLength = 100, ZoomFactor = -1), "positive number")
  expect_error(getSectorWidth(data.frame(x = 1), 100, 1), "Name.*Length")
})

test_that("get_os returns a recognized OS string", {
  expect_true(get_os() %in% c("windows","linux","osx"))
})

test_that("formatFolderPath appends the platform-appropriate trailing slash", {
  expect_equal(formatFolderPath("/tmp/foo"), "/tmp/foo/")
  expect_equal(formatFolderPath("/tmp/foo/"), "/tmp/foo/")
})

test_that("seqRemoveAmbiguous replaces IUPAC ambiguity codes and upcases sequence lines", {
  infile <- tempfile(fileext = ".fasta")
  writeLines(c(">s1", "acgtRYSWKMBDHVN", ">s2", "ACGT"), infile)

  outfile <- seqRemoveAmbiguous(infile)
  lines <- readLines(outfile)

  expect_equal(lines[1], ">s1")
  expect_equal(lines[2], "ACGTATCAGCTGAAT")
  expect_equal(lines[3], ">s2")
  expect_equal(lines[4], "ACGT")
})

test_that("seqRemoveAmbiguous rejects a missing input file", {
  expect_error(seqRemoveAmbiguous("does/not/exist.fasta"), "existing fasta file")
})

test_that("AlignedTrueLenght counts non-gap characters", {
  expect_equal(AlignedTrueLenght(c("A","-","T","-","-","G")), 3)
  expect_equal(AlignedTrueLenght(c("-","-","-")), 0)
})

test_that("alignmentNoGaps locates non-gap runs and alignmentNoGapsLinks derives their unaligned regions", {
  SeqAligned <- list(c("A","-","-","T","C"), c("-","G","G","-","-"))
  runs <- alignmentNoGaps(SeqAligned)

  expect_equal(runs[[1]], matrix(c(1,4,1,5), nrow = 2, dimnames = list(NULL, c("start","end"))))
  expect_equal(runs[[2]], matrix(c(2,3), nrow = 1, dimnames = list(NULL, c("start","end"))))

  links <- alignmentNoGapsLinks(SeqAligned, runs)
  expect_equal(length(links), length(SeqAligned))
})

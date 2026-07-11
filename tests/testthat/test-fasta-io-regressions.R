test_that("alignment2Fasta's saved file round-trips cleanly through readSeq (no embedded block spaces)", {
  # Regression test for a real bug report: alignment2Fasta() used to write a
  # clean FASTA, then immediately overwrite it via ape::write.dna(format="fasta")
  # with ape's default block/space formatting (a space every 10 bases).
  # seqinr::read.fasta() (used by readSeq()/getSeqInfo()) does not strip that,
  # so every re-read of the saved file silently gained ~10% spurious "space"
  # characters, corrupting position-based stats (e.g. implausible gap %) and
  # heatmaps for otherwise near-identical sequences.
  m <- matrix(c(
    "A","C","G","T","A","C","G","T","A","C","G","T","A","C","G","T","A","C","G","T","A","C",
    "A","C","G","T","A","C","G","T","A","C","G","T","A","C","G","T","A","C","G","T","A","C"
  ), nrow = 2, byrow = TRUE)
  rownames(m) <- c("seqA", "seqB")
  dna <- ape::as.DNAbin(m)
  SeqInfo <- data.frame(Name = rownames(m), Length = rep(ncol(m), 2), stringsAsFactors = FALSE)

  outFile <- tempfile(fileext = ".fasta")
  alignment2Fasta(dna, SeqInfo, outFile)

  rawLines <- readLines(outFile)
  expect_false(any(grepl(" ", rawLines))) # no embedded block-separator spaces

  reread <- getSeqInfo(outFile)
  expect_equal(reread$Length, rep(ncol(m), 2)) # not inflated by spurious space "residues"

  fs <- readSeq(outFile)
  expect_equal(toupper(as.character(fs[[1]])), unname(m["seqA", ]))
  unlink(outFile)
})

test_that("getDistanceMatrixTabel's internal round-trip does not corrupt sequences with spaces", {
  # Same root cause as above, but inside getDistanceMatrixTabel()'s own
  # write.dna()/read.alignment() round-trip -- this one affected the distance
  # matrix (and therefore the tree/heatmap/PCA) on every single call, not just
  # when re-reading a saved file.
  m <- matrix(c(
    "A","C","G","T","A","C","G","T","A","C","G","T","A","C","G","T","A","C","G","T","A","C",
    "A","C","G","T","A","C","G","T","A","C","G","T","A","C","G","T","A","C","G","T","A","C"
  ), nrow = 2, byrow = TRUE)
  rownames(m) <- c("seqA", "seqB")
  dna <- ape::as.DNAbin(m)
  SeqInfo <- data.frame(Name = rownames(m), Length = rep(ncol(m), 2), stringsAsFactors = FALSE)

  dm <- getDistanceMatrixTabel(SeqInfo, dna)
  # identical sequences -> identity distance must be exactly 0, not inflated
  # by spurious matching/mismatching "space" residues from block formatting
  expect_equal(dm["seqA", "seqB"], 0)
})

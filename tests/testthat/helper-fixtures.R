# Shared fixtures for the analysis-function regression suite.
# Kept deliberately small/handcrafted where the expected values need to be
# known by construction, and backed by the bundled inst/extdata files where a
# real end-to-end alignment is needed (no external alignment binary required:
# fixtures build an ape::DNAbin directly instead of calling seqAlign()).

make_small_alignment <- function() {
  # 5 sequences x 8 sites, handcrafted so gap/GC/biallelic counts are known.
  m <- matrix(
    c("A","T","C","G","A","T","C","G",
      "A","T","C","G","A","T","C","G",
      "A","T","C","G","A","T","G","G",
      "A","T","C","G","-","T","G","G",
      "A","T","C","G","-","T","G","G"),
    nrow = 5, byrow = TRUE
  )
  rownames(m) <- paste0("seq", 1:5)
  dna <- ape::as.DNAbin(m)
  SeqInfo <- data.frame(Name = rownames(m), Length = rep(ncol(m), nrow(m)),
                        stringsAsFactors = FALSE)
  list(SeqInfo = SeqInfo, dna = dna)
}

make_biallelic_table <- function() {
  # 6 sequences x 25 positions. Columns 1:20 are biallelic A/G (3 rows A, 3
  # rows G); columns 21:25 are monomorphic A. Ground truth is known exactly.
  nseq <- 6
  ncol_bi <- 20
  ncol_mono <- 5
  bi <- matrix(rep(c("A","A","A","G","G","G"), ncol_bi), nrow = nseq)
  mono <- matrix("A", nrow = nseq, ncol = ncol_mono)
  m <- cbind(bi, mono)
  rownames(m) <- paste0("seq", 1:nseq)
  colnames(m) <- paste0("N", 1:ncol(m))
  m
}

make_mixed_allele_table <- function() {
  # 6 sequences x 22 positions: N1..N20 biallelic A/G (as in
  # make_biallelic_table()), N21/N22 triallelic (3 distinct alleles, so
  # nucTableFilter's removeMono keeps them, but getBiallelicByFreq correctly
  # excludes them). Reproduces the shape mismatch that alignstatplot()'s
  # binary-conversion step must guard against: GenotypeRef only covers the
  # biallelic subset, not every column nucTableFilter kept.
  bi <- make_biallelic_table()[, 1:20]
  tri <- matrix(rep(c("A","C","G","A","C","G"), 2), nrow = 6)
  m <- cbind(bi, tri)
  colnames(m) <- paste0("N", 1:ncol(m))
  m
}

bundled_seq_info <- function() {
  fasta <- system.file("extdata", "Example_Sequences_Aligned.fasta", package = "alignstatplot")
  getSeqInfo(fasta)
}

bundled_alignment <- function() {
  fasta <- system.file("extdata", "Example_Sequences_Aligned.fasta", package = "alignstatplot")
  ape::read.dna(fasta, format = "fasta")
}

make_two_cluster_table <- function() {
  # 8 sequences x 20 positions with two distinct co-variation patterns, so
  # SNPCluster (HCPC) has a real, deterministic non-trivial clustering to
  # find: N1-N10 split 4A/4G by sequence, N11-N20 split alternating A/G.
  nseq <- 8
  clusterA <- matrix(rep(c("A","A","A","A","G","G","G","G"), 10), nrow = nseq)
  clusterB <- matrix(rep(c("A","G","A","G","A","G","A","G"), 10), nrow = nseq)
  m <- cbind(clusterA, clusterB)
  rownames(m) <- paste0("seq", 1:nseq)
  colnames(m) <- paste0("N", 1:ncol(m))
  m
}

#' Population-genetics summary statistics for an alignment
#'
#' @description Computes classic diversity statistics directly from an aligned sequence
#' table: the count of segregating (variable) sites, nucleotide diversity (\eqn{\pi}, the
#' expected proportion of differing sites between two random sequences), Watterson's
#' \eqn{\theta}, and the transition/transversion (Ts/Tv) ratio across strictly biallelic
#' sites (A/G and C/T pairs are transitions; all other pairs are transversions).
#' @param SeqAlignedTable A Table of aligned sequences (rows) x nucleotides (columns)
#' generated using \code{\link{alignment2Table}}
#' @return a single-row data.frame with \code{NumSequences}, \code{AlignmentLength},
#' \code{SegregatingSites}, \code{NucleotideDiversity}, \code{WattersonsTheta},
#' \code{TsTvRatio}
#' @export
nucDiversityStats<-function(SeqAlignedTable)
{
  NucCount<-nucFrequency(SeqAlignedTable)
  if (nrow(SeqAlignedTable) < 2) {
    stop("nucDiversityStats requires at least 2 sequences, got ", nrow(SeqAlignedTable), ".")
  }

  n<-nrow(SeqAlignedTable)
  L<-ncol(SeqAlignedTable)
  bases<-c("A","C","T","G")
  freqs<-NucCount[bases, , drop = FALSE]

  nAlleles<-colSums(freqs > 0)
  SegregatingSites<-sum(nAlleles > 1)

  #Nucleotide diversity: unbiased per-site heterozygosity averaged over all sites
  siteHet<-1 - colSums(freqs^2)
  NucleotideDiversity<-(n / (n - 1)) * mean(siteHet)

  #Watterson's theta
  a_n<-sum(1 / seq_len(n - 1))
  WattersonsTheta<-(SegregatingSites / a_n) / L

  #Ts/Tv ratio across strictly biallelic sites
  transitionPairs<-list(c("A","G"), c("C","T"))
  biallelicPos<-which(nAlleles == 2)
  Ts<-0; Tv<-0
  for (pos in biallelicPos) {
    alleles<-sort(bases[freqs[, pos] > 0])
    isTs<-any(vapply(transitionPairs, function(p) identical(alleles, sort(p)), logical(1)))
    if (isTs) Ts<-Ts + 1 else Tv<-Tv + 1
  }
  TsTvRatio<-if (Tv > 0) Ts / Tv else if (Ts > 0) Inf else NA_real_

  data.frame(
    NumSequences = n,
    AlignmentLength = L,
    SegregatingSites = SegregatingSites,
    NucleotideDiversity = NucleotideDiversity,
    WattersonsTheta = WattersonsTheta,
    TsTvRatio = TsTvRatio
  )
}

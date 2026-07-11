#' Per-position conservation, entropy and missingness across an alignment
#'
#' @description For every column (position) of an aligned sequence table, reports the
#' majority allele among A/C/T/G, the fraction of sequences matching it (conservation),
#' the Shannon entropy of the full A/C/T/G/N distribution (in bits), and the fraction of
#' missing/gapped calls (N). Built directly on \code{\link{nucFrequency}} so there is a
#' single source of truth for per-position nucleotide proportions.
#' @param SeqAlignedTable A Table of aligned sequences (rows) x nucleotides (columns)
#' generated using \code{\link{alignment2Table}}
#' @return data.frame with one row per alignment position: \code{Position},
#' \code{MajorityAllele} (\code{NA} if every call at that position is missing),
#' \code{Conservation} (0-1, \code{NA} where \code{MajorityAllele} is \code{NA}),
#' \code{ShannonEntropy} (bits), \code{MissingFrac} (0-1)
#' @export
positionConservation<-function(SeqAlignedTable)
{
  NucCount<-nucFrequency(SeqAlignedTable)
  bases<-c("A","C","T","G")
  baseFreqs<-NucCount[bases, , drop = FALSE]

  majorIdx<-apply(baseFreqs, 2, which.max)
  Conservation<-apply(baseFreqs, 2, max)
  MajorityAllele<-bases[unlist(majorIdx)]
  allMissing<-Conservation == 0
  MajorityAllele[allMissing]<-NA
  Conservation[allMissing]<-NA

  allFreqs<-NucCount[c(bases, "N"), , drop = FALSE]
  ShannonEntropy<-apply(allFreqs, 2, function(p) {
    p<-p[p > 0]
    -sum(p * log2(p))
  })

  data.frame(
    Position = factor(colnames(NucCount), levels = colnames(NucCount)),
    MajorityAllele = MajorityAllele,
    Conservation = as.numeric(Conservation),
    ShannonEntropy = as.numeric(ShannonEntropy),
    MissingFrac = as.numeric(NucCount["N", ]),
    stringsAsFactors = FALSE
  )
}

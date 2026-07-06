#' Get a reference sequence using biallelic nucleotides
#' @description #' Get a sequence can be used as a reference for sequence binary
#' conversion using for only biallelic nucleotides
#' @param NucCount Table of nucleotide frequency \code{\link{nucFrequency}}
#' @param biallelic location of biallelic nucleotides \code{\link{getBiallelicByFreq}}
#'
#' @return a vector of nucleotides can be used as a reference
#' @export
getRefGenotypeForbiallelic<-function(NucCount,biallelic)
{
  if (is.null(dim(NucCount)) || nrow(NucCount) != 5) {
    stop("NucCount must have exactly 5 rows (A, C, T, G, N), as returned by nucFrequency().")
  }
  if (length(biallelic) == 0 || any(biallelic < 1) || any(biallelic > ncol(NucCount))) {
    stop("biallelic must be a vector of valid column indices into NucCount, as returned by getBiallelicByFreq().")
  }
  #get biallelic nucleotides Frequency table
  MajorNucFreq<-NucCount[-5,] #remove N row
  MajorNucFreqBiallelic<-MajorNucFreq[,biallelic]
  rownames(MajorNucFreqBiallelic)[apply(MajorNucFreqBiallelic,2,which.max)]
}

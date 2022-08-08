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
  #get biallelic nucleotides Frequency table
  MajorNucFreq<-NucCount[-5,] #remove N row
  MajorNucFreqBiallelic<-MajorNucFreq[,biallelic]
  rownames(MajorNucFreqBiallelic)[apply(MajorNucFreqBiallelic,2,which.max)]
}

#' Return biallelic nucleotide location in frequency table
#' @description takes the nucleotide frequency and returns the location of
#' biallelic loci such as A/G
#' @param NucCount Table of nucleotide frequency \code{\link{nucFrequency}}
#' @return a vector of nucleotide locations in consensus sequence
#' @export
getBiallelicByFreq<-function(NucCount)
{
  MajorNucFreq<-NucCount[-5,] #discard N row for missing
  biallelic<-c()
  for (n in 1:ncol(MajorNucFreq)) {
    alleles<-which(MajorNucFreq[,n]>0)    #Which Alleles have representation in every sequence
    if (length(alleles)==2) {             #if locations contains only two nucleotides representation (biallelic)
      biallelic<-c(biallelic,n)
    }
  }

  if (length(biallelic)<=15) {
    stop(paste("Number of biallelic nucleotides is :",length(biallelic),
        "
        Your sequence alignment contains no/or few biallelic
        nucleotides and cannot be used for further analysis;
        this may occur if the sequences are
        extremely dissimilar."))
  }
  biallelic
}

#' Filter aligned seq table from missing and mono
#' @param SeqTable ist of sequence vectors \code{\link{alignment2Fasta}}
#' @param MaxMissPer Maximum percentage of missing nucleotides
#' @param removeMono bool value remove monomorphic variations
#' @return data frame
#' @export
nucTableFilter<-function(SeqTable,MaxMissPer=0.2,removeMono=T){

  #Frequency Table
  NucFreqTable<-nucFrequency(SeqTable)

  #Filtering
  N.good<-c()
  i<-1
  for (N in 1:ncol(NucFreqTable)) {
    NI.stat<-NucFreqTable[,N]
    if (NI.stat[5]>MaxMissPer) {next} #If missing is max
    if (removeMono) {
      #Count Allele
      N.allele<-0
      for (Nc in 1:4) {
        if (NI.stat[Nc]>0) {
          N.allele<-N.allele+1
        }
      }
      #if Mono ignore
      if (N.allele<2) {
        next
      }
    }
    #If goo add to array
    N.good[i]<-N
    i<-i+1
  }
  #return good table
  SeqTable[,c(N.good)]
}

#' Calculates nucleotide Frequency across sequences
#'
#' @param TargetTable A Table of aligned sequences (rows) x nucleotides (columns)
#' generated using \code{\link{alignment2Table}}
#' @return Table of nucleotide frequencies across the sequences including
#' the missing nucleotide (N)
#' @export
nucFrequency<-function(TargetTable){
  #be aware that
  SeqN<-nrow(TargetTable)
  NucCount<-matrix(nrow = 5, ncol = ncol(TargetTable))
  rownames(NucCount)<-c("A","C","T","G","N")
  colnames(NucCount)<-colnames(TargetTable)
  TargetTable[!(TargetTable %in% c("A","T","C","G"))]<-"-" #ALL Degenerate Nucleotides and Gaps will be removed

  NucCount["A",]<-colSums(TargetTable == "A")/SeqN
  NucCount["C",]<-colSums(TargetTable == "C")/SeqN
  NucCount["T",]<-colSums(TargetTable == "T")/SeqN
  NucCount["G",]<-colSums(TargetTable == "G")/SeqN
  NucCount["N",]<-colSums(TargetTable=="-")/SeqN
  NucCount<-as.data.frame(NucCount)
  NucCount
}

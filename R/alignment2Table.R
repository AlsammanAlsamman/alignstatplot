#' Sequence Alignment to Table
#' @param SeqAligned list of sequnece vectors \code{\link{alignment2Fasta}}
#' @param SeqInfo table of sequence information generated using \code{\link{getSeqInfo}}
#' @description Converts sequence alignment to data frame format
#' @return A data.frame object
#' @export
alignment2Table<-function(SeqInfo,SeqAligned){
  SeqAlignedTable<-do.call(rbind, SeqAligned) #convert SeqAlignment to Table
  rownames(SeqAlignedTable)<-SeqInfo$Name     #Rows as sample/genes
  colnames(SeqAlignedTable)<-paste0("N",1:ncol(SeqAlignedTable))  #columns as Nucleotides
  SeqAlignedTable
}

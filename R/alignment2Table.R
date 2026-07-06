#' Sequence Alignment to Table
#' @param SeqAligned list of sequnece vectors \code{\link{alignment2Fasta}}
#' @param SeqInfo table of sequence information generated using \code{\link{getSeqInfo}}
#' @description Converts sequence alignment to data frame format
#' @return A data.frame object
#' @export
alignment2Table<-function(SeqInfo,SeqAligned){
  if (!is.data.frame(SeqInfo) || !all(c("Name","Length") %in% colnames(SeqInfo))) {
    stop("SeqInfo must be a data.frame with 'Name' and 'Length' columns, as returned by getSeqInfo().")
  }
  if (length(SeqAligned) != nrow(SeqInfo)) {
    stop("SeqAligned has ", length(SeqAligned), " sequences but SeqInfo has ", nrow(SeqInfo),
         " rows; they must describe the same set of sequences in the same order.")
  }
  SeqAlignedTable<-do.call(rbind, SeqAligned) #convert SeqAlignment to Table
  rownames(SeqAlignedTable)<-SeqInfo$Name     #Rows as sample/genes
  colnames(SeqAlignedTable)<-paste0("N",1:ncol(SeqAlignedTable))  #columns as Nucleotides
  SeqAlignedTable
}

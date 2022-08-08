#' Write Sequence Alignment to fasta or return it as a list of sequences
#'
#' @param alignment sequence alignment object \code{\link[msa]{msa}} \code{\link{seqAlign}}
#' @param SeqInfo Information of the sequences \code{\link{getSeqInfo}}
#' @param filename If it was set, the file name sequences will be written in file
#' @importFrom msa msaConvert
#' @return A list of vectors of aligned sequences or write it to file
#' @export
#' @examples
#' seqFile<-system.file("extdata","sequence_few.fasta",package = "alignstatplot")
#' myClustalWAlignment <- seqAlign(seqFile,"ClustalW")
#' SeqAligned<-alignment2Fasta(myClustalWAlignment,SeqInfo)
#' SeqAligned
alignment2Fasta <- function(alignment,SeqInfo,filename="") {
  alignCW_as_align <- msaConvert(alignment, "bios2mds::align")
  if (filename=="") {
    return(alignCW_as_align)
  }
  for (seq in 1:length(alignCW_as_align)) {
    write(paste0(">",SeqInfo[seq,]$Name),filename,append = TRUE)
    write(gsub("(.{60})", "\\1\n", paste(alignCW_as_align[[seq]], collapse = '')),filename,append = TRUE)
  }
}

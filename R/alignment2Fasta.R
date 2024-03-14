#' Write Sequence Alignment to fasta or return it as a list of sequences
#'
#' @param alignment sequence alignment object \code{\link[ape]{DNAbin}} \code{\link{seqAlign}}
#' @param SeqInfo Information of the sequences \code{\link{getSeqInfo}}
#' @param filename If it was set, the file name sequences will be written in file
#' @return A list of vectors of aligned sequences or write it to file
#' @export
#' @examples
#' seqFile<-system.file("extdata","sequence_few.fasta",package = "alignstatplot")
#' myClustalWAlignment <- seqAlign(seqFile,"ClustalW")
#' SeqAligned<-alignment2Fasta(myClustalWAlignment,SeqInfo)
#' SeqAligned
alignment2Fasta <- function(alignment,SeqInfo,filename="",format="blocks") {
  # convert to List of sequences
  SeqAlignList<- alignment %>% as.list() %>% as.character %>%
    lapply(.,paste0,collapse="")
  # change the name of the sequences according to the SeqInfo
  names(SeqAlignList)<-SeqInfo$Name
  # write to file
  if (filename!="") {
    for (seq in 1:length(SeqAlignList)) {
      write(paste0(">",SeqInfo[seq,]$Name),filename,append = TRUE)
      write(gsub("(.{60})", "\\1\n", SeqAlignList[[seq]]),filename,append = TRUE)
    }
  }
  # save as aln file
  if (format=="blocks") {
    write.dna(alignment, file = filename, format = "fasta")
  }
  # split the sequences
  SeqAlignListSplit<-lapply(SeqAlignList,function(x) unlist(strsplit(x,"")))
  # to upper case
  SeqAlignListSplit<-lapply(SeqAlignListSplit,toupper)
  # SeqAlignListSplit
  # return the list of sequences
  #SeqAlignListSplit
  return(SeqAlignListSplit)
}

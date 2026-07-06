#' Write Sequence Alignment to fasta or return it as a list of sequences
#'
#' @param alignment sequence alignment object \code{\link[ape]{DNAbin}} \code{\link{seqAlign}}
#' @param SeqInfo Information of the sequences \code{\link{getSeqInfo}}
#' @param filename If it was set, the file name sequences will be written in file
#' @param format if "blocks" (default), also write the alignment to \code{filename} via \code{\link[ape]{write.dna}}
#' @return A list of vectors of aligned sequences or write it to file
#' @export
#' @examples
#' \dontrun{
#' # requires the ClustalW executable to be installed and on the PATH
#' seqFile<-system.file("extdata","Example_Small.fasta",package = "alignstatplot")
#' SeqInfo<-getSeqInfo(seqFile)
#' myClustalWAlignment <- seqAlign(seqFile,"ClustalW")
#' SeqAligned<-alignment2Fasta(myClustalWAlignment,SeqInfo)
#' SeqAligned
#' }
alignment2Fasta <- function(alignment,SeqInfo,filename="",format="blocks") {
  if (!is.data.frame(SeqInfo) || !all(c("Name","Length") %in% colnames(SeqInfo))) {
    stop("SeqInfo must be a data.frame with 'Name' and 'Length' columns, as returned by getSeqInfo().")
  }
  if (length(as.list(alignment)) != nrow(SeqInfo)) {
    stop("alignment has ", length(as.list(alignment)), " sequences but SeqInfo has ", nrow(SeqInfo),
         " rows; they must describe the same set of sequences in the same order.")
  }
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

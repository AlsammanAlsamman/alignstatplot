#' Split aligned sequence to list of vectors
#' @description Split aligned sequences to list of vectors where every vector
#' contains a list of a part (split range) of every aligned sequence
#' @param SeqAligned Sequences aligned \code{\link{alignment2Fasta}}
#' @param splitRange Integer -- number of nucleotides in every plot
#' @return A list of vectors
#' @export
getSeqLogo<-function(SeqAligned,splitRange=20){
  #get the aligned sequences and calculate the location of links
  SeqSplitList<-list()  #container for separated sequences
  for (seq in 1:length(SeqAligned)) {
    seq.aligend<-paste(SeqAligned[[seq]], collapse = '') #sequence as one string
    SeqSplit<-strsplit(seq.aligend, paste0("(?<=.{",splitRange,"})"), perl = TRUE)[[1]] #split sequence
    SeqSplitList[[seq]]<-SeqSplit
  }

  ConsusSeqList<-list()   #container for separated sequences
  FragN<-length(SeqSplitList[[1]])
  for (i in 1:FragN) {
    ThisList<-c()
    for (j in 1:length(SeqAligned)) {
      ThisList[j]<-SeqSplitList[[j]][i]
    }
    ConsusSeqList[[i]]<-ThisList
  }
  ConsusSeqList
}

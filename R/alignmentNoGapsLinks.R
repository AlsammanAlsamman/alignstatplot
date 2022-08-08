#' Get links for alignment regions
#'
#' @param SeqAligned list of sequence vectors \code{\link{alignment2Fasta}}
#' @param SeqHighLights list of sequence vectors \code{\link{alignmentNoGaps}}
#' @description In aligned seq out location of non gaped sequence in the original sequence (list)
#' used for drawing sequences in circos
#' @return a list for the location of sequence alignment links between sequences for regions
#' similar in sequences
#' @export
#' @importFrom stringr str_locate_all
#' @importFrom stringr str_replace_all
alignmentNoGapsLinks<-function(SeqAligned,SeqHighLights){
  #get the aligned sequences and calculate the location of links
  SeqLinks<-list()
  for (seq in 1:length(SeqAligned)) {
    seq.aligend<-paste(SeqAligned[[seq]], collapse = '')
    NonGaps<-SeqHighLights[[seq]]

    for (Frag in 1:nrow(NonGaps)) {
      Hstart<-as.numeric(NonGaps[Frag,][1])
      Hend<-as.numeric(NonGaps[Frag,][2])
      substr(seq.aligend, Hstart, Hstart) <- "$"
      substr(seq.aligend, Hend, Hend) <- "%"
      if (Hstart==Hend) {
        #if single letter in the alignment
        seq.aligend<-gsub(paste0('-%-'), '-$%-', seq.aligend)
      }
    }
    seq.aligend
    #remove "-"
    seq.aligend<-str_replace_all(seq.aligend, "-", "")
    #locate regions between $ and %
    SeqLinks[seq]<-getSeqRegion(seq.aligend)
  }

  SeqLinks
}




#' getSeqRegion_ C implementation
#'
#' @param seqMarked character vector of aligned sequence
#'
#' @return list of vectors of regions locations
getSeqRegionCI <- function(seqMarked)
{

   dyn.load(paste0(.libPaths()[1],"/alignstatplot","/libs","/alignstatplot.so"))
  .Call("getSeqRegion",as.character(seqMarked),PACKAGE = "alignstatplot")
}

#' Get regions of sequences in sequence aligned with marks
#'
#' @param seqMarked character vector of aligned sequence
#'
#' @return list of locations
getSeqRegion <- function(seqMarked)
{
  regions<-getSeqRegionCI(seqMarked)
  regionsList <- list(matrix(unlist(regions), nrow=length(regions), byrow=TRUE))
  regionsList
}

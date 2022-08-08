#' Get sequence alignment list of sequences without gaps
#'
#' @param  SeqAligned list of sequence vectors \code{\link{alignment2Fasta}}
#' @description In Aligned seq out location of non gap sequence (list)
#' it used in the algorithm of drawing circle sequences
#' @return A list of sequences without gaps
#' @export
#' @importFrom  stringr str_locate_all
alignmentNoGaps<-function(SeqAligned){
  SeqHighLights<-list()
  for (seq in 1:length(SeqAligned)) {
    seq.aligend<-paste(SeqAligned[[seq]], collapse = '')
    SeqHighLights[seq]<-str_locate_all(seq.aligend, "[A-Z|a-z]+")
  }
  SeqHighLights
}

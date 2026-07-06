#' Calculate Zooming factor and sector width for circular plot with links
#'
#' @param SeqInfo Table of sequence information \code{\link{getSeqInfo}}
#' @param ConsLength Length of the sequence in base pair
#' @param ZoomFactor A number between 1-10 for the size of the consensus representation
#' in relative to the other sequences
#' @return A table for every sector name (sequence) and zooming ratio
#' @export
getSectorWidth<-function(SeqInfo,ConsLength,ZoomFactor){
  if (!is.data.frame(SeqInfo) || !all(c("Name","Length") %in% colnames(SeqInfo))) {
    stop("SeqInfo must be a data.frame with 'Name' and 'Length' columns, as returned by getSeqInfo().")
  }
  if (!is.numeric(ConsLength) || length(ConsLength) != 1 || ConsLength <= 0) {
    stop("ConsLength must be a single positive number, got: ", ConsLength)
  }
  if (!is.numeric(ZoomFactor) || length(ZoomFactor) != 1 || ZoomFactor <= 0) {
    stop("ZoomFactor must be a single positive number, got: ", ZoomFactor)
  }
  mat<-matrix(nrow = nrow(SeqInfo), ncol = 2)
  sector.width<-as.data.frame(mat)
  colnames(sector.width)<-c("sector","factor")
  sector.width$sector<-SeqInfo$Name
  sector.width$factor<-SeqInfo$Length
  SeqTotalLen<-sum(sector.width$factor)
  sector.width$factor<-sector.width$factor/sum(SeqTotalLen,ConsLength*ZoomFactor)
  ConsZoomedFacLen<-ConsLength*ZoomFactor/sum(SeqTotalLen,ConsLength*ZoomFactor)
  sector.width[nrow(sector.width)+1,]<-c("Consensus",ConsZoomedFacLen)
  sector.width
}

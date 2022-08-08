#' Get distance matrix for sequence alignment
#'
#' @param seqInfo Table of sequence information \code{\link{getSeqInfo}}
#' @param seqAlignment sequence alignment list generated using \code{\link[msa]{msa}}
#'
#' @return matrix of sequences similarity distances
#' @export
#' @importFrom msa msaConvert
#' @importFrom seqinr dist.alignment
getDistanceMatrixTabel<-function(seqInfo,seqAlignment)
{
  #Convert Sequence Alignment
  seqAlignmentConvert<-msaConvert(seqAlignment,type = "seqinr::alignment")
  #Extract Distance Matrix
  DistMatrix<-dist.alignment(seqAlignmentConvert, matrix = "identity" )
  DistMatrix<-as.matrix(DistMatrix)
  DistMatrixTable <-as.data.frame(DistMatrix)
  rownames(DistMatrixTable)<-seqInfo$Name   #replace rownames with sequences names
  colnames(DistMatrixTable)<-seqInfo$Name
  DistMatrixTable
}

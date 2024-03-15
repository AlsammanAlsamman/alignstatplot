#' Get distance matrix for sequence alignment
#'
#' @param seqInfo Table of sequence information \code{\link{getSeqInfo}}
#' @param seqAlignment sequence alignment list
#'
#' @return matrix of sequences similarity distances
#' @export
#' @importFrom seqinr dist.alignment
getDistanceMatrixTabel<-function(seqInfo,seqAlignment)
{
  # save to temporary file
  tempFile <- tempfile(fileext = ".fasta")
  write.dna(seqAlignment, file = tempFile, format = "fasta")
  # read as alignment
  seqAlignment <- read.alignment(tempFile, format = "fasta")
  # remove temporary file
  unlink(tempFile)
  #Extract Distance Matrix
  DistMatrix<-dist.alignment(seqAlignment, matrix = "identity" )
  DistMatrix<-as.matrix(DistMatrix)
  DistMatrixTable <-as.data.frame(DistMatrix)
  rownames(DistMatrixTable)<-seqInfo$Name   #replace rownames with sequences names
  colnames(DistMatrixTable)<-seqInfo$Name
  DistMatrixTable
}

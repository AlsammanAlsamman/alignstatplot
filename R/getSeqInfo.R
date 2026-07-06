#' Extract sequence information from a fasta file
#'
#' @param SeqFilePath Fasta file path
#' @importFrom seqinr getName getLength
#' @return A table of sequence information
#' \itemize{
#'   \item Name - Sequence Name
#'   \item Length - Sequence in base pairs
#' }
#' @export
#' @examples
#' SeqFile<-system.file("extdata","Example_Small.fasta",package = "alignstatplot")
#' SeqInfo<-getSeqInfo(SeqFile)
#' SeqInfo
getSeqInfo<-function(SeqFilePath)
{
  if (!is.character(SeqFilePath) || length(SeqFilePath) != 1 || !file.exists(SeqFilePath)) {
    stop("SeqFilePath must be a path to an existing fasta file; got: ", paste(SeqFilePath, collapse = ", "))
  }
  fastaFile<-readSeq(SeqFilePath)
  Names<-seqinr::getName(fastaFile)
  Lengths<-seqinr::getLength(fastaFile)
  mat<-matrix( nrow = length(Names), ncol = 2)
  SeqInfo<-as.data.frame(mat)
  colnames(SeqInfo)<-c("Name","Length")
  SeqInfo$Name<-Names
  SeqInfo$Length<-Lengths
  SeqInfo
}

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
#' SeqFile<-SeqFile<-system.file("extdata","sequence_few.fasta",package = "alignstatplot")
#' fs <- read.fasta(file = SeqFile,forceDNAtolower = TRUE,apply.mask = T)
#' SeqInfo<-getSeqInfo(fs)
#' SeqInfo
getSeqInfo<-function(SeqFilePath)
{
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

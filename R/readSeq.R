#' Read and reformat fasta sequence
#' @param fastaPath path of fasta file
#' @param outPath output folder path
#' @return return a list of vector of chars. Each element is a sequence
#' object of the class 'SeqFastadna'
#' @export
#' @importFrom seqinr read.fasta
readSeq<-function(fastaPath,outPath)
{
  #read clean Sequence File
  fs <- read.fasta(file = fastaPath,forceDNAtolower = TRUE
                   ,apply.mask = T) #Read Sequence as lowercase
  fs
}

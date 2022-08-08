#' Perfom sequence alignment
#'
#' @param SeqFile sequence file path
#' @param AlignMethod specifies the multiple sequence alignment to be used; currently, "ClustalW",
#' "ClustalOmega", and "Muscle" are supported.
#' @param SeqType "dna"
#' @param order Ordering sequences in the list random or according to the input
#' @import msa msa
#' @return Returns MsaDNAMultipleAlignment \code{\link[msa]{msa}}
#' @export
seqAlign<-function(SeqFile, AlignMethod,SeqType="dna",order = "input")
{
  #Remove amiguous nucleotides
  SeqFile<-seqRemoveAmbiguous(SeqFile)
  #perform sequence alignment
  Alignment <- msa(inputSeqs=SeqFile, method = AlignMethod,
                             type = SeqType,order = order) #perform align
  Alignment
}

#' Perfom sequence alignment
#'
#' @param SeqFile sequence file path
#' @param AlignMethod specifies the multiple sequence alignment to be used; currently, "ClustalW",
#' "ClustalOmega", and "Muscle" are supported.
#' @param SeqType "dna"
#' @param order Ordering sequences in the list random or according to the input
#' @import ape
#' @return Returns MsaDNAMultipleAlignment
#' @export
seqAlign<-function(SeqFile, AlignMethod,SeqType="dna",order = "input")
{
  #Remove amiguous nucleotides
  SeqFile<-seqRemoveAmbiguous(SeqFile)
  # read fasta file using ape
  DNA <- read.dna(SeqFile, format = "fasta")
  Alignment <- NULL
  if (AlignMethod=="ClustalW") {

     Alignment <- clustal(DNA, MoreArgs = "", quiet = TRUE,
                          original.ordering = TRUE)
  } else if (AlignMethod=="Muscle") {
    Alignment <- muscle(DNA, MoreArgs = "", quiet = TRUE,
                        original.ordering = TRUE)
  } else if (AlignMethod=="ClustalOmega") {
    Alignment <- clustalomega(DNA, MoreArgs = "", quiet = TRUE,
                              original.ordering = TRUE)
  } else if(AlignMethod=="tcoffee") {
    Alignment <- tcoffee(DNA,  exec = "t_coffee", MoreArgs = "", quiet = TRUE,
                         original.ordering = TRUE)
  } else {
    stop("Alignment method not supported")
  }
  Alignment
}

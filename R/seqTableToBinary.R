#' Convert table of aligned sequence to binary format
#' @description Convert Sequence Table aligned to Binary Format according
#' to reference
#' @param SeqAlignedTable list of aligned vectors contains aligned sequences using \code{\link{alignment2Fasta}}
#' @param Refs vector of sequences IDs to be used as a reference for
#' bionary conversion
#' @param RemoveNonRefNuc logical -- remove nucleotide absent in reference (Insertions)
#' @param RefsNames logical is the provided is reference IDs or a reference as avector generated
#' using \code{\link{seqRefCommon}} or \code{\link{getRefGenotypeForbiallelic}}
#'
#' @return Table of 0/1 variations
#' @export
seqTableToBinary<-function(SeqAlignedTable,Refs,RemoveNonRefNuc=T,RefsNames=T)
{

  RefGenotype<-c()
  if (RefsNames) {
    #extract ref sequence (s) if one or many are chosen to be the reference
    RefGenotype<-seqRefCommon(SeqAlignedTable,Refs)
  }
  else{
    #The reference is already offered as a vector of nucleotides
    RefGenotype<-Refs
  }
  SeqNames<-rownames(SeqAlignedTable)
  #create Table
  SeqAlignedBinary<-as.data.frame(matrix(nrow = length(SeqNames), ncol = ncol(SeqAlignedTable)))
  colnames(SeqAlignedBinary)<-colnames(SeqAlignedTable)
  rownames(SeqAlignedBinary)<-SeqNames
  #loop through sequences
  for (seq in SeqNames) {
    QuerySeq<-as.vector(SeqAlignedTable[seq,])
    NotGapLoc<-which(QuerySeq!="-")          #Get Not Gaps locations
    RefLike<-QuerySeq[NotGapLoc]==RefGenotype[NotGapLoc]    #same as reference
    RefNotLike<-!RefLike #Not the same as reference
    QuerySeq[NotGapLoc][RefNotLike]<-0
    QuerySeq[NotGapLoc][RefLike]<-1
    SeqAlignedBinary[seq,]<-QuerySeq
  }
  #remove nucleotides not exist in the reference sequence
  if (RemoveNonRefNuc) {
    SeqAlignedBinary<-SeqAlignedBinary[,which(RefGenotype!="-")]
  }
  SeqAlignedBinary
}

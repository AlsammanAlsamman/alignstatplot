#' Create reference form a batch/single sequence
#'
#' @param SeqAlignedTable list of aligned vectors contains aligned sequences using \code{\link{alignment2Fasta}}
#' @param RefsNames vector of sequences names chosen as reference
#'
#' @return vector of single sequence can be used as a reference
#' @export
seqRefCommon<-function(SeqAlignedTable,RefsNames)
{
  #Using Multiple References
  #take the first one as reference
  RefGenotype<-SeqAlignedTable[RefsNames[1],]
  SeqNames<-rownames(SeqAlignedTable)
  RefGenotypeCommon<-as.vector(RefGenotype)
  #loop on the other and compare with this one and look for shared
  if (length(RefsNames)==1) {return(RefGenotypeCommon)}
  for (ref in 2:length(RefsNames)) {
    QuerySeq<-as.vector(SeqAlignedTable[RefsNames[ref],])
    NotGapLoc<-which(QuerySeq!="-")          #Get Not Gaps locations
    RefLike<-QuerySeq[NotGapLoc]==RefGenotypeCommon[NotGapLoc]    #same as reference
    QuerySeq[NotGapLoc][!RefLike]<-"-"
    RefGenotypeCommon<-QuerySeq
  }
  RefGenotypeCommon
}

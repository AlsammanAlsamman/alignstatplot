#' Generate several plots for sequence alignment
#'
#' @param SeqAlignedTable list of aligned vectors contains aligned sequences using \code{\link{alignment2Fasta}}
#' @param maxN Maximum number of nucleotides in every plot
#' @param cex.NucLabels Label font size
#' @param cex.SeqLabels Sequence name font size
#'
#' @return list of plots
#' @export
nucTableFreqHeatmapSplit<-function(SeqAlignedTable,maxN=100,cex.NucLabels=7,cex.SeqLabels=10)
{

  colArray<-1:ncol(SeqAlignedTable)
  colArrayList<-split(colArray, ceiling(seq_along(colArray)/maxN))
  colArrayList
  AllPlots<-lapply(colArrayList, function(x) {
    SeqTableChunk<-SeqAlignedTable[,x]
    nucTableFreqHeatmap(SeqTableChunk)
  })
  #return Plot List
  AllPlots
}

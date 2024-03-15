#' Plot distance matrix and phylogenetic tree in the same figure as heatmap
#'
#' @param seqInfo table of sequence information generated using \code{\link{getSeqInfo}}
#' @param seqAlignment sequence alignment object
#' @param plotTree logical plot phyolgenetic tree
#' @param plotDisMatrix logical plot heatmap of distance matrix
#' @return Tree and Heatmap plots
#' @export
#' @import RColorBrewer
#' @importFrom phytools phylo.heatmap
plotSimilarityMatrixWithTree<-function(seqInfo,seqAlignment,
                                       plotTree=TRUE,plotDisMatrix=TRUE)
{

  DistMatrixTable<-getDistanceMatrixTabel(seqInfo,seqAlignment)
  SeqTree<-getTree(DistMatrixTable)

  #HeatMap color Scale
  colors<-colorRampPalette(colors=c("blue","yellow","red"))(20)
  #gene font size
  genfsize<-100/nrow(DistMatrixTable)
  if (genfsize>0.8) {
    genfsize<-0.8
  }
  figure<-phylo.heatmap(SeqTree,as.matrix(DistMatrixTable),
                        fsize=c(genfsize,0.8,0.8),
                        colors=colors,standardize = F)
  figure
}

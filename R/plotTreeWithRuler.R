#' Plot phylogenetic tree along with distance ruler
#'
#' @param SeqInfo table of sequence information generated using \code{\link{getSeqInfo}}
#' @param myClustalWAlignment sequence alignment object
#'
#' @return Tree plot
#' @export
#' @importFrom ape plot.phylo
plotTreeWithRuler<-function(SeqInfo,myClustalWAlignment)
{
  DistTable<-getDistanceMatrixTabel(SeqInfo,myClustalWAlignment)
  myTree<-getTree(DistTable)
  phylo <- plot.phylo(myTree, edge.width = 1, label.offset = 0,cex = 0.5)

  plot.window(xlim = phylo$x.lim,ylim = phylo$y.lim)
  #Add phylo
  par(new = T)
  #Add a x axis that looks decent
  axis(1,at =seq(from =0, to = phylo$x.lim[2], by = round(phylo$x.lim[2]/10,digits = 2)),cex.axis = 0.5)
}

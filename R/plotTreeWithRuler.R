#' Plot phylogenetic tree along with distance ruler
#'
#' @param SeqInfo table of sequence information generated using \code{\link{getSeqInfo}}
#' @param myClustalWAlignment sequence alignment object
#' @param edge.width branch line width
#' @param label.offset gap between tip and its label
#' @param cex tip label font size
#' @param axis.cex ruler axis label font size
#'
#' @return Tree plot
#' @export
#' @importFrom ape plot.phylo
plotTreeWithRuler<-function(SeqInfo,myClustalWAlignment,
                            edge.width=1,label.offset=0,cex=0.5,axis.cex=0.5)
{
  DistTable<-getDistanceMatrixTabel(SeqInfo,myClustalWAlignment)
  myTree<-getTree(DistTable)
  phylo <- plot.phylo(myTree, edge.width = edge.width, label.offset = label.offset,cex = cex)

  plot.window(xlim = phylo$x.lim,ylim = phylo$y.lim)
  #Add phylo
  par(new = T)
  #Round, evenly-spaced tick marks (pretty() adapts to the tree's actual
  #branch-length range, unlike a fixed "10 steps" heuristic which can produce
  #an awkward tick count/spacing depending on the data)
  axis(1, at = pretty(c(0, phylo$x.lim[2])), cex.axis = axis.cex)
  title(xlab = "Genetic distance")
}

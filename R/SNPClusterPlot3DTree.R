#' plots cluster in 3D tree format
#' @param Cluster object of HCPC \code{\link{SNPCluster}}
#' @param angle angle of tree
#' @param title plot title (default: \code{FactoMineR}'s own default title)
#' @param ind.names logical, show individual point labels
#' @return Tree plot
#' @import FactoMineR
#' @export
SNPClusterPlot3DTree<-function(Cluster,angle=60,title=NULL,ind.names=TRUE)
{
  # Base-graphics dispatch on FactoMineR's own plot.HCPC method - the control
  # surface here is inherently limited to what plot.HCPC itself exposes.
  plot(Cluster, choice="3D.map", angle=angle,title=title,ind.names=ind.names)
}

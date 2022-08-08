#' plots cluster in 3D tree format
#' @param Cluster object of HCPC \code{\link{SNPCluster}}
#' @param angle angle of tree
#' @return Tree plot
#' @import FactoMineR
#' @export
SNPClusterPlot3DTree<-function(Cluster,angle=60)
{
  plot(Cluster, choice="3D.map", angle=angle,label = F)
}

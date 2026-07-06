#' Plot SNP Cluster as a one dimension tree
#' @param Cluster object of HCPC \code{\link{SNPCluster}}
#' @param ShowLabels True Show SNP labels
#' @param LabelsFontSize Labels font size
#' @return plot
#' @export
#' @import ggplot2
SNPClusterPlot1DTree<-function(Cluster,ShowLabels=T,LabelsFontSize=0.1)
{
  hc<-Cluster$call$t$tree
  k<-length(unique(Cluster$data.clust$clust))
  ggClusterDendrogram(hc, k = k, show_labels = ShowLabels, cex = LabelsFontSize)
}

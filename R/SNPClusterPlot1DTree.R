#' Plot SNP Cluster as a one dimension tree
#' @param Cluster object of HCPC \code{\link{SNPCluster}}
#' @param ShowLabels True Show SNP labels
#' @param LabelsFontSize Labels font size
#' @return plot
#' @export
#' @importFrom factoextra fviz_dend
SNPClusterPlot1DTree<-function(Cluster,ShowLabels=T,LabelsFontSize=0.1)
{
  fviz_dend(Cluster, show_labels = T,cex = 0.1)
}

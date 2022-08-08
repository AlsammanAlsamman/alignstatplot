#' Plot SNP Cluster as a PCA Map
#' @param Cluster Cluster object of HCPC \code{\link{SNPCluster}}
#' @return plot
#' @export
#' @importFrom factoextra fviz_cluster
SNPClusterPlotPCAMap<-function(Cluster)
{
  fviz_cluster(Cluster, geom = "point", main = "SNP Cluster PCA Map")
}

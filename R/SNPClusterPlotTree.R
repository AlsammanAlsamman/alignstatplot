SNPClusterPlotTree<-function(SNPCluster,angle)
{
  hc<-SNPCluster$call$t$tree
  k<-length(unique(SNPCluster$data.clust$clust))
  ggClusterDendrogram(hc, k = k, show_labels = TRUE, cex = 0.1)
}

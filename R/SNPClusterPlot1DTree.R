#' Plot SNP Cluster as a one dimension tree
#' @param Cluster object of HCPC \code{\link{SNPCluster}}
#' @param ShowLabels True Show SNP labels
#' @param LabelsFontSize Labels font size; 0 (default) picks a size automatically based on
#' the number of leaves (a flat small size that looks fine for a handful of SNPs becomes
#' illegible for the hundreds of SNPs a real alignment can produce)
#' @return plot
#' @export
#' @import ggplot2
SNPClusterPlot1DTree<-function(Cluster,ShowLabels=T,LabelsFontSize=0)
{
  hc<-Cluster$call$t$tree
  k<-length(unique(Cluster$data.clust$clust))
  if (LabelsFontSize==0) {
    n<-length(hc$order)
    LabelsFontSize<-if (n>200) 0.25
      else if (n>100) 0.3
      else if (n>60) 0.4
      else if (n>30) 0.6
      else 0.8
  }
  ggClusterDendrogram(hc, k = k, show_labels = ShowLabels, cex = LabelsFontSize)
}

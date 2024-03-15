#' Plot PCA for genes / Samples using distance matrix generatd from alignment
#' @param seqInfo  seqInfo table of sequence information generated using \code{\link{getSeqInfo}}
#' @param seqAlignment sequence alignment object
#' @param ncluster number of cluster default 4
#' @return plot of PCA
#' @importFrom factoextra fviz_cluster
#' @importFrom stats kmeans
#' @import ggplot2
#' @export
plotPCA<-function(seqInfo,seqAlignment,ncluster=4,labelsize = 10 ,showlabels = T)
{

  if (showlabels == F) {
    labelsize = 0
  }
  DistMatrixTable<-getDistanceMatrixTabel(seqInfo,seqAlignment)
  km.res <- kmeans(DistMatrixTable, 4, nstart = 25)
  p<-fviz_cluster(km.res, data = DistMatrixTable, frame.type = "convex",labelsize = labelsize)
  # save '$data'
  data <- p$data # this is all you need

  # calculate the convex hull using chull(), for each cluster
  hull_data <-  data %>%
    group_by(cluster) %>%
    slice(chull(x, y))

  # plot: you can now customize this by using ggplot sintax
  ggplot(data, aes(x, y)) + geom_point() +
    geom_polygon(data = hull_data, alpha = 0.5, aes(fill=cluster, linetype=cluster))
}

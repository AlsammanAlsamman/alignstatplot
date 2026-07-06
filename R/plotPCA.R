#' Plot PCA for genes / Samples using distance matrix generatd from alignment
#' @param seqInfo  seqInfo table of sequence information generated using \code{\link{getSeqInfo}}
#' @param seqAlignment sequence alignment object
#' @param ncluster number of cluster default 4
#' @param labelsize point label font size (currently unused: the plot has no text-label
#' layer, so this parameter has no effect on the rendered output; kept for
#' backward compatibility, see REFACTOR_PLAN.md Step 5)
#' @param showlabels whether to show point labels (currently unused, see \code{labelsize})
#' @return plot of PCA
#' @importFrom stats kmeans prcomp
#' @import ggplot2
#' @export
plotPCA<-function(seqInfo,seqAlignment,ncluster=4,labelsize = 10 ,showlabels = T)
{

  if (showlabels == F) {
    labelsize = 0
  }
  DistMatrixTable<-getDistanceMatrixTabel(seqInfo,seqAlignment)
  km.res <- kmeans(DistMatrixTable, 4, nstart = 25)
  # Reimplements factoextra::fviz_cluster's coordinate computation (stand=TRUE
  # default: standardize then PCA, keep first two components) without factoextra.
  ScaledData<-scale(DistMatrixTable)
  pca<-prcomp(ScaledData, scale = FALSE, center = FALSE)
  data<-data.frame(name = rownames(DistMatrixTable), x = pca$x[, 1], y = pca$x[, 2],
                   cluster = as.factor(km.res$cluster))

  # calculate the convex hull using chull(), for each cluster
  hull_data <-  data %>%
    group_by(cluster) %>%
    slice(chull(x, y))

  # plot: you can now customize this by using ggplot sintax
  ggplot(data, aes(x, y)) + geom_point() +
    geom_polygon(data = hull_data, alpha = 0.5, aes(fill=cluster, linetype=cluster))
}

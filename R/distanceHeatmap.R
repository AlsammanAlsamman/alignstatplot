#' Plot distance matrix as heatmap
#'
#' @param DistTable Table of distance matrix generated using \code{\link{getDistanceMatrixTabel}}
#' @param fontsizescale scale of font size
#' @return heatmap plot
#' @export
#' @importFrom pheatmap pheatmap
distanceHeatmap<-function(DistTable,fontsizescale=1.5)
{
  pheatmap(as.matrix(DistTable),fontsize = nrow(DistTable)*fontsizescale)
}

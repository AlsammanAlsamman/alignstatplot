#' Plot distance matrix as heatmap
#'
#' @param DistTable Table of distance matrix generated using \code{\link{getDistanceMatrixTabel}}
#' @param fontsizescale scale of font size
#' @return heatmap plot
#' @export
#' @importFrom pheatmap pheatmap
distanceHeatmap<-function(DistTable,fontsizescale=0)
{
  # if fontsizescale is not set calculate it
  seqn<-nrow(DistTable)
  if (seqn>1 && seqn<20 && fontsizescale==0) {
    fontsizescale<-2
  } else if (seqn>20 && seqn<50&& fontsizescale==0) {
    fontsizescale<-1
  } else if (seqn>50 && seqn<100&& fontsizescale==0) {
    fontsizescale<-0.5
  } else if (seqn>100 && seqn<200&& fontsizescale==0) {
    fontsizescale<-0.3
  } else if (seqn>200 && fontsizescale==0) {
    fontsizescale<-0.1
  }
  pheatmap(as.matrix(DistTable),fontsize = nrow(DistTable)*fontsizescale)
}

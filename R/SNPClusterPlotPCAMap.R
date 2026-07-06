#' Plot SNP Cluster as a PCA Map
#' @param Cluster Cluster object of HCPC \code{\link{SNPCluster}}
#' @param main plot title
#' @param geom character vector, any of \code{"point"}/\code{"text"} - which geoms to draw
#' @param pointsize point size (only used when \code{"point"} is in \code{geom})
#' @param font.label point-label font size (only used when \code{"text"} is in \code{geom})
#' @return plot
#' @export
#' @import ggplot2
#' @import ggpubr
SNPClusterPlotPCAMap<-function(Cluster,main="SNP Cluster PCA Map",geom=c("point"),
                               pointsize=1.5,font.label=12)
{
  # Reimplements factoextra::fviz_cluster.HCPC directly via ggpubr::ggscatter -
  # ggpubr is what fviz_cluster calls internally anyway, and is already a
  # required dependency of this package.
  axes<-c(1, 2)
  ind<-Cluster$call$X[, c(axes, ncol(Cluster$call$X))]
  colnames(ind)<-c("Dim.1", "Dim.2", "clust")
  ind<-cbind.data.frame(name = rownames(ind), ind)
  colnames(ind)[2:3]<-c("x", "y")
  cluster<-as.factor(Cluster$call$X$clust)
  plot.data<-cbind.data.frame(ind, cluster = cluster)
  #FactoMineR's own PCA/MCA result already stores this - same values
  #factoextra::get_eigenvalue() would return, just without the rename.
  eig<-Cluster$call$t$res$eig[axes, 2]
  xlab<-paste0("Dim", axes[1], " (", round(eig[1], 1), "%)")
  ylab<-paste0("Dim", axes[2], " (", round(eig[2], 1), "%)")

  if (!("point" %in% geom)) pointsize<-0
  label<-if ("text" %in% geom) "name" else NULL

  ggscatter(plot.data, "x", "y", color = "cluster", shape = "cluster", size = pointsize,
           point = "point" %in% geom, label = label, font.label = font.label, repel = FALSE,
           mean.point = TRUE, ellipse = TRUE, ellipse.type = "convex",
           ellipse.alpha = 0.2, ellipse.level = 0.95,
           main = main, xlab = xlab, ylab = ylab, ggtheme = theme_grey())
}

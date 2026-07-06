#' Build a cluster-colored dendrogram as a ggplot object
#'
#' @description Internal helper replacing \code{factoextra::fviz_dend()} for
#' \code{hclust}-based dendrograms. Reimplements the standard rectangular
#' dendrogram-layout algorithm (leaf x-position from \code{hc$order}, node
#' height from \code{hc$height}) plus \code{fviz_dend}'s branch-coloring rule:
#' find, for each of the \code{k} \code{cutree()} clusters, the subtree that is
#' entirely that one cluster, and color every edge in it; edges connecting
#' different clusters stay black. Cluster-to-color assignment follows
#' left-to-right first-appearance order along the dendrogram leaves, matching
#' \code{fviz_dend}'s convention, and colors are left unmapped so ggplot2's own
#' default discrete palette is used (identical to \code{fviz_dend}'s default
#' palette, which is generated the same way).
#' @param hc an object of class "hclust"
#' @param k number of clusters to color (as in \code{stats::cutree(hc, k=k)})
#' @param show_labels logical, show leaf labels (matches \code{fviz_dend(show_labels=)})
#' @param cex leaf label font scale (matches \code{fviz_dend(cex=)})
#' @param main plot title
#' @return a ggplot object
ggClusterDendrogram<-function(hc, k, show_labels = TRUE, cex = 0.8, main = "Cluster Dendrogram")
{
  n<-length(hc$order)
  leaf_x<-stats::setNames(seq_len(n), hc$labels[hc$order])
  node_x<-numeric(n - 1)
  node_y<-hc$height

  #Relabel cutree()'s cluster ids by left-to-right first-appearance order,
  #matching fviz_dend/dendextend's convention (not cutree's raw numeric ids).
  raw_clusters<-stats::cutree(hc, k = k)
  ordered_ids<-unique(raw_clusters[hc$order])
  remap<-stats::setNames(seq_along(ordered_ids), ordered_ids)
  clusters<-remap[as.character(raw_clusters)]
  leaf_cluster<-stats::setNames(as.character(clusters), hc$labels)
  node_cluster<-rep(NA_character_, n - 1)

  getInfo<-function(idx) {
    if (idx < 0) {
      lbl<-hc$labels[-idx]
      list(x = leaf_x[[lbl]], y = 0, cluster = leaf_cluster[[lbl]])
    } else {
      list(x = node_x[idx], y = node_y[idx], cluster = node_cluster[idx])
    }
  }

  segs<-vector("list", 3*(n - 1))
  si<-1
  for (i in seq_len(n - 1)) {
    a<-getInfo(hc$merge[i, 1])
    b<-getInfo(hc$merge[i, 2])
    node_x[i]<-(a$x + b$x) / 2
    same<-!is.na(a$cluster) && !is.na(b$cluster) && a$cluster == b$cluster
    node_cluster[i]<-if (same) a$cluster else NA_character_
    ca<-if (!is.na(a$cluster)) a$cluster else "black"
    cb<-if (!is.na(b$cluster)) b$cluster else "black"
    ch<-if (same) a$cluster else "black"
    segs[[si]]<-data.frame(x = a$x, xend = a$x, y = a$y, yend = node_y[i], col = ca); si<-si + 1
    segs[[si]]<-data.frame(x = b$x, xend = b$x, y = b$y, yend = node_y[i], col = cb); si<-si + 1
    segs[[si]]<-data.frame(x = a$x, xend = b$x, y = node_y[i], yend = node_y[i], col = ch); si<-si + 1
  }
  segdf<-do.call(rbind, segs)
  black_segs<-segdf[segdf$col == "black", ]
  color_segs<-segdf[segdf$col != "black", ]

  p<-ggplot2::ggplot()
  if (nrow(black_segs) > 0) {
    p<-p + ggplot2::geom_segment(data = black_segs, ggplot2::aes(x = x, xend = xend, y = y, yend = yend), color = "black")
  }
  if (nrow(color_segs) > 0) {
    p<-p + ggplot2::geom_segment(data = color_segs, ggplot2::aes(x = x, xend = xend, y = y, yend = yend, color = col))
  }
  if (show_labels) {
    max_h<-max(node_y)
    labels_df<-data.frame(x = seq_len(n), y = -max_h/100, label = hc$labels[hc$order],
                          col = leaf_cluster[hc$labels[hc$order]])
    p<-p + ggplot2::geom_text(data = labels_df, ggplot2::aes(x = x, y = y, label = label, color = col),
                              angle = 90, hjust = 1, size = cex*3)
  }
  p + ggplot2::guides(color = "none") +
    ggplot2::labs(title = main, x = NULL, y = "Height") +
    ggplot2::theme_classic() +
    ggplot2::theme(axis.text.x = ggplot2::element_blank(),
                   axis.ticks.x = ggplot2::element_blank(),
                   axis.line.x = ggplot2::element_blank())
}

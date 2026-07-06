#' Build a rectangular phylogenetic tree as a ggplot object
#'
#' @description Internal helper replacing \code{ggtree(tree) + geom_tiplab(align=TRUE) +
#' hexpand(.4)}. Uses only \code{ape}'s own tree-layout coordinates (via the documented
#' \code{ape:::.PlotPhyloEnv} pattern also used by \code{phytools} and other ape-ecosystem
#' packages) plus \code{ggplot2} primitives, so the result stays a plain \code{ggplot} object
#' that composes with \code{cowplot::plot_grid()} exactly like the ggtree version did - with
#' no Bioconductor dependency.
#' @param tree an object of class "phylo"
#' @param tip_size tip label font size (matches \code{geom_tiplab(size=)})
#' @param align logical, right-align tip labels with a dotted leader line
#' (matches \code{geom_tiplab(align=TRUE)})
#' @param expand extra fractional space to the right of the plot for label text
#' (matches \code{hexpand(.4)})
#' @return a list with `plot` (a ggplot object) and `tip_order` (tip labels ordered
#' top-to-bottom as rendered, for reordering companion row-aligned plots)
ggPhyloTree<-function(tree, tip_size = 3, align = TRUE, expand = 0.4)
{
  Ntip<-length(tree$tip.label)
  # Standard documented ape pattern for retrieving tree-layout coordinates without
  # depending on any tree-drawing package beyond ape itself.
  grDevices::pdf(NULL)
  invisible(ape::plot.phylo(tree, plot = TRUE))
  grDevices::dev.off()
  lastPP<-get("last_plot.phylo", envir = ape::.PlotPhyloEnv)
  xx<-lastPP$xx
  yy<-lastPP$yy
  edge<-lastPP$edge

  tip_x<-xx[seq_len(Ntip)]
  tip_y<-yy[seq_len(Ntip)]
  tip_label<-tree$tip.label
  x_max<-max(xx)

  #Rectangular branches: one horizontal (child branch) + one vertical (parent
  #connector) segment per edge - the standard right-angle phylogram style.
  horiz<-data.frame(x = xx[edge[,1]], xend = xx[edge[,2]],
                    y = yy[edge[,2]], yend = yy[edge[,2]])
  vert<-data.frame(x = xx[edge[,1]], xend = xx[edge[,1]],
                   y = yy[edge[,1]], yend = yy[edge[,2]])
  segs<-rbind(horiz, vert)

  labelX<-if (align) rep(x_max, Ntip) else tip_x
  leader<-data.frame(x = tip_x, xend = labelX, y = tip_y, yend = tip_y)
  labels<-data.frame(x = labelX, y = tip_y, label = tip_label)

  p<-ggplot2::ggplot()+
    ggplot2::geom_segment(data = segs, ggplot2::aes(x = x, xend = xend, y = y, yend = yend))
  if (align) {
    p<-p + ggplot2::geom_segment(data = leader, ggplot2::aes(x = x, xend = xend, y = y, yend = yend),
                                 linetype = "dotted", color = "grey50")
  }
  p<-p+
    ggplot2::geom_text(data = labels, ggplot2::aes(x = x, y = y, label = label),
                       hjust = 0, nudge_x = x_max*0.01, size = tip_size)+
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = c(0.02, expand)))+
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = 0.02))+
    ggplot2::theme_void()

  tip_order<-tip_label[order(tip_y, decreasing = TRUE)]
  list(plot = p, tip_order = tip_order)
}

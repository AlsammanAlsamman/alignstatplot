#' The tip order ape::plot.phylo() actually drew tips in, top-to-bottom
#'
#' @description tree$tip.label's raw storage order generally does NOT match the order
#' \code{ape::plot.phylo()} draws tips in (that depends on tree topology, not input
#' order). Must be called immediately after a \code{plot.phylo(tree, ...)} call, since it
#' reads the y-coordinates ape just assigned each tip from \code{ape::.PlotPhyloEnv}.
#' @param tree the same "phylo" object just passed to \code{plot.phylo()}
#' @return character vector of \code{tree$tip.label}, reordered by ascending plotted
#' y-coordinate (bottom-to-top, matching \code{graphics::image()}'s y-axis convention)
plottedTipOrder<-function(tree)
{
  lastPP<-get("last_plot.phylo", envir = ape::.PlotPhyloEnv)
  tipY<-lastPP$yy[seq_along(tree$tip.label)]
  names(tipY)<-tree$tip.label
  names(sort(tipY))
}

#' Draw a phylogenetic tree next to a heatmap of a matrix, base graphics
#'
#' @description Internal helper replacing \code{phytools::phylo.heatmap()}.
#' Draws the tree with \code{ape::plot.phylo} (already used elsewhere in this
#' package, e.g. \code{plotTreeWithRuler}) and the matrix with base
#' \code{graphics::image()}, laid out side by side via \code{graphics::layout()}.
#' Like \code{phylo.heatmap()}, this is a base-graphics side effect (draws to
#' the active device) rather than a returned plot object - matching current
#' behavior exactly, since \code{phylo.heatmap()} itself never returned a
#' reusable object either.
#' @param tree an object of class "phylo"
#' @param X a numeric matrix whose rownames match \code{tree$tip.label}
#' @param fsize length-3 vector: tip label size, column label size, legend size
#' (matches \code{phylo.heatmap(fsize=)}); a single value is recycled to all three
#' @param colors a vector of colors for the heatmap gradient
#' @param standardize logical, z-score standardize each column before plotting
#' @param legend logical, draw a color-scale legend
#' @return invisible NULL (side effect only)
baseTreeHeatmap<-function(tree, X, fsize = c(1, 1, 1), colors = NULL, standardize = FALSE, legend = TRUE)
{
  if (length(fsize) != 3) fsize<-rep(fsize, 3)
  if (is.null(colnames(X))) colnames(X)<-paste0("var", seq_len(ncol(X)))
  if (standardize) {
    sdv<-apply(X, 2, function(v) stats::sd(v, na.rm = TRUE))
    X<-sweep(sweep(X, 2, colMeans(X, na.rm = TRUE), "-"), 2, sdv, "/")
  }
  if (is.null(colors)) colors<-grDevices::heat.colors(20)[20:1]

  n_row<-nrow(X); n_col<-ncol(X)
  widths<-if (legend) c(2, 2, 0.4) else c(1, 1)
  layout_mat<-if (legend) matrix(c(1, 2, 3), nrow = 1) else matrix(c(1, 2), nrow = 1)
  graphics::layout(layout_mat, widths = widths)

  #Both panels use the same top/bottom margin so their plot regions are the
  #same height and tree tips line up with heatmap rows pixel-for-pixel,
  #regardless of how much room the heatmap's x-axis labels need.
  graphics::par(mar = c(8, 1, 2, 0))
  ape::plot.phylo(tree, cex = fsize[1], label.offset = 0.01)

  #Reorder rows to match the tree's plotted tip order, so heatmap rows always
  #line up with the tips they're drawn beside, regardless of tree topology.
  plottedOrder<-plottedTipOrder(tree)
  #For a square matrix whose columns are the same entities as the tips (e.g. a
  #distance matrix), also reorder columns to match, so the diagonal (self vs
  #self) reads as a clean visual line instead of a scattered pattern. Columns
  #use the reverse order of rows so the diagonal runs the conventional
  #top-left-to-bottom-right way (rows go bottom-to-top in image()'s y-axis,
  #so mirroring the columns left-to-right undoes that and restores the usual
  #reading direction).
  if (all(colnames(X) %in% tree$tip.label)) {
    X<-X[plottedOrder, rev(plottedOrder), drop = FALSE]
  } else {
    X<-X[plottedOrder, , drop = FALSE]
  }

  graphics::par(mar = c(8, 0, 2, 1))
  graphics::image(x = seq_len(n_col), y = seq_len(n_row), z = t(X),
                  col = colors, axes = FALSE, xlab = "", ylab = "")
  graphics::axis(1, at = seq_len(n_col), labels = colnames(X), las = 2, cex.axis = fsize[2])

  if (legend) {
    rng<-range(X, na.rm = TRUE)
    graphics::par(mar = c(8, 0.5, 2, 2))
    graphics::image(x = 1, y = seq_along(colors), z = matrix(seq_along(colors), nrow = 1),
                    col = colors, axes = FALSE, xlab = "", ylab = "")
    graphics::axis(4, at = c(1, length(colors)), labels = round(rng, 2), las = 1, cex.axis = fsize[3])
  }
  invisible(NULL)
}

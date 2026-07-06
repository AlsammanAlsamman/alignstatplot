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
  #Reorder rows to match the tree's tip order - same alignment contract as
  #phylo.heatmap()'s X <- X[cw$tip.label, ].
  X<-X[tree$tip.label, , drop = FALSE]
  if (is.null(colors)) colors<-grDevices::heat.colors(20)[20:1]

  n_row<-nrow(X); n_col<-ncol(X)
  widths<-if (legend) c(2, 2, 0.4) else c(1, 1)
  layout_mat<-if (legend) matrix(c(1, 2, 3), nrow = 1) else matrix(c(1, 2), nrow = 1)
  graphics::layout(layout_mat, widths = widths)

  graphics::par(mar = c(3, 1, 2, 0))
  ape::plot.phylo(tree, cex = fsize[1], label.offset = 0.01)

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

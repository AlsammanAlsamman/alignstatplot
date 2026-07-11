#' Plot the distribution of pairwise sequence identity
#'
#' @param DistMatrixTable A distance matrix generated using \code{\link{getDistanceMatrixTabel}}
#' @param colors fill/line color, length 1 or 2 (default: the package's sequential blue ramp)
#' @param bins number of histogram bins
#' @return a \code{ggplot} object
#' @export
#' @import ggplot2
plotIdentityDistribution<-function(DistMatrixTable, colors = NULL, bins = 20)
{
  if (is.null(dim(DistMatrixTable)) || nrow(DistMatrixTable) != ncol(DistMatrixTable)) {
    stop("DistMatrixTable must be a square distance matrix, as returned by getDistanceMatrixTabel().")
  }
  if (nrow(DistMatrixTable) < 2) {
    stop("At least 2 sequences are required to compute pairwise identity, got ", nrow(DistMatrixTable), ".")
  }
  if (is.null(colors)) {
    colors<-c(fill = .alignstatplotSequential[2], line = .alignstatplotSequential[4])
  } else if (length(colors) == 1) {
    colors<-c(fill = unname(colors[1]), line = unname(colors[1]))
  } else {
    colors<-c(fill = unname(colors[1]), line = unname(colors[2]))
  }

  m<-as.matrix(DistMatrixTable)
  Identity<-1 - m[upper.tri(m)]
  df<-data.frame(Identity = Identity)

  ggplot(df, aes(x = .data$Identity)) +
    geom_histogram(aes(y = after_stat(density)), bins = bins,
                   fill = colors[["fill"]], colour = "white", linewidth = 0.2) +
    geom_density(colour = colors[["line"]], linewidth = 0.5) +
    labs(x = "Pairwise sequence identity", y = "Density",
         title = "Distribution of pairwise sequence identity") +
    theme_alignstatplot()
}

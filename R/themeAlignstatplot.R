#' A clean, publication-style ggplot2 theme for alignstatplot figures
#'
#' @description A minimal theme (thin recessive gridlines, muted axis text, no panel
#' border) used by this package's newer statistical plots (\code{\link{plotConservationTrack}},
#' \code{\link{plotVariantDensity}}, \code{\link{plotIdentityDistribution}},
#' \code{\link{plotSeqStatsSummary}}, \code{\link{plotBaseComposition}},
#' \code{\link{plotRegionStats}}). Exported so it can also be applied to the output of any
#' other function that returns a \code{ggplot} object, e.g. \code{plotPCA(...) + theme_alignstatplot()}
#' -- doing so does not change that function's own default appearance unless the user opts in.
#' @param base_size base font size in points
#' @return a \code{ggplot2} theme object
#' @export
#' @import ggplot2
theme_alignstatplot<-function(base_size = 11)
{
  theme_minimal(base_size = base_size) +
    theme(
      text = element_text(colour = "#0b0b0b"),
      plot.title = element_text(face = "bold", colour = "#0b0b0b", size = base_size * 1.1),
      plot.subtitle = element_text(colour = "#52514e"),
      axis.title = element_text(colour = "#52514e"),
      axis.text = element_text(colour = "#898781"),
      axis.line = element_line(colour = "#c3c2b7", linewidth = 0.3),
      axis.ticks = element_line(colour = "#c3c2b7", linewidth = 0.3),
      panel.grid.major = element_line(colour = "#e1e0d9", linewidth = 0.3),
      panel.grid.minor = element_blank(),
      panel.border = element_blank(),
      legend.title = element_text(colour = "#52514e"),
      legend.text = element_text(colour = "#0b0b0b"),
      legend.key = element_blank(),
      strip.background = element_blank(),
      strip.text = element_text(colour = "#0b0b0b", face = "bold")
    )
}

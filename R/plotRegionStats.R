#' Plot conservation and variable-site count by annotated region type
#'
#' @param RegionStatsTable output of \code{\link{regionStats}}
#' @param colors fixed-order categorical palette for region types (default: the package's
#' validated 8-hue categorical palette)
#' @return a \code{patchwork} composite of 2 \code{ggplot} panels
#' @export
#' @import ggplot2
#' @importFrom scales percent
plotRegionStats<-function(RegionStatsTable, colors = NULL)
{
  required<-c("Type","MeanConservation","VariantRate")
  if (!all(required %in% colnames(RegionStatsTable))) {
    stop("RegionStatsTable must be the output of regionStats() (needs ",
         paste(required, collapse = ", "), " columns).")
  }
  if (is.null(colors)) colors<-.alignstatplotCategorical

  p1<-ggplot(RegionStatsTable, aes(x = .data$Type, y = .data$MeanConservation, fill = .data$Type)) +
    geom_boxplot(outlier.shape = NA) +
    geom_jitter(width = 0.1, height = 0, alpha = 0.5, colour = "#0b0b0b", size = 1) +
    scale_fill_manual(values = colors) +
    labs(x = NULL, y = "Mean conservation", title = "Conservation by region type") +
    theme_alignstatplot() +
    theme(legend.position = "none")

  p2<-ggplot(RegionStatsTable, aes(x = .data$Type, y = .data$VariantRate, fill = .data$Type)) +
    geom_boxplot(outlier.shape = NA) +
    geom_jitter(width = 0.1, height = 0, alpha = 0.5, colour = "#0b0b0b", size = 1) +
    scale_fill_manual(values = colors) +
    scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
    labs(x = NULL, y = "Variable sites / region length", title = "Variant rate by region type") +
    theme_alignstatplot() +
    theme(legend.position = "none")

  patchwork::wrap_plots(p1, p2, ncol = 2)
}

#' Plot overall nucleotide composition across the whole alignment
#'
#' @param NucCount Table of nucleotide frequency across the aligned sequences \code{\link{nucFrequency}}
#' @param colors named color vector for nucleotides A, T, C, G, N (default:
#' the package's standard nucleotide palette, shared with \code{\link{nucTableHeatmap}}/\code{\link{nucFrequencyPlot}})
#' @return a \code{ggplot} object
#' @export
#' @import ggplot2
#' @importFrom scales percent
plotBaseComposition<-function(NucCount, colors = defaultNucleotideColors)
{
  if (is.null(dim(NucCount)) || nrow(NucCount) != 5) {
    stop("NucCount must have exactly 5 rows (A, C, T, G, N), as returned by nucFrequency().")
  }
  order<-c("A","T","C","G","N")
  Overall<-rowMeans(NucCount[order, , drop = FALSE])
  df<-data.frame(Nucleotide = factor(order, levels = order), Frequency = as.numeric(Overall))

  ggplot(df, aes(x = .data$Nucleotide, y = .data$Frequency, fill = .data$Nucleotide)) +
    geom_col(width = 0.6) +
    scale_fill_manual(values = colors) +
    scale_y_continuous(labels = scales::percent) +
    labs(x = NULL, y = "Overall frequency", title = "Base composition") +
    theme_alignstatplot() +
    theme(legend.position = "none")
}

#' Plot variable-site density along the alignment
#'
#' @description Counts variable (more than one A/C/T/G allele present) sites in
#' non-overlapping windows along the alignment and plots the count per window -- the
#' standard "SNP/variant density along the genome" figure.
#' @param SeqAlignedTable A Table of aligned sequences (rows) x nucleotides (columns)
#' generated using \code{\link{alignment2Table}}
#' @param windowSize number of alignment positions per window (default 50)
#' @param colors fill color for the density bars (default: the package's sequential blue ramp)
#' @return a \code{ggplot} object
#' @export
#' @import ggplot2
plotVariantDensity<-function(SeqAlignedTable, windowSize = 50, colors = NULL)
{
  NucCount<-nucFrequency(SeqAlignedTable)
  if (!is.numeric(windowSize) || length(windowSize) != 1 || windowSize < 1) {
    stop("windowSize must be a single positive number, got: ", windowSize)
  }
  windowSize<-round(windowSize)
  if (is.null(colors)) colors<-.alignstatplotSequential[3]

  bases<-c("A","C","T","G")
  isVariable<-colSums(NucCount[bases, , drop = FALSE] > 0) > 1
  L<-length(isVariable)
  windowSize<-min(windowSize, L)
  windowStart<-seq(1, L, by = windowSize)

  WindowData<-data.frame(
    WindowStart = windowStart,
    WindowEnd = pmin(windowStart + windowSize - 1, L)
  )
  WindowData$VariantCount<-vapply(seq_len(nrow(WindowData)), function(i) {
    sum(isVariable[WindowData$WindowStart[i]:WindowData$WindowEnd[i]])
  }, numeric(1))
  WindowData$WindowMid<-(WindowData$WindowStart + WindowData$WindowEnd) / 2

  ggplot(WindowData, aes(x = .data$WindowMid, y = .data$VariantCount)) +
    geom_col(fill = colors, width = windowSize * 0.9) +
    labs(x = "Alignment position", y = paste0("Variable sites / ", windowSize, "bp window"),
         title = "Variant density along the alignment") +
    theme_alignstatplot()
}

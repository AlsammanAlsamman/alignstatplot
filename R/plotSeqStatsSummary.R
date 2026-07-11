#' Plot a small-multiple summary of per-sequence alignment statistics
#'
#' @description Boxplots (with individual points overlaid) of sequence length, gap
#' percentage, and GC percentage across all sequences, from
#' \code{\link{AlignmentStatsPerSeq}}'s output -- a quick per-run QC panel.
#' @param StatsTable output of \code{\link{AlignmentStatsPerSeq}}
#' @param colors fill color for the boxplots (default: the package's sequential blue ramp)
#' @return a \code{patchwork} composite of 3 \code{ggplot} panels
#' @export
#' @import ggplot2
plotSeqStatsSummary<-function(StatsTable, colors = NULL)
{
  required<-c("Sequence.Length","Gap.Percentage","GC.Percentage")
  if (!all(required %in% colnames(StatsTable))) {
    stop("StatsTable must be the output of AlignmentStatsPerSeq() (needs ",
         paste(required, collapse = ", "), " columns).")
  }
  if (is.null(colors)) colors<-.alignstatplotSequential[3]

  toNum<-function(x) as.numeric(sub("%", "", x))
  df<-data.frame(
    x = "",
    Length = StatsTable$Sequence.Length,
    GapPct = toNum(StatsTable$Gap.Percentage),
    GCPct = toNum(StatsTable$GC.Percentage)
  )

  onePanel<-function(y, ylab, title) {
    ggplot(df, aes(x = .data$x, y = .data[[y]])) +
      geom_boxplot(fill = colors, width = 0.4, outlier.shape = NA) +
      geom_jitter(width = 0.08, height = 0, alpha = 0.6, colour = "#0b0b0b", size = 1.5) +
      labs(x = NULL, y = ylab, title = title) +
      theme_alignstatplot() +
      theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
  }

  p1<-onePanel("Length", "bp", "Sequence length")
  p2<-onePanel("GapPct", "%", "Gap percentage")
  p3<-onePanel("GCPct", "%", "GC percentage")

  patchwork::wrap_plots(p1, p2, p3, ncol = 3)
}

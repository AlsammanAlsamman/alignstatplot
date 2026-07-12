#' Rank-ordered impact plot for choosing a filterHighImpactSNPs() cutoff
#'
#' @description Two stacked panels, both x-axed by SNP rank (highest impact first): the
#' per-SNP impact score, and the cumulative share of total impact captured by keeping the
#' top N SNPs. Kept as two panels rather than one dual-axis chart, since "score per SNP"
#' and "cumulative % captured" are different units on different scales. A vertical marker
#' shows the proposed cutoff -- \code{topN} if supplied, otherwise the elbow of the impact
#' curve (the same default \code{\link{filterHighImpactSNPs}} uses) -- so its effect (how
#' many SNPs are kept, how much of the total impact they capture) can be checked before
#' committing to it.
#' @param ImpactTable output of \code{\link{SNPClusterImpact}}
#' @param topN the candidate cutoff to mark; defaults to the elbow of the impact curve
#' @return a \code{patchwork} composite of 2 \code{ggplot} panels
#' @export
#' @import ggplot2
plotSNPClusterImpact<-function(ImpactTable, topN=NULL)
{
  if (!all(c("SNP","Impact") %in% colnames(ImpactTable))) {
    stop("ImpactTable must be the output of SNPClusterImpact() (needs SNP, Impact columns).")
  }
  sortedImpact<-ImpactTable$Impact[order(-ImpactTable$Impact)]
  n<-length(sortedImpact)
  if (is.null(topN)) {
    topN<-findImpactElbow(sortedImpact)
  } else if (!is.numeric(topN) || length(topN) != 1 || topN < 1) {
    stop("topN must be a single positive number, got: ", topN)
  }
  topN<-min(topN, n)

  d<-data.frame(
    Rank = seq_len(n),
    Impact = sortedImpact,
    CumulativeShare = cumsum(sortedImpact) / sum(sortedImpact)
  )
  capturedPct<-round(d$CumulativeShare[topN] * 100, 1)
  markLabel<-paste0("kept = ", topN, " (", capturedPct, "% of total impact)")
  lineCol<-.alignstatplotSequential[4]
  fillCol<-.alignstatplotSequential[2]

  p1<-ggplot(d, aes(x = .data$Rank, y = .data$Impact)) +
    geom_area(fill = fillCol, alpha = 0.5) +
    geom_line(colour = lineCol, linewidth = 0.4) +
    geom_vline(xintercept = topN, colour = "#e34948", linetype = "dashed", linewidth = 0.4) +
    labs(x = NULL, y = "Impact score", title = "A. Per-SNP impact (sorted)", subtitle = markLabel) +
    theme_alignstatplot()

  p2<-ggplot(d, aes(x = .data$Rank, y = .data$CumulativeShare)) +
    geom_line(colour = lineCol, linewidth = 0.6) +
    geom_vline(xintercept = topN, colour = "#e34948", linetype = "dashed", linewidth = 0.4) +
    scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
    labs(x = "SNP rank (highest impact first)", y = "Cumulative share of total impact",
         title = "B. Cumulative impact captured") +
    theme_alignstatplot()

  patchwork::wrap_plots(p1, p2, ncol = 1)
}

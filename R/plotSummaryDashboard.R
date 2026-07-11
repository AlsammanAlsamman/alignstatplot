#' A composite summary figure combining base composition, pairwise identity,
#' variant density, and per-position conservation
#'
#' @description Combines \code{\link{plotBaseComposition}}, \code{\link{plotIdentityDistribution}},
#' \code{\link{plotVariantDensity}}, and \code{\link{plotConservationTrack}} into one
#' \code{patchwork}-composed figure -- a ready-to-drop-in supplementary summary figure
#' for a paper using this package.
#' @param SeqInfo table of sequence information generated using \code{\link{getSeqInfo}}
#' @param SeqAligned list of aligned vectors contains aligned sequences using \code{\link{alignment2Fasta}}
#' @param DistMatrixTable a distance matrix generated using \code{\link{getDistanceMatrixTabel}}
#' @param windowSize window size (in alignment positions) for the variant-density panel, see \code{\link{plotVariantDensity}}
#' @return a \code{patchwork} composite of 4 \code{ggplot} panels
#' @export
#' @import ggplot2
plotSummaryDashboard<-function(SeqInfo, SeqAligned, DistMatrixTable, windowSize = 50)
{
  SeqAlignedTable<-alignment2Table(SeqInfo, SeqAligned)
  NucCount<-nucFrequency(SeqAlignedTable)
  PositionStats<-positionConservation(SeqAlignedTable)

  p1<-plotBaseComposition(NucCount) + labs(title = "A. Base composition")
  p2<-plotIdentityDistribution(DistMatrixTable) + labs(title = "B. Pairwise identity")
  p3<-plotVariantDensity(SeqAlignedTable, windowSize = windowSize) + labs(title = "C. Variant density")
  p4<-plotConservationTrack(PositionStats) + labs(title = "D. Conservation track")

  patchwork::wrap_plots(p1, p2, p3, p4, ncol = 2)
}

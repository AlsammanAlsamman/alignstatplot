#' Draw Consensus Circos without Links
#'
#' @param SeqInfo Table of sequence information generated using \code{\link{getSeqInfo}}
#' @param SeqAligned list of aligned vectors contains aligned sequences using \code{\link{alignment2Fasta}}
#' @param geneLabels custom display names for the sequences, one per row of \code{SeqInfo}
#' (default: \code{SeqInfo$Name})
#' @param cex.SeqLabels A number for sequence labels font size; 0 (default) picks a size
#' automatically based on the number of sequences (each sequence's label sits on its own
#' concentric ring, whose radial height shrinks as more sequences are added)
#' @param cex.bpLabels A number for base pair labels font size (the single consensus axis
#' spans the whole circle, so this can be much larger than a per-sequence ruler without overlap)
#' @param colors sector colors, one per sequence (default: \code{\link{getSeqColors}})
#' @param bgColor background segment color for the base track
#'
#' @return plot an alignment circle
#' @export
drawConsWithNoGenes<-function(SeqInfo,SeqAligned,geneLabels=NULL,cex.SeqLabels=0,cex.bpLabels=0.8,
                              colors=NULL,bgColor="#CCCCCC")
{
  if (!is.null(geneLabels) && length(geneLabels) != nrow(SeqInfo)) {
    stop("geneLabels must have one entry per sequence (", nrow(SeqInfo), "), got ", length(geneLabels), ".")
  }
  if (cex.SeqLabels==0) {
    n<-nrow(SeqInfo)
    cex.SeqLabels<-if (n>100) 0.3
      else if (n>50) 0.4
      else if (n>20) 0.6
      else if (n>10) 0.9
      else 1.3
  }
  SeqLabelsToDraw<-if (is.null(geneLabels)) SeqInfo$Name else geneLabels
  #Sequences colors
  ColorsN <- nrow(SeqInfo)
  SectorColors<-if (is.null(colors)) getSeqColors(ColorsN) else colors

  #Length of the consensus is the length of any aligned sequence
  ConsLength<-length(SeqAligned[[1]])
  #Track Matched Sequences across the alignement
  SeqHighLights<-alignmentNoGaps(SeqAligned)
  #Clear Prev
  circos.clear()
  #Global Variables
  circos.par(gap.degree = 15,"start.degree" = 95, cell.padding = c(0, 0, 0, 0))
  #Draw Genes basic structure
  mycircos.Seq.Sectors = data.frame(sectors = c("Consensus"),
                                    x = 1, y = c(ConsLength))

  SeqN<-length(SeqHighLights)
  circos.initialize(c("Consensus"),xlim = c(0,ConsLength)) #labels fonts
  circos.track(ylim = c(0.5, SeqN+0.5), track.height = 0.8,
               bg.border = NA, panel.fun = function(x, y) {
                 xlim = CELL_META$xlim  #Information of current cell

                 circos.segments(rep(xlim[1], SeqN), 1:SeqN,
                                 rep(xlim[2], SeqN), 1:SeqN,
                                 col = bgColor,lwd = 0.1)

                 for (SeqH in 1:SeqN) {
                   SeqH.Frags<-as.data.frame(SeqHighLights[[SeqH]])
                   #loop inside fragments
                   for (Fa in 1:nrow(SeqH.Frags)) {
                     Frag.start<-SeqH.Frags[Fa,]$start
                     Frag.end<-SeqH.Frags[Fa,]$end

                     ConsPos = circlize(c(Frag.start,Frag.end), c(SeqH-1, SeqH),
                                        sector.index = "Consensus", track.index = 1)
                     draw.sector(ConsPos[2, "theta"],ConsPos[1, "theta"],
                                 rou1 = ConsPos[1, "rou"], rou2 = ConsPos[2, "rou"],
                                 clock.wise = FALSE, col = SectorColors[SeqH],border = "white")

                   }
                 }

                 circos.text(rep(xlim[1], SeqN), 1:SeqN,
                             paste(SeqLabelsToDraw),
                             facing = "downward", adj = c(1.05, 0.5), cex = cex.SeqLabels)

                 #A fixed 100bp step works for a ~1000bp example sequence but produces
                 #hundreds of overlapping, unreadable ticks on a real tens-of-kb genome;
                 #target ~8 ticks regardless of the actual sequence length instead.
                 breaks = niceTicks(0, ConsLength)
                 circos.axis(h = "top", major.at = breaks, labels = paste0(breaks, "bp"),
                             labels.cex = cex.bpLabels)
               })
}

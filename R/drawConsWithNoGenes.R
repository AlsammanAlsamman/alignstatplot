#' Draw Consensus Circos without Links
#'
#' @param SeqInfo Table of sequence information generated using \code{\link{getSeqInfo}}
#' @param SeqAligned list of aligned vectors contains aligned sequences using \code{\link{alignment2Fasta}}
#' @param cex.SeqLabels A number for sequence labels font size
#' @param cex.bpLabels A number for base pair labels font size
#'
#' @return plot an alignment circle
#' @export
drawConsWithNoGenes<-function(SeqInfo,SeqAligned,cex.SeqLabels=0.5,cex.bpLabels=0.3)
{
  #Sequences colors
  ColorsN <- nrow(SeqInfo)
  SectorColors<-getSeqColors(ColorsN)

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
                                 col = "#CCCCCC",lwd = 0.1)

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
                             paste(SeqInfo$Name),
                             facing = "downward", adj = c(1.05, 0.5), cex = cex.SeqLabels)

                 breaks = seq(0, ConsLength, by = 100)   #we can handle it by removing label
                 circos.axis(h = "top", major.at = breaks, labels = paste0(breaks, "bp"),
                             labels.cex = cex.bpLabels)
               })
}

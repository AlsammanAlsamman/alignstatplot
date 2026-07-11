#' Draw circos plot for sequence alignment for genes with the consensus sequence
#'
#' @param SeqInfo Table of sequence information generated using \code{\link{getSeqInfo}}
#' @param SeqAligned list of aligned vectors contains aligned sequences using \code{\link{alignment2Fasta}}
#' @param consZoomFactor A number between 1-10 for the size of the consensus representation
#' in relative to the other sequences
#' @param geneLabels custom display names for the sequences, one per row of \code{SeqInfo}
#' (default: \code{SeqInfo$Name}). Only affects the displayed text, not sector identity/ordering.
#' @param consensusLabel custom display name for the consensus sector (default: \code{"Consensus"})
#' @param cex.SeqLabels A number for sequence name labels font size
#' @param cex.ConsLabel A number for the consensus label font size (default: \code{cex.SeqLabels})
#' @param cex.RulerLabels A number for the base-pair ruler tick label font size of the
#' sequences (each sequence only occupies a fraction of the circle, so this needs to stay
#' smaller than \code{cex.ConsRulerLabels} to avoid overlap)
#' @param cex.ConsRulerLabels A number for the base-pair ruler tick label font size of the
#' consensus sector, which spans the whole circle and so has much more room per tick
#' @param colors sector colors, one per sequence (default: \code{\link{getSeqColors}})
#' @param linkAlpha transparency of the consensus-to-sequence links (0-1)
#' @return plot of sequence alignment for genes with the consensus sequence
#' @export
#' @import circlize
drawConsWithGenes<-function(SeqInfo,
                            SeqAligned,consZoomFactor=3,
                            geneLabels=NULL,
                            consensusLabel="Consensus",
                            cex.SeqLabels=0.5,
                            cex.ConsLabel=cex.SeqLabels,
                            cex.RulerLabels=0.45,
                            cex.ConsRulerLabels=0.9,
                            colors=NULL,
                            linkAlpha=0.4){
  if (nrow(SeqInfo)>15) {
    warning("The kind of plot will be missy with more sequences than 15 sequences, please use drawConsWithNoGenes instead")
  }
  if (!is.null(geneLabels) && length(geneLabels) != nrow(SeqInfo)) {
    stop("geneLabels must have one entry per sequence (", nrow(SeqInfo), "), got ", length(geneLabels), ".")
  }
  #Sequences colors
  ColorsN <- nrow(SeqInfo)
  SectorColors<-if (is.null(colors)) getSeqColors(ColorsN) else colors
  #Length of the consensus is the length of any aligned sequence
  ConsLength<-length(SeqAligned[[1]])
  #Calculate consensus width using the zooming factor
  sector.width<-getSectorWidth(SeqInfo,ConsLength,consZoomFactor) #Zooming Factor is 3 by Default
  #Clear Prev

  circos.clear()
  #Global Variables
  circos.par(gap.degree = 5)
  #Draw Genes basic structure
  mycircos.Seq.Sectors = data.frame(sectors = c(SeqInfo$Name,"Consensus"),
                                    x = 1, y = c(SeqInfo$Length,ConsLength))
  #Display labels are drawn ourselves (below) so the consensus label can have
  #its own font size; circos.genomicInitialize only supports one shared cex.
  circos.genomicInitialize(mycircos.Seq.Sectors, plotType = character(0),
                           sector.width = as.numeric(sector.width$factor))
  inv <- "Consensus"

  #Sector name labels (genes + consensus), each with its own display text/size
  SectorLabels<-c(if (is.null(geneLabels)) SeqInfo$Name else geneLabels, consensusLabel)
  names(SectorLabels)<-mycircos.Seq.Sectors$sectors
  #circos.genomicInitialize() itself zeroes cell.padding while it builds its
  #label track, then restores it; do the same for our own label track, or a
  #short/large-cex label track can be taller than the default cell padding.
  opCellPadding<-circos.par("cell.padding")
  circos.par(cell.padding = c(0, 0, 0, 0))
  circos.track(ylim = c(0, 1), bg.border = NA,
              track.height = strheight("chr", cex = max(cex.SeqLabels, cex.ConsLabel)),
              panel.fun = function(x, y) {
                sector.index<-CELL_META$sector.index
                thisCex<-if (sector.index == inv) cex.ConsLabel else cex.SeqLabels
                circos.text(mean(CELL_META$xlim), 0, labels = SectorLabels[sector.index],
                           cex = thisCex, adj = c(0.5, 0), niceFacing = TRUE)
              })
  circos.par(cell.padding = opCellPadding)

  #Draw Genes and Consensus
  drawGenes(mycircos.Seq.Sectors,inv,labelCexScale=cex.RulerLabels,consLabelCexScale=cex.ConsRulerLabels)

  # Draw Fragments---------------------------------

  SeqHighLights<-alignmentNoGaps(SeqAligned)

  ConsDegreeSt<- get.cell.meta.data("cell.start.degree", sector.index = "Consensus")
  ConsDegreeEn<- get.cell.meta.data("cell.end.degree", sector.index = "Consensus")

  SectorsCount<-length(SeqHighLights)
  #loop inside sequences
  for (SeqH in 1:length(SeqHighLights)) {
    SeqH.Frags<-as.data.frame(SeqHighLights[[SeqH]])

    SecStep<-(0.5/SectorsCount)
    SectSt<-0+SecStep*(SeqH-1)
    SectEn<-SecStep+SecStep*(SeqH-1)
    #loop inside fragments
    for (Fa in 1:nrow(SeqH.Frags)) {
      Frag.start<-SeqH.Frags[Fa,]$start
      Frag.end<-SeqH.Frags[Fa,]$end
      ConsPos = circlize(c(ConsLength-Frag.start,ConsLength-Frag.end), c(0.2, 0.8), sector.index = "Consensus", track.index = 1)
      draw.sector(ConsPos[1, "theta"],ConsPos[2, "theta"],
                  rou2 = 1-SectSt-0.11, rou1 = 1-SectEn-0.11,
                  clock.wise = FALSE, col = SectorColors[SeqH],border = "white")
    }
  }

  # Draw Links---------------------------------
  SeqHighLights.Links<-alignmentNoGapsLinks(SeqAligned,SeqHighLights)


  for (SeqH in 1:length(SeqHighLights)) {

    SeqH.Frags<-as.data.frame(SeqHighLights[[SeqH]])
    SeqH.Links<-as.data.frame(SeqHighLights.Links[[SeqH]])
    colnames(SeqH.Links)<-c("start","end")
    bedCons<-as.data.frame(matrix(nrow = nrow(SeqH.Frags),ncol = 4))
    colnames(bedCons)<-c("chr","start","end","value1")

    SeqTarget<-as.data.frame(matrix(nrow = nrow(SeqH.Links),ncol = 4))

    colnames(SeqTarget)<-c("chr","start","end","value1")
    # Zero 1 Problem
    bedCons$chr<-"Consensus"
    bedCons$end<-ConsLength-SeqH.Frags$start
    bedCons$start<-ConsLength-SeqH.Frags$end+1

    SeqTarget$chr<-SeqInfo$Name[SeqH]
    SeqTarget$start<-SeqH.Links$start
    SeqTarget$end<-SeqH.Links$end

    circos.genomicLink(bedCons,SeqTarget,col = adjustcolor( SectorColors[SeqH], alpha.f = linkAlpha)
                       , rou1=0.39,rou2 = 0.9)

  }
  #Clear All
  circos.clear()
}

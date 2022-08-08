#' Draw circos plot for sequence alignment for genes with the consensus sequence
#'
#' @param SeqInfo Table of sequence information generated using \code{\link{getSeqInfo}}
#' @param SeqAligned list of aligned vectors contains aligned sequences using \code{\link{alignment2Fasta}}
#' @param consZoomFactor A number between 1-10 for the size of the consensus representation
#' in relative to the other sequences
#' @param cex.SeqLabels A number for sequence labels font size
#' @return plot of sequence alignment for genes with the consensus sequence
#' @export
#' @import circlize
drawConsWithGenes<-function(SeqInfo,
                            SeqAligned,consZoomFactor=3,
                            cex.SeqLabels=0.5){
  if (nrow(SeqInfo)>15) {
    warning("The kind of plot will be missy with more sequences than 15 sequences, please use drawConsWithNoGenes instead")
  }
  #Sequences colors
  ColorsN <- nrow(SeqInfo)
  SectorColors<-getSeqColors(ColorsN)
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
  circos.genomicInitialize(mycircos.Seq.Sectors, plotType = "labels",sector.width = as.numeric(sector.width$factor),labels.cex = cex.SeqLabels) #labels fonts
  inv <- "Consensus"

  #Draw Genes and Consensus
  drawGenes(mycircos.Seq.Sectors,inv)

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

    circos.genomicLink(bedCons,SeqTarget,col = adjustcolor( SectorColors[SeqH], alpha.f = 0.4)
                       , rou1=0.39,rou2 = 0.9)

  }
  #Clear All
  circos.clear()
}

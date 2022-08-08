#' Drawing sequence basic structure including inverting the consensus direction without links
#' @param mycircos.Seq.Sectors Table of genes as sectors of the circle plot
#' @param inv The name of the sequence that will be inverted -- mostly the consensus
#'
#' @return draws genes and consensus as a part of the drawing alignment function \code{\link{drawConsWithGenes}}
#' @export
#' @import circlize
drawGenes<-function(mycircos.Seq.Sectors,inv){
  # Rules
  circos.track(ylim = c(0, 1), track.margin = convert_height(c(0,0), "mm"),
               bg.border = NA, cell.padding = c(0, 0, 0, 0),
               track.height = uh(3, "mm"))
  circos.track(ylim = c(0, 1), bg.border = NA, cell.padding = c(0, 0, 0, 0),
               track.height = uh(3, "mm"), panel.fun = function(x, y) {
                 if(CELL_META$sector.index == inv) {
                   major.by = seqWithLast(mycircos.Seq.Sectors[which(mycircos.Seq.Sectors$sectors == inv), 2],
                                      mycircos.Seq.Sectors[which(mycircos.Seq.Sectors$sectors == inv), 3],
                                      by = 200) #number of divission of he rule
                   circos.axis(major.at = rev(major.by), labels = paste0(major.by,"bp"), #, "bp"
                               labels.cex = 0.4 * par("cex"))
                 }else {
                   major.by = seqWithLast(mycircos.Seq.Sectors[which(mycircos.Seq.Sectors$sectors ==
                                                                   CELL_META$sector.index), 2],
                                      mycircos.Seq.Sectors[which(mycircos.Seq.Sectors$sectors == CELL_META$sector.index),
                                                           3], by= 300) #number of divissions of the rule
                   circos.axis(major.at = major.by, labels = paste0(major.by), #, "bp"
                               labels.cex = 0.4 * par("cex"))
                 }
               })
}

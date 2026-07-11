#' A "nice" tick spacing for an axis spanning \code{from} to \code{to}
#'
#' @description Targets ~8 ticks regardless of the actual range, via \code{pretty()},
#' instead of a fixed bp interval -- a fixed interval (e.g. one tick every 200bp) works
#' fine for a ~1000bp example sequence but produces hundreds of overlapping,
#' unreadable ticks on a real tens-of-kb genome.
#' @param from range start
#' @param to range end
#' @return a single positive number: the spacing between ticks
tickStep<-function(from, to)
{
  breaks<-pretty(c(from, to), n = 8)
  step<-if (length(breaks) > 1) breaks[2] - breaks[1] else (to - from)
  max(1, step)
}

#' Drawing sequence basic structure including inverting the consensus direction without links
#' @param mycircos.Seq.Sectors Table of genes as sectors of the circle plot
#' @param inv The name of the sequence that will be inverted -- mostly the consensus
#' @param labelCexScale scale multiplier applied to the axis label font size of the
#' non-consensus sequences (relative to \code{par("cex")})
#' @param consLabelCexScale scale multiplier applied to the axis label font size of the
#' \code{inv} (consensus) sector (relative to \code{par("cex")}); defaults to \code{labelCexScale}
#'
#' @return draws genes and consensus as a part of the drawing alignment function \code{\link{drawConsWithGenes}}
#' @export
#' @import circlize
drawGenes<-function(mycircos.Seq.Sectors,inv,labelCexScale=0.4,consLabelCexScale=labelCexScale){
  # Rules
  circos.track(ylim = c(0, 1), track.margin = convert_height(c(0,0), "mm"),
               bg.border = NA, cell.padding = c(0, 0, 0, 0),
               track.height = uh(3, "mm"))
  circos.track(ylim = c(0, 1), bg.border = NA, cell.padding = c(0, 0, 0, 0),
               track.height = uh(3, "mm"), panel.fun = function(x, y) {
                 if(CELL_META$sector.index == inv) {
                   from<-mycircos.Seq.Sectors[which(mycircos.Seq.Sectors$sectors == inv), 2]
                   to<-mycircos.Seq.Sectors[which(mycircos.Seq.Sectors$sectors == inv), 3]
                   major.by = seqWithLast(from, to, by = tickStep(from, to))
                   circos.axis(major.at = rev(major.by), labels = paste0(major.by,"bp"), #, "bp"
                               labels.cex = consLabelCexScale * par("cex"))
                 }else {
                   from<-mycircos.Seq.Sectors[which(mycircos.Seq.Sectors$sectors == CELL_META$sector.index), 2]
                   to<-mycircos.Seq.Sectors[which(mycircos.Seq.Sectors$sectors == CELL_META$sector.index), 3]
                   major.by = seqWithLast(from, to, by = tickStep(from, to))
                   circos.axis(major.at = major.by, labels = paste0(major.by), #, "bp"
                               labels.cex = labelCexScale * par("cex"))
                 }
               })
}

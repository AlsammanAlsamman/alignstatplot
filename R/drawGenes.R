#' A "nice" tick spacing for an axis spanning \code{from} to \code{to}
#'
#' @description Targets \code{n} ticks regardless of the actual range, via
#' \code{pretty()}, instead of a fixed bp interval -- a fixed interval (e.g. one tick
#' every 200bp) works fine for a ~1000bp example sequence but produces hundreds of
#' overlapping, unreadable ticks on a real tens-of-kb genome. \code{n} itself should be
#' scaled down by the caller for axes with little room to draw labels in (e.g. a narrow
#' circos sector) -- a fixed target regardless of available space just moves the
#' overlap problem from "too many ticks for the data range" to "too many ticks for the
#' screen space".
#' @param from range start
#' @param to range end
#' @param n target tick count passed to \code{pretty()}
#' @return a single positive number: the spacing between ticks
tickStep<-function(from, to, n = 8)
{
  breaks<-pretty(c(from, to), n = n)
  step<-if (length(breaks) > 1) breaks[2] - breaks[1] else (to - from)
  max(1, step)
}

#' Evenly-spaced tick positions from \code{from} to \code{to}, endpoint included
#'
#' @description Combines \code{\link{tickStep}} and \code{\link{seqWithLast}}, with one
#' extra safeguard: \code{seqWithLast()} always appends the exact endpoint, which can land
#' close enough to the preceding regular tick to visually crowd/overlap once real labels
#' (not just points) are drawn -- especially on a narrow circos sector, where there's very
#' little angular room for the last pair of labels. Label *text* width doesn't shrink just
#' because the gap is smaller, so even a ~60-75% gap can still look crossed in practice; when
#' the gap is less than 80% of the regular step, the second-to-last tick is dropped so only
#' the true endpoint remains.
#' @param from range start
#' @param to range end
#' @param n target tick count, forwarded to \code{\link{tickStep}}
#' @return numeric vector of tick positions, always including \code{from} and \code{to}
niceTicks<-function(from, to, n = 8)
{
  step<-tickStep(from, to, n = n)
  ticks<-seqWithLast(from, to, by = step)
  nt<-length(ticks)
  if (nt >= 3 && (ticks[nt] - ticks[nt - 1]) < step * 0.8) {
    ticks<-ticks[-(nt - 1)]
  }
  ticks
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
                 #A sector only has as many degrees of arc as its share of the circle --
                 #a fixed tick-count target (e.g. always ~8) ignores that, so a sector
                 #with 10+ siblings and little angular room ends up with as many ticks as
                 #one that spans most of the circle, and the labels overlap. Scale the
                 #tick-count target down with the sector's actual angular width instead.
                 sectorDeg<-abs(get.cell.meta.data("cell.end.degree") - get.cell.meta.data("cell.start.degree"))
                 if(CELL_META$sector.index == inv) {
                   from<-mycircos.Seq.Sectors[which(mycircos.Seq.Sectors$sectors == inv), 2]
                   to<-mycircos.Seq.Sectors[which(mycircos.Seq.Sectors$sectors == inv), 3]
                   #Consensus labels are wider ("123bp") and drawn at a bigger cex than
                   #the plain-number gene labels below, so they need more degrees per tick.
                   n<-max(2, min(8, round(sectorDeg / 25)))
                   major.by = niceTicks(from, to, n = n)
                   circos.axis(major.at = rev(major.by), labels = paste0(major.by,"bp"), #, "bp"
                               labels.cex = consLabelCexScale * par("cex"))
                 }else {
                   from<-mycircos.Seq.Sectors[which(mycircos.Seq.Sectors$sectors == CELL_META$sector.index), 2]
                   to<-mycircos.Seq.Sectors[which(mycircos.Seq.Sectors$sectors == CELL_META$sector.index), 3]
                   n<-max(2, min(8, round(sectorDeg / 12)))
                   major.by = niceTicks(from, to, n = n)
                   circos.axis(major.at = major.by, labels = paste0(major.by), #, "bp"
                               labels.cex = labelCexScale * par("cex"))
                 }
               })
}

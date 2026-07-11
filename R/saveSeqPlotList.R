#' save plot lists
#'
#' @param PlotList list of plots
#' @param outFolder path to folder
#' @param width plot width
#' @param height plot height
#' @param format file format/extension passed to \code{\link[ggplot2]{ggsave}} (e.g. "pdf", "png")
#' @export
#' @importFrom  ggplot2 ggsave
#' @import ggplot2
saveSeqPlotList<-function(PlotList,outFolder,width = 15,height = 10,format = "pdf")
{
  lapply(names(PlotList),
         function(x)ggplot2::ggsave(filename=paste0(outFolder,x,".",format),
                           width = width,height = height, plot=PlotList[[x]]))
}


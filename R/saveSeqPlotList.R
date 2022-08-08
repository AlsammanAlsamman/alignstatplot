#' save plot lists
#'
#' @param PlotList list of plots
#' @param outFolder path to folder
#' @param width plot width
#' @param height plot height
#' @export
#' @importFrom  ggplot2 ggsave
#' @import ggplot2
saveSeqPlotList<-function(PlotList,outFolder,width = 15,height = 10)
{
  lapply(names(PlotList),
         function(x)ggplot2::ggsave(filename=paste(outFolder,x,".pdf",sep=""),
                           width = width,height = height, plot=PlotList[[x]]))
}


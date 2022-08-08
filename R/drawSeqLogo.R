#' Draw the aligned sequences in logo format
#'
#' @param SeqAligned Sequences aligned \code{\link{alignment2Fasta}}
#' @param joinPlot True/False Plot to one plot or to several plots
#' @param outFolder Specify the folder for plots
#' @param SplitLen Integer -- number of nucleotides in every plot
#' @param width Plot height
#' @param height Plot width
#'
#' @description Drawing of the aligned sequences in logo format showing the percentage for every nucleotide
#' @return plot
#' @export
#' @import ggseqlogo
#' @import ggplot2
#' @import patchwork
drawSeqLogo<-function(SeqAligned,SplitLen=50,joinPlot=T,outFolder="",width = 15,height = 30)
{
  if (!joinPlot && outFolder=="") {
    stop("Please specify folder 'outFolder' for the output")
  }
  if (outFolder!="") {
    outFolder<-formatFolderPath(outFolder)
    dir.create(file.path(outFolder), showWarnings = FALSE)
  }
  SeqLogo<-getSeqLogo(SeqAligned,SplitLen)
  SeqLogo
  #Split Sequence into equal length of 50 Nuc.
  CurrentLoc<-0

  #List of plots that will be joined
  AllPlots<-lapply(1:length(SeqLogo), function(x) {
    #The vector of logos
    xLogo<-SeqLogo[[x]]
    CurrentLoc<-SplitLen*x
    #If the chunk is less than 50
    if (nchar(xLogo[[1]])<SplitLen) {
      CurrentLoc<-SplitLen*(x-1)    #Previous sequence
      +nchar(xLogo[[1]]) #current sequence length
    }
    ggseqlogo(xLogo,method = 'prob')+
      ggtitle(paste0(CurrentLoc,"bp"))+
      theme(plot.title = element_text(color = "red",size = 5)) + theme_logo()
  })

  if (length(AllPlots)>=15 && joinPlot==T) {
    warning("The number of plots exceeds the available space for one page
            please add outfolder path and choose joinPlot = False")
  }
  if (joinPlot) {
    p<-patchwork::wrap_plots(AllPlots)+
      plot_layout(ncol=1,nrow = length(AllPlots),
                  heights =   c(rep(6,length(AllPlots))))
    if (outFolder!="") {
      ggplot2::ggsave(paste0(outFolder,
                      "Nuc_Frequency_With_Logo.pdf"),
                      plot = p, device = "pdf",
                      width = width,height = height)
    }
    else{
        p # return plot
    }

  }
  else{
    names(AllPlots)<-1:length(AllPlots)
    saveSeqPlotList(AllPlots,outFolder,height = height,width = width)
    print(paste0("Plots were saved to ",outFolder))
  }
}

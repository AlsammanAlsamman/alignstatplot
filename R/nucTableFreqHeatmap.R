#' Heatmap and frequency plots for sequence alignment
#' @param SeqAlignedTable list of aligned vectors contains aligned sequences using \code{\link{alignment2Fasta}}
#' @param cex.NucLabels Label font size
#' @param cex.SeqLabels Sequence name font size
#' @return Heatmap and frequency plots
#' @export
#' @import ggpubr grid
nucTableFreqHeatmap<-function(SeqAlignedTable,cex.NucLabels=7,cex.SeqLabels=10)
{
  #Calculate Frequency
  NucCount<-nucFrequency(SeqAlignedTable)

  #plot HeatMap
  NucMapPlot<-nucTableHeatmap(SeqAlignedTable)
  #+ theme(plot.margin=unit(c(-0.5,1,1,1),"cm"))
  #Plot Frequency
  NucFreqPlot<-nucFrequencyPlot(NucCount,F,cex.NucLabels)
  #+ theme(plot.margin=unit(c(1,1,-0.5,1),"cm"))
  #Join Plots
  p <- ggarrange(NucFreqPlot + rremove("ylab") + rremove("xlab") , NULL,
                 NucMapPlot + rremove("ylab") + rremove("xlab"),
                 labels = NULL,
                 ncol = 1, nrow = 3,
                 common.legend = TRUE, legend = "bottom",
                 align = "hv", heights = c(0.2,-0.05,0.8),
                 font.label = list(size = 10, color = "black", face = "bold", family = NULL, position = "top"))
  p<-annotate_figure(p, to = textGrob("Nucleotide Frequency", vjust = 1, gp = gpar(cex = 1.3)),
                     bottom = textGrob("Heatmap of Nucleotide Distribution", gp = gpar(cex = 1.3)))
  p
}

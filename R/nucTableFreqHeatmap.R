#' Heatmap and frequency plots for sequence alignment
#' @param SeqAlignedTable list of aligned vectors contains aligned sequences using \code{\link{alignment2Fasta}}
#' @param cex.NucLabels Label font size
#' @param cex.SeqLabels Sequence name font size
#' @param colors named color vector for nucleotides A, T, C, G, N, passed to
#' \code{\link{nucTableHeatmap}} and \code{\link{nucFrequencyPlot}} (default: the
#' package's standard nucleotide palette)
#' @param heights relative heights of the frequency plot, spacer, and heatmap panels
#' @param title top title text
#' @param subtitle bottom subtitle text
#' @param title_size font scale for \code{title}/\code{subtitle}
#' @return Heatmap and frequency plots
#' @export
#' @import ggpubr grid
nucTableFreqHeatmap<-function(SeqAlignedTable,cex.NucLabels=7,cex.SeqLabels=10,
                              colors=defaultNucleotideColors,
                              heights=c(0.2,-0.05,0.8),
                              title="Nucleotide Frequency",
                              subtitle="Heatmap of Nucleotide Distribution",
                              title_size=1.3)
{
  #Calculate Frequency
  NucCount<-nucFrequency(SeqAlignedTable)

  #plot HeatMap
  NucMapPlot<-nucTableHeatmap(SeqAlignedTable,cex.NucLabels=cex.NucLabels,cex.SeqLabels=cex.SeqLabels,colors=colors)
  #+ theme(plot.margin=unit(c(-0.5,1,1,1),"cm"))
  #Plot Frequency
  NucFreqPlot<-nucFrequencyPlot(NucCount,F,cex.NucLabels,colors=colors)
  #+ theme(plot.margin=unit(c(1,1,-0.5,1),"cm"))
  #Join Plots
  p <- ggarrange(NucFreqPlot + rremove("ylab") + rremove("xlab") , NULL,
                 NucMapPlot + rremove("ylab") + rremove("xlab"),
                 labels = NULL,
                 ncol = 1, nrow = 3,
                 common.legend = TRUE, legend = "bottom",
                 align = "hv", heights = heights,
                 font.label = list(size = 10, color = "black", face = "bold", family = NULL, position = "top"))
  p<-annotate_figure(p, top = textGrob(title, vjust = 1, gp = gpar(cex = title_size)),
                     bottom = textGrob(subtitle, gp = gpar(cex = title_size)))
  p
}

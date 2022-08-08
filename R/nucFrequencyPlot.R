#' Plot the frequency of nucleotides across the sequence
#'
#' @param NucCount Table of nueleotide frequency across the aligned sequences \code{\link{nucFrequency}}
#' @param xlabel font size of sequences names
#' @param cex.NucLabels font size of nucleotides
#'
#' @return A plot for the frequency of nucleotides
#' @export
#' @import  ggplot2 dplyr tidyr tibble
nucFrequencyPlot<-function(NucCount, xlabel=TRUE,cex.NucLabels=7){
  NucCount.Table<-NucCount%>%
    rownames_to_column %>%
    gather(col, value, -rowname)
  colnames(NucCount.Table)<-c("Nucleotide","Position","Frequency")
  #Do not change order , change to factor
  NucCount.Table$Position<-factor(NucCount.Table$Position,levels=unique(NucCount.Table$Position))
  NucCount.Table$Nucleotide<-factor(NucCount.Table$Nucleotide,levels = c("A", "T", "C","G","N"))

  p<-ggplot(data=NucCount.Table, aes(x=Position, y=Frequency, fill=Nucleotide)) +
    geom_bar(stat="identity")+ scale_y_continuous(labels = scales::percent)+
    scale_fill_manual(values=c("red", "blue", "green","yellow","black"))+
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(),
          panel.background = element_blank(),
          axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1,size = cex.NucLabels)
    )

  if (!xlabel) {
    p<-p+theme(axis.title.x=element_blank(),
               axis.text.x=element_blank(),
               axis.ticks.x=element_blank())
  }
  p
}

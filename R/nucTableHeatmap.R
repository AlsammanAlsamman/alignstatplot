#' Plot aligned sequence variation as heatmap
#'
#' @param SeqAlignedTable list of aligned vectors contains aligned sequences using \code{\link{alignment2Fasta}}
#' @param cex.NucLabels Label font size
#' @param cex.SeqLabels Sequence name font size
#'
#' @return Heatmap plot
#' @export
#' @importFrom  reshape2 melt
#' @import ggplot2
#' @import dplyr
nucTableHeatmap<-function(SeqAlignedTable,cex.NucLabels=7,cex.SeqLabels=10)
{
  SeqTableMelt <- melt(as.matrix(SeqAlignedTable))
  colnames(SeqTableMelt)<-c("SeqID","Nucleotide.Position","Nucleotide")
  SeqTableMelt$Nucleotide[SeqTableMelt$Nucleotide=="-"]<-"N"
  SeqTableMelt$Nucleotide<-factor(SeqTableMelt$Nucleotide,
                                  levels = c("A", "T", "C","G","N"))
  p<-ggplot(SeqTableMelt, aes(Nucleotide.Position, SeqID)) +
    geom_tile(aes(fill = Nucleotide),colour = "white") +
    scale_fill_manual(values=c("red", "blue", "green","yellow","black"))+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1,size = cex.NucLabels),
          axis.text.y = element_text(size = cex.SeqLabels))
  p
}

#' Plot aligned sequence variation as heatmap
#'
#' @param SeqAlignedTable list of aligned vectors contains aligned sequences using \code{\link{alignment2Fasta}}
#' @param cex.NucLabels Label font size
#' @param cex.SeqLabels Sequence name font size
#' @param colors named color vector for nucleotides A, T, C, G, N (default:
#' the package's standard nucleotide palette, shared with \code{\link{nucFrequencyPlot}})
#'
#' @return Heatmap plot
#' @export
#' @importFrom tidyr pivot_longer
#' @import ggplot2
#' @import dplyr
nucTableHeatmap<-function(SeqAlignedTable,cex.NucLabels=7,cex.SeqLabels=10,colors=defaultNucleotideColors)
{
  # Reimplements reshape2::melt(matrix) via pivot_longer: melt traverses
  # column-major (all rows for position 1, then position 2, ...) and keeps
  # Nucleotide.Position as an integer when the matrix has no column names, or
  # as a factor (levels = original column order) when it does. Both are
  # replicated explicitly below so the resulting plot is unchanged.
  SeqMatrix<-as.matrix(SeqAlignedTable)
  SeqDF<-as.data.frame(SeqMatrix, stringsAsFactors = FALSE, check.names = FALSE)
  if (is.null(colnames(SeqMatrix))) {
    PositionLevels<-seq_len(ncol(SeqMatrix))
    colnames(SeqDF)<-as.character(PositionLevels)
  } else {
    PositionLevels<-colnames(SeqMatrix)
  }
  SeqDF$SeqID<-factor(rownames(SeqMatrix), levels = rownames(SeqMatrix))
  SeqTableMelt<-pivot_longer(SeqDF, cols = -SeqID,
                             names_to = "Nucleotide.Position",
                             values_to = "Nucleotide")
  SeqTableMelt<-as.data.frame(SeqTableMelt)
  if (is.null(colnames(SeqMatrix))) {
    SeqTableMelt$Nucleotide.Position<-as.integer(SeqTableMelt$Nucleotide.Position)
  } else {
    SeqTableMelt$Nucleotide.Position<-factor(SeqTableMelt$Nucleotide.Position, levels = PositionLevels)
  }
  SeqTableMelt<-SeqTableMelt[order(SeqTableMelt$Nucleotide.Position, SeqTableMelt$SeqID), ]
  SeqTableMelt<-SeqTableMelt[, c("SeqID","Nucleotide.Position","Nucleotide")]
  rownames(SeqTableMelt)<-NULL
  SeqTableMelt$Nucleotide[SeqTableMelt$Nucleotide=="-"]<-"N"
  SeqTableMelt$Nucleotide<-factor(SeqTableMelt$Nucleotide,
                                  levels = c("A", "T", "C","G","N"))
  p<-ggplot(SeqTableMelt, aes(Nucleotide.Position, SeqID)) +
    geom_tile(aes(fill = Nucleotide),colour = "white") +
    scale_fill_manual(values=colors)+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1,size = cex.NucLabels),
          axis.text.y = element_text(size = cex.SeqLabels))
  p
}

#' Return Gene information table for clusterplot
#' @param SeqInfo Information of the sequences \code{\link{getSeqInfo}}
#' @return data.frame
GeneInfoForClusterPlot<-function(SeqInfo)
{
  GeneInfoTable<-as.data.frame(matrix(nrow = nrow(SeqInfo), ncol = 6))
  colnames(GeneInfoTable)<-c("molecule","gene","start","end","strand","orientation")
  GeneInfoTable$molecule<-SeqInfo$Name
  GeneInfoTable$gene<-SeqInfo$Name
  GeneInfoTable$start<-0
  GeneInfoTable$end<-SeqInfo$Length
  GeneInfoTable$strand<-"forward"
  GeneInfoTable$orientation<-1
  GeneInfoTable
}

#' Read Annotation file
#'
#' @param AnnoFilePath Annotation file path
#' @param GeneInfoTable Gene information Table
#'
#' @return Table
AnnotationTable<-function(AnnoFilePath,GeneInfoTable)
{
  AnnoProvided<-read.table(AnnoFilePath)
  GeneAnnotationTable<-as.data.frame(matrix( ncol = 9,nrow = nrow(AnnoProvided)))
  colnames(GeneAnnotationTable)<-c("molecule","gene","start","end","strand","subgene","from","to","orientation")
  GeneAnnotationTable$molecule<-AnnoProvided$V1
  GeneAnnotationTable$gene<-AnnoProvided$V1
  GeneAnnotationTable$strand<-AnnoProvided$V5
  GeneAnnotationTable$subgene<-AnnoProvided$V2
  GeneAnnotationTable$from<-AnnoProvided$V3
  GeneAnnotationTable$to<-AnnoProvided$V4
  GeneAnnotationTable$orientation<-1
  GeneAnnotationTable$start<-0
  ends<-c()
  i<-1
  for (g in GeneAnnotationTable$gene) {
    ends[i]<-GeneInfoTable[GeneInfoTable$molecule==g,]$end
    i<-i+1
  }
  GeneAnnotationTable$end<-ends
  GeneAnnotationTable
}

#' Title
#'
#' @param SeqInfo table of sequence information generated using \code{\link{getSeqInfo}}
#' @param Alignment sequence alignment object
#' @param AnnoFilePath Annotation file path
#' @import ggplot2
#' @import gggenes
#' @import ggtree
#' @import forcats
#' @import cowplot
#' @return plot
#' @export
plotTreeWithGenes<-function(SeqInfo,Alignment,AnnoFilePath)
{

  #Phylogenetic Tree
  DistanceTable<-getDistanceMatrixTabel(SeqInfo,Alignment)
  options(ignore.negative.edge=TRUE)
  myTree<-getTree(DistanceTable)
  #Tree order
  TreeTable=fortify(myTree)
  TipTable = subset(TreeTable, isTip)
  NodesOrder<-TipTable$label[order(TipTable$y, decreasing=TRUE)]
  #Gene Information
  GeneInfoTable<-GeneInfoForClusterPlot(SeqInfo)
  GeneInfoTable<-GeneInfoTable[match(rev(NodesOrder), GeneInfoTable$molecule),]
  #Read Annotation File
  GeneAnnotationTable<-AnnotationTable(AnnoFilePath,GeneInfoTable)
  ##### Sequences
  SeqClPlot<-GeneInfoTable %>% ggplot(aes(xmin = start, xmax = end, y = molecule))+
    geom_gene_arrow(fill = "white")+ aes(y = fct_inorder(gene))+
    geom_subgene_arrow(data = GeneAnnotationTable,
                       aes(xmin = start, xmax = end,
                           y = molecule, fill = subgene,
                           xsubmin = from, xsubmax = to),
                       color="black", alpha=.7) + theme_genes()+
    guides(fill=guide_legend(title="Gene Structure"))+
    theme(axis.title.y = element_blank()) +
    theme(plot.margin=unit(c(0,0,0,0), "cm"))+
    #### Prepare part
    theme_tree2() +
    xlab(NULL) + ylab(NULL)+
    theme_minimal()+ theme(
      panel.grid = element_blank(),
      axis.title = element_blank(),
      axis.text = element_blank(),
      axis.ticks.x = element_blank())

  SeqTreePlot <- ggtree(myTree) + geom_tiplab(align=TRUE,size=3) + hexpand(.4)
  #Join Plots
  SeqTreePlot
  plot_grid(SeqTreePlot,SeqClPlot, ncol=2,rel_widths = c(1,2),label_size = 1)
}






#' Plot distance matrix and phylogenetic tree in the same figure as heatmap
#'
#' @param seqInfo table of sequence information generated using \code{\link{getSeqInfo}}
#' @param seqAlignment sequence alignment object
#' @param plotTree logical plot phyolgenetic tree
#' @param plotDisMatrix logical plot heatmap of distance matrix
#' @return Tree and Heatmap plots
#' @export
#' @import RColorBrewer
#' @importFrom phytools phylo.heatmap
plotSimilarityMatrixWithTree<-function(seqInfo,seqAlignment,
                                       plotTree=TRUE,plotDisMatrix=TRUE)
{

  DistMatrixTable<-getDistanceMatrixTabel(seqInfo,seqAlignment)
  SeqTree<-getTree(DistMatrixTable)

  #HeatMap color Scale
  colors<-colorRampPalette(colors=c("blue","yellow","red"))(20)
  #gene font size
  genfsize<-0.8
  seqnum<-nrow(DistMatrixTable)
  if (seqnum > 100) {
    genfsize<- 0.2
    } else if (seqnum > 80 && seqnum < 100) {
      genfsize<- 0.3
    } else if (seqnum > 60 && seqnum < 80) {
      genfsize<- 0.4
    } else if (seqnum > 40 && seqnum < 60) {
      genfsize<- 0.4
    } else if (seqnum > 20 && seqnum < 40) {
      genfsize<- 0.5
    } else if (seqnum < 20) {
      genfsize<- 0.7
    }



  figure<-phylo.heatmap(SeqTree,as.matrix(DistMatrixTable),
                        fsize=c(genfsize,genfsize,genfsize),
                        colors=colors,standardize = F)
  figure
}

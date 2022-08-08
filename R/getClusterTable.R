#' Get Cluster Table of SNPs
#'
#' @param Cluster Cluster object generated using \code{\link{SNPCluster}}
#'
#' @return data.frame
#' @export
getClusterTable<-function(Cluster)
{
  ClustTable<-data.frame(Nucleotide=rownames(Cluster$data.clust),
                         Cluster=Cluster$data.clust$clust)
  ClustTable
}

#' Get Cluster Table of SNPs
#'
#' @param Cluster Cluster object generated using \code{\link{SNPCluster}}
#'
#' @return data.frame
#' @export
getClusterTable<-function(Cluster)
{
  if (is.null(Cluster$data.clust) || is.null(Cluster$data.clust$clust)) {
    stop("Cluster must be an HCPC object with a 'data.clust' data.frame containing a 'clust' column, as returned by SNPCluster().")
  }
  ClustTable<-data.frame(Nucleotide=rownames(Cluster$data.clust),
                         Cluster=Cluster$data.clust$clust)
  ClustTable
}

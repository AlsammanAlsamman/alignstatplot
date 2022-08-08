#' Get Tree from a distance Matrix
#'
#' @param DistMatrixTable A distance matrix for similarity matrix across the genes
#' generated using \code{\link{getDistanceMatrixTabel}}
#'
#' @return an object of class "phylo"
#' @export
#' @importFrom ape nj
getTree<-function(DistMatrixTable)
{
  SeqTree <- nj(as.dist(DistMatrixTable))
  SeqTree
}

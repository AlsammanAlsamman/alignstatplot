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
  if (is.null(dim(DistMatrixTable)) || nrow(DistMatrixTable) != ncol(DistMatrixTable)) {
    stop("DistMatrixTable must be a square distance matrix, as returned by getDistanceMatrixTabel().")
  }
  if (nrow(DistMatrixTable) < 3) {
    stop("At least 3 sequences are required to build a neighbor-joining tree, got ", nrow(DistMatrixTable), ".")
  }
  SeqTree <- nj(as.dist(DistMatrixTable))
  SeqTree
}

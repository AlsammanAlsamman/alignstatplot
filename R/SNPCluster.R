#' Performs MCA or PCA clustering depending on data type
#'
#' @param SeqAlignedTable list of aligned vectors contains aligned sequences using \code{\link{alignment2Fasta}}
#' @param ncp number of dimensions kept in the results (by default 5)
#' @description The function perfoms clustering analysis dependiong on the data format
#' if the provided data is binary based {0, 1} it will use PCA analysis a PCA list components please see \code{\link[FactoMineR]{PCA}}
#' , while if allele-based {A,C,T,G} it will use \code{\link[FactoMineR]{MCA}}
#' @return an HCPC object  \code{\link[FactoMineR]{HCPC}}
#' @export
#' @importFrom FactoMineR PCA MCA HCPC
SNPCluster<-function(SeqAlignedTable,ncp=20)
{
  if (is.null(dim(SeqAlignedTable)) || nrow(SeqAlignedTable) == 0 || ncol(SeqAlignedTable) == 0) {
    stop("SeqAlignedTable must be a non-empty matrix/data.frame of aligned sequences (rows) x nucleotide positions (columns), as returned by alignment2Table() or nucTableFilter().")
  }
  if (!is.numeric(ncp) || length(ncp) != 1 || ncp < 1) {
    stop("ncp must be a single positive number, got: ", ncp)
  }
  CaAnalysis<-""
  SeqAlignedTable[SeqAlignedTable=="-"]<-NA

  if (length(grep("[A|T|C|G]",SeqAlignedTable[1,]))>0)
    CaAnalysis<- MCA(as.matrix(t(SeqAlignedTable)),
                     ncp = ncp,
                     graph=FALSE)
  else{
    options(warn=-1) # Suppress warning if data contains Missing Values and it will imputed by average
    CaAnalysis <- PCA(t(data.matrix(SeqAlignedTable)), ncp = ncp, graph = FALSE)
    options(warn=0)
  }


  HCPCanalysis <- HCPC (CaAnalysis, graph = FALSE)
  HCPCanalysis
}

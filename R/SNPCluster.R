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

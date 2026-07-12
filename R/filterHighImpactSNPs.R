#' Keep only the highest-impact SNPs identified by SNPClusterImpact()
#'
#' @description A QC layer for the SNP-clustering pipeline: after
#' \code{Cluster<-SNPCluster(SeqAlignedTableFiltered)}, most real SNP tables have far more
#' columns than actually drive the clustering structure (see \code{\link{SNPClusterImpact}}).
#' Re-running \code{SNPCluster()} on just the high-impact subset this returns gives a cleaner
#' clustering and much less crowded downstream plots (\code{\link{SNPClusterPlot1DTree}},
#' \code{\link{SNPClusterPlot3DTree}}, \code{\link{SNPClusterPlotPCAMap}}) without changing
#' which structure they show, since the low-impact SNPs contributed little to it anyway.
#' @param SeqAlignedTable the same table originally passed to \code{SNPCluster()}
#' (sequences x SNP columns)
#' @param ImpactTable output of \code{\link{SNPClusterImpact}}
#' @param topN keep this many of the highest-impact SNPs. Mutually exclusive with
#' \code{minImpact}; if both are left \code{NULL}, defaults to the elbow point of the
#' sorted impact curve (see \code{\link{plotSNPClusterImpact}} to inspect that choice
#' before committing to it)
#' @param minImpact keep SNPs with \code{Impact >= minImpact}. Mutually exclusive with
#' \code{topN}
#' @return \code{SeqAlignedTable} subset to the kept SNP columns, in their original column
#' order (so downstream position-based logic, e.g. \code{\link{regionStats}}, still works)
#' @export
filterHighImpactSNPs<-function(SeqAlignedTable, ImpactTable, topN=NULL, minImpact=NULL)
{
  if (!all(c("SNP","Impact") %in% colnames(ImpactTable))) {
    stop("ImpactTable must be the output of SNPClusterImpact() (needs SNP, Impact columns).")
  }
  if (!is.null(topN) && !is.null(minImpact)) {
    stop("Specify only one of topN or minImpact, not both.")
  }
  if (is.null(topN) && is.null(minImpact)) {
    topN<-findImpactElbow(ImpactTable$Impact[order(-ImpactTable$Impact)])
  }

  if (!is.null(topN)) {
    if (!is.numeric(topN) || length(topN) != 1 || topN < 1) {
      stop("topN must be a single positive number, got: ", topN)
    }
    keepSNPs<-ImpactTable$SNP[order(-ImpactTable$Impact)][seq_len(min(topN, nrow(ImpactTable)))]
  } else {
    if (!is.numeric(minImpact) || length(minImpact) != 1) {
      stop("minImpact must be a single number, got: ", minImpact)
    }
    keepSNPs<-ImpactTable$SNP[ImpactTable$Impact >= minImpact]
  }

  keepCols<-intersect(colnames(SeqAlignedTable), keepSNPs)
  if (length(keepCols)==0) {
    stop("No SNP columns matched after filtering; ImpactTable must come from the same SeqAlignedTable/Cluster.")
  }
  SeqAlignedTable[, keepCols, drop = FALSE]
}

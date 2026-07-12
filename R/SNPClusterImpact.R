#' Rank each SNP by how much it drives the SNPCluster() clustering structure
#'
#' @description \code{\link{SNPCluster}} clusters SNPs (as MCA/PCA "individuals") on their
#' retained principal dimensions. FactoMineR already computes, per SNP, its percent
#' contribution to each of those dimensions (\code{contrib}) and how well it is represented
#' on them (\code{cos2}) -- this collapses both into a single per-SNP "impact" score by
#' weighting each dimension's contribution by how much variance that dimension explains
#' (\code{eig[, "percentage of variance"]}), so a SNP that dominates a high-variance
#' dimension counts for more than one that only dominates a noisy, low-variance one.
#' @param Cluster an HCPC object from \code{\link{SNPCluster}}
#' @return data.frame with one row per SNP, sorted by descending Impact:
#' \describe{
#'   \item{SNP}{column name from the table originally passed to \code{SNPCluster()}}
#'   \item{Impact}{variance-weighted contribution to the retained dimensions (0-100)}
#'   \item{Cos2}{variance-weighted quality of representation (0-1); low values flag SNPs
#'   whose variation isn't well captured by the retained dimensions at all (noisy/singleton
#'   patterns), as distinct from SNPs that are well represented but simply low-impact}
#'   \item{Cluster}{the SNP's assigned cluster id, as in \code{\link{getClusterTable}}}
#' }
#' @export
SNPClusterImpact<-function(Cluster)
{
  if (is.null(Cluster$data.clust) || is.null(Cluster$data.clust$clust) ||
      is.null(Cluster$call$t$res$ind$contrib) || is.null(Cluster$call$t$res$eig)) {
    stop("Cluster must be an HCPC object with the underlying PCA/MCA result attached, as returned by SNPCluster().")
  }
  res<-Cluster$call$t$res
  contrib<-res$ind$contrib
  cos2<-res$ind$cos2
  eigPct<-res$eig[seq_len(ncol(contrib)), "percentage of variance"]
  #A dimension with ~zero eigenvalue carries no real variance, and FactoMineR's own
  #contrib/cos2 for it is an undefined 0/0 (NaN) rather than a true zero -- weighting it
  #by 0 does not clean that up (0 * NaN is still NaN in IEEE arithmetic), so such
  #dimensions must be dropped before the weighted sum, not just given zero weight.
  validDims<-eigPct > 1e-8
  if (!any(validDims)) validDims<-rep(TRUE, length(eigPct))
  contrib<-contrib[, validDims, drop = FALSE]
  cos2<-cos2[, validDims, drop = FALSE]
  eigPct<-eigPct[validDims]
  w<-eigPct / sum(eigPct)

  clust<-stats::setNames(as.character(Cluster$data.clust$clust), rownames(Cluster$data.clust))

  ImpactTable<-data.frame(
    SNP = rownames(contrib),
    Impact = as.numeric(contrib %*% w),
    Cos2 = as.numeric(cos2 %*% w),
    Cluster = unname(clust[rownames(contrib)]),
    stringsAsFactors = FALSE
  )
  ImpactTable[order(-ImpactTable$Impact), ]
}

#' Rank at which the sorted-descending impact curve bends the most ("elbow")
#'
#' @description Standard elbow-detection heuristic: the point on the curve farthest from
#' the straight line connecting its first and last points. Used by
#' \code{\link{filterHighImpactSNPs}} as the default \code{topN} when the caller doesn't
#' supply one, and drawn as a suggested cutoff by \code{\link{plotSNPClusterImpact}}.
#' @param sortedImpact numeric vector, sorted descending
#' @return a single integer rank (1-based)
findImpactElbow<-function(sortedImpact)
{
  n<-length(sortedImpact)
  if (n<3) return(n)
  x<-(seq_len(n) - 1) / (n - 1)
  yRange<-diff(range(sortedImpact))
  y<-if (yRange==0) rep(0, n) else (sortedImpact - min(sortedImpact)) / yRange
  x1<-x[1]; y1<-y[1]; x2<-x[n]; y2<-y[n]
  d<-abs((y2 - y1) * x - (x2 - x1) * y + x2 * y1 - y2 * x1) / sqrt((y2 - y1)^2 + (x2 - x1)^2)
  which.max(d)
}

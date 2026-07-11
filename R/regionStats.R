#' Aggregate per-position conservation statistics within annotated regions
#'
#' @description Reads an annotation file in the same raw layout already used by
#' \code{\link{plotTreeWithGenes}} (columns: molecule name, region type, start, end,
#' strand -- whitespace-separated, no header), and aggregates
#' \code{\link{positionConservation}}'s output within each annotated region. Only one
#' molecule's annotation is used at a time, since \code{PositionStats} is indexed by a
#' single shared alignment-column coordinate system (the same coordinate assumption
#' \code{\link{plotTreeWithGenes}} already makes for its gene-structure panel).
#' @param PositionStats output of \code{\link{positionConservation}}
#' @param AnnoFilePath Annotation file path (same format as used by \code{\link{plotTreeWithGenes}})
#' @param referenceName molecule name whose annotation rows to use (default: the first
#' molecule name found in the file)
#' @return data.frame with one row per annotated region: \code{Type}, \code{Start},
#' \code{End}, \code{NumPositions}, \code{MeanConservation}, \code{MeanMissingFrac},
#' \code{VariableSites} (raw count), \code{VariantRate} (\code{VariableSites / NumPositions},
#' comparable across regions of different lengths)
#' @export
regionStats<-function(PositionStats, AnnoFilePath, referenceName = NULL)
{
  if (!all(c("Position","Conservation","MissingFrac") %in% colnames(PositionStats))) {
    stop("PositionStats must be the output of positionConservation() (needs Position, Conservation, MissingFrac columns).")
  }
  if (!is.character(AnnoFilePath) || length(AnnoFilePath) != 1 || !file.exists(AnnoFilePath)) {
    stop("AnnoFilePath must be a path to an existing annotation file; got: ", paste(AnnoFilePath, collapse = ", "))
  }
  AnnoProvided<-read.table(AnnoFilePath, stringsAsFactors = FALSE)
  if (ncol(AnnoProvided) < 4) {
    stop("Annotation file must have at least 4 whitespace-separated columns (molecule, type, start, end); got ", ncol(AnnoProvided), ".")
  }
  colnames(AnnoProvided)[1:4]<-c("molecule","type","start","end")

  if (is.null(referenceName)) {
    referenceName<-AnnoProvided$molecule[1]
  } else if (!referenceName %in% AnnoProvided$molecule) {
    stop("referenceName '", referenceName, "' not found in AnnoFilePath; available molecules: ",
         paste(unique(AnnoProvided$molecule), collapse = ", "))
  }
  RegionTable<-AnnoProvided[AnnoProvided$molecule == referenceName, , drop = FALSE]

  PosIndex<-as.numeric(gsub("[^0-9]", "", as.character(PositionStats$Position)))

  out<-do.call(rbind, lapply(seq_len(nrow(RegionTable)), function(i) {
    from<-min(RegionTable$start[i], RegionTable$end[i])
    to<-max(RegionTable$start[i], RegionTable$end[i])
    inRegion<-PositionStats[PosIndex >= from & PosIndex <= to, , drop = FALSE]
    VariableSites<-sum(inRegion$Conservation < 1, na.rm = TRUE)
    hasPositions<-nrow(inRegion) > 0
    data.frame(
      Type = RegionTable$type[i],
      Start = from,
      End = to,
      NumPositions = nrow(inRegion),
      MeanConservation = if (hasPositions) mean(inRegion$Conservation, na.rm = TRUE) else NA_real_,
      MeanMissingFrac = if (hasPositions) mean(inRegion$MissingFrac, na.rm = TRUE) else NA_real_,
      VariableSites = VariableSites,
      VariantRate = if (hasPositions) VariableSites / nrow(inRegion) else NA_real_
    )
  }))
  rownames(out)<-NULL
  out
}

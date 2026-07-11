#' Plot per-position conservation as a track along the alignment
#'
#' @param PositionStats output of \code{\link{positionConservation}}
#' @param colors a length-2 vector \code{c(line, fill)} (default: the package's sequential
#' blue ramp)
#' @param title plot title
#' @return a \code{ggplot} object
#' @export
#' @import ggplot2
plotConservationTrack<-function(PositionStats, colors = NULL, title = "Per-position conservation")
{
  if (!all(c("Position","Conservation") %in% colnames(PositionStats))) {
    stop("PositionStats must be the output of positionConservation() (needs Position, Conservation columns).")
  }
  if (is.null(colors)) {
    colors<-c(line = .alignstatplotSequential[4], fill = .alignstatplotSequential[2])
  } else if (length(colors) == 1) {
    colors<-c(line = unname(colors[1]), fill = unname(colors[1]))
  } else {
    colors<-c(line = unname(colors[1]), fill = unname(colors[2]))
  }
  PositionStats$PositionIndex<-as.numeric(gsub("[^0-9]", "", as.character(PositionStats$Position)))

  ggplot(PositionStats, aes(x = .data$PositionIndex, y = .data$Conservation)) +
    geom_area(fill = colors[["fill"]], alpha = 0.5) +
    geom_line(colour = colors[["line"]], linewidth = 0.4) +
    scale_y_continuous(limits = c(0, 1)) +
    labs(x = "Alignment position", y = "Conservation (majority-allele fraction)", title = title) +
    theme_alignstatplot()
}

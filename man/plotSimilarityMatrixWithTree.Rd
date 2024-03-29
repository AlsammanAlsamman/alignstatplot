% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotSimilarityMatrixWithTree.R
\name{plotSimilarityMatrixWithTree}
\alias{plotSimilarityMatrixWithTree}
\title{Plot distance matrix and phylogenetic tree in the same figure as heatmap}
\usage{
plotSimilarityMatrixWithTree(
  seqInfo,
  seqAlignment,
  plotTree = TRUE,
  plotDisMatrix = TRUE
)
}
\arguments{
\item{seqInfo}{table of sequence information generated using \code{\link{getSeqInfo}}}

\item{seqAlignment}{sequence alignment object}

\item{plotTree}{logical plot phyolgenetic tree}

\item{plotDisMatrix}{logical plot heatmap of distance matrix}
}
\value{
Tree and Heatmap plots
}
\description{
Plot distance matrix and phylogenetic tree in the same figure as heatmap
}

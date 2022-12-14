% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/seqRemoveAmbiguous.R
\name{seqRemoveAmbiguous}
\alias{seqRemoveAmbiguous}
\title{Replace ambiguous nucleotides}
\usage{
seqRemoveAmbiguous(fileNameInput, fileNameOut = "", LowerToUpper = T)
}
\arguments{
\item{fileNameInput}{path of fasta sequence input}

\item{fileNameOut}{path of fasta sequence output}

\item{LowerToUpper}{logiocal if upper to lower format ios needed}
}
\value{
sequence file
}
\description{
Ambiguous nucleotide will be replaced and lower to upper case conversion
}

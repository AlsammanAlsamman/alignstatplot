#' Formatting numbers as a percentage
#'
#' @param x value
#' @param digits number of digits
#' @param format formatting
#' @param ... ...
#' @return Percent ion format
#' @export
percentFormat <- function(x, digits = 2, format = "f", ...) {
  paste0(formatC(100 * x, format = format, digits = digits, ...), "%")
}

#' Sequence alignment statistics table per sequence
#'
#' @param SeqAligned  list of aligned vectors contains aligned sequences using \code{\link{alignment2Fasta}}
#' @param SeqInfo table of sequence information generated using \code{\link{getSeqInfo}}
#' @return Table
#' @import stringr
#' @export
AlignmentStatsPerSeq<-function(SeqInfo,SeqAligned)
{

  Nlist<-c("A","T","C","G")
  alignmentStats<-data.frame(SeqNo=c(0),
                             Sequence.Name=c(""),
                             Sequence.Length=c(0),
                             "A"=c(0),
                             "T"=c(0),
                             "C"=c(0),
                             "G"=c(0),
                             "Gap"=c(0),
                             "Gap.Percentage"=c(0),
                             "GC"=c(0),
                             "GC.Percentage"=c(0))

  for (seq in 1:length(SeqAligned)) {
    alignmentStats[seq,"SeqNo"]<-seq
    alignmentStats[seq,"Sequence.Name"]<-SeqInfo[seq,]$Name
    thisseq<-paste0(SeqAligned[[seq]],sep="",collapse = "")
    alignmentStats[seq,"Gap"]<-str_count(thisseq, "-")
    for (c in Nlist) {
      alignmentStats[seq,c]<-str_count(thisseq, c)
    }
  }

  #Sequence Length
  alignmentStats$Sequence.Length<-alignmentStats$A+
    alignmentStats$T+
    alignmentStats$C+
    alignmentStats$G
  #GC Content
  alignmentStats$GC<-alignmentStats$G+alignmentStats$C
  #GC Percentage
  alignmentStats$GC.Percentage<-percentFormat((alignmentStats$GC/alignmentStats$Sequence.Length))
  ### Gap Percentage to the consensus
  Conslength<-length(SeqAligned[[1]])
  alignmentStats$Gap.Percentage<-percentFormat((alignmentStats$Gap/Conslength))
  alignmentStats
}



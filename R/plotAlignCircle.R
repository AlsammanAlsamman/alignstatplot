#' Plot Sequence Alignment as circle plot
#' @param path Sequence alignment Fasta path
#' @param SeqFormat fasta clustalw
#' @param SeqFontSize sequence labels font size
#' @param colors sector colors, one per sequence (default: \code{\link{getSeqColors}})
#' @return  plot
#' @export
#' @import seqinr
plotAlignCircle<-function(path,SeqFormat="fasta",SeqFontSize=1,colors=NULL)
{
    Seq<-""
    AlignedSeqInfo<-""
    if (SeqFormat=="fasta") {
      # read fasta file into list of vectors
      Seq<-read.fasta(path)
      AlignedSeqInfo<-data.frame(Name=names(Seq),
                                 Length=as.vector(unlist(lapply(Seq, AlignedTrueLenght))))
    }
    if (SeqFormat=="clustalw") {
      clustal.res <- read.alignment(file = path,
                                    format="clustal")
      Seq<-lapply(clustal.res$seq, AlignSplit)
      AlignedSeqInfo<-
        data.frame(Name=clustal.res$nam,
                   Length=as.vector(unlist(lapply(Seq, AlignedTrueLenght))))
    }
    Seq<-as.vector(Seq)
    if (nrow(AlignedSeqInfo)<=15) {
      drawConsWithGenes(AlignedSeqInfo,Seq,colors=colors)
    }else{
      drawConsWithNoGenes(AlignedSeqInfo,Seq,cex.SeqLabels = SeqFontSize,colors=colors)
    }
}

#' Aligned sequence true length without gaps
#' @return length
#' @param seq vector of chars
#' @export
AlignedTrueLenght<-function(seq)
{
  len<-0
  for (n in seq) {
    if (n!="-") {
      len<-len+1
    }
  }
  len
}

#' Split sequence alignment object
#' @param seq a single aligned sequence, as a character string
#' @import stringr
#' @return character vector of the sequence split into individual bases
AlignSplit<-function(seq)
{
  as.vector(str_split_fixed(as.vector(seq), pattern = "", n = nchar(seq)))
}


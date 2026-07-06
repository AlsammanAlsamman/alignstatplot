#' Replace ambiguous nucleotides
#' @description Ambiguous nucleotide will be replaced and lower to upper case conversion
#' @param fileNameInput path of fasta sequence input
#' @param fileNameOut path of fasta sequence output
#' @param LowerToUpper logiocal if upper to lower format ios needed
#' @return sequence file
#' @export
seqRemoveAmbiguous<-function(fileNameInput,fileNameOut="",LowerToUpper=T)
{
  if (!is.character(fileNameInput) || length(fileNameInput) != 1 || !file.exists(fileNameInput)) {
    stop("fileNameInput must be a path to an existing fasta file; got: ", paste(fileNameInput, collapse = ", "))
  }
  if (fileNameOut=="") {
    fileNameOut=paste0(tempdir(),"/input.fasta")
  }
  conn <- file(fileNameInput,open="r")
  linn <-readLines(conn,warn=FALSE)
  AmbNuc <- c("R","Y","S","W","K","M","B","D","H","V","N")
  NiceNuc<-c("A","T","C","A","G","C","T","G","A","A","T")
  Pattern = paste(AmbNuc, collapse="|")
  if (LowerToUpper) {
    #To Uppercase
    for (i in 1:length(linn)){
      if (grepl(">",linn[i], fixed = TRUE)) {next}
      linn[i]<-toupper(linn[i])
    }
  }
  close(conn)
  #Replace Ambiguous Nucleotides
  for (i in 1:length(linn)){
    if (grepl(">",linn[i], fixed = TRUE)) {next}
    if (!grepl(Pattern,linn[i])) {next}
    strvect<-strsplit(linn[i],"")[[1]]
    matched<-strvect %in% AmbNuc
    strvect[matched]<-setNames(NiceNuc, AmbNuc)[strvect[matched]]
    linn[i]<-paste(as.vector(unname(strvect)),collapse = "")
  }
  #Print to file
  #Check its existence
  if (file.exists(fileNameOut)) {
    #Delete file if it exists
    file.remove(fileNameOut)
  }
  for (i in 1:length(linn)){
    write(linn[i],fileNameOut,append=TRUE)
  }
  fileNameOut
}

#Sequences colors
#' get sequences colors
#' @param ColorsN number of colors
#' @return character
#' @export
#' @importFrom RColorBrewer brewer.pal
#' @examples
#' getSectorColors(10)
getSeqColors<-function(ColorsN){
  SectorColors<-c()
  if (ColorsN<=8) {
    SectorColors<-brewer.pal(n = ColorsN, name = "Dark2") #color lists are
  }
  if (ColorsN<=22) {
    SectorColors<-as.vector(pals::kelly())
  }
  if (ColorsN<=26) {
    SectorColors<-as.vector(pals::alphabet())
  }
  if (ColorsN<=36) {
    SectorColors<-as.vector(pals::polychrome())
  }
  if (ColorsN>=37) {
    #More than 30
    qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
    col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
    SectorColors<-sample(1:length(col_vector), ColorsN, replace=TRUE)
    SectorColors<-col_vector[SectorColors]
  }
  SectorColors
}

#Sequences colors
# Fixed palettes below are literal copies of pals::kelly()/alphabet()/polychrome()
# (as.vector, names stripped) - not generated, so hardcoding them drops the pals
# dependency with zero behavior change.
.kellyColors <- c("#F2F3F4", "#222222", "#F3C300", "#875692", "#F38400", "#A1CAF1",
"#BE0032", "#C2B280", "#848482", "#008856", "#E68FAC", "#0067A5",
"#F99379", "#604E97", "#F6A600", "#B3446C", "#DCD300", "#882D17",
"#8DB600", "#654522", "#E25822", "#2B3D26")
.alphabetColors <- c("#F0A0FF", "#0075DC", "#993F00", "#4C005C", "#191919", "#005C31",
"#2BCE48", "#FFCC99", "#808080", "#94FFB5", "#8F7C00", "#9DCC00",
"#C20088", "#003380", "#FFA405", "#FFA8BB", "#426600", "#FF0010",
"#5EF1F2", "#00998F", "#E0FF66", "#740AFF", "#990000", "#FFFF80",
"#FFE100", "#FF5005")
.polychromeColors <- c("#5A5156", "#E4E1E3", "#F6222E", "#FE00FA", "#16FF32", "#3283FE",
"#FEAF16", "#B00068", "#1CFFCE", "#90AD1C", "#2ED9FF", "#DEA0FD",
"#AA0DFE", "#F8A19F", "#325A9B", "#C4451C", "#1C8356", "#85660D",
"#B10DA1", "#FBE426", "#1CBE4F", "#FA0087", "#FC1CBF", "#F7E1A0",
"#C075A6", "#782AB6", "#AAF400", "#BDCDFF", "#822E1C", "#B5EFB5",
"#7ED7D1", "#1C7F93", "#D85FF7", "#683B79", "#66B0FF", "#3B00FB")

#' get sequences colors
#' @param ColorsN number of colors
#' @return character
#' @export
#' @importFrom RColorBrewer brewer.pal
#' @examples
#' getSeqColors(10)
getSeqColors<-function(ColorsN){
  SectorColors<-c()
  if (ColorsN<=8) {
    SectorColors<-brewer.pal(n = ColorsN, name = "Dark2") #color lists are
  }
  if (ColorsN<=22) {
    SectorColors<-.kellyColors
  }
  if (ColorsN<=26) {
    SectorColors<-.alphabetColors
  }
  if (ColorsN<=36) {
    SectorColors<-.polychromeColors
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

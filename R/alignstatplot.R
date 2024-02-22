#' Perform all analysis as a pipeline
#'
#' @param SeqFile Fasta File path
#' @param AlignMethod (optional) Alignment tool that will be used. "ClustalW", "ClustalOmega", and "Muscle" are supported
#' @param AnnoFile Annotation file
#' @param OutFolder (optional) Output folder name
#' @param MaxMissPer (optional) Maximum Missing in SNPs to remove
#' @param MaxCluster (optional) Maximum number of SNP cluster to report
#' @param MinimumClusterLength (optional) Minimum Nucleotides in one cluster to be reported
#' @param Verbose (optional) verbose
#' @return plots
#' @import ggtree
#' @import phytools
#' @import ggplot2
#' @export

alignstatplot<-function(SeqFile,AlignMethod="ClustalW",AnnoFile="",OutFolder="output",MaxMissPer=0.2,
                        MaxCluster = 4,MinimumClusterLength = 3,Verbose=T, fontscale = 0)
{
  if (Verbose==T) print(paste("Create Output Folder ",OutFolder))
  dir.create(file.path(OutFolder), showWarnings = FALSE)
  if (Verbose==T) print(paste("Perform Sequence Alignment using ",AlignMethod))
  myClustalWAlignment <- seqAlign(SeqFile,AlignMethod)
  #extract sequence information
  SeqInfo<-getSeqInfo(SeqFile)
  
  Seqn<-nrow(SeqInfo)
  
  # calculate the font size for the sequence alignment plot if 
  if (Seqn>30 and Seqn<50 and fontscale==0) {
    fontscale = 0.5
  }
  else if (Seqn>50 and Seqn<100 and fontscale==0) {
    fontscale = 0.3
  }
  else if (Seqn>100 and fontscale==0) {
    fontscale = 0.1
  }

  #Convert sequence to list
  SeqAligned<-alignment2Fasta(myClustalWAlignment,SeqInfo)
  if (Verbose==T) print(paste("Save Alignment as Fasta "))
  alignment2Fasta(myClustalWAlignment,SeqInfo,paste(OutFolder,"Alignment.fasta",sep = "/"))
  if (Verbose==T) print(paste("Save Alignment statistics"))
  StatsTable<-AlignmentStatsPerSeq(SeqInfo,SeqAligned)
  write.table(StatsTable,paste0(OutFolder,"/Alignment_Stats.tsv"),sep="\t")
  if (Verbose==T) print(paste("Alignment Plotting"))

  #Sequence Alignment plots
  #Plot Sequence alignment with consensus and links
  if (Seqn<15) {
    if (Verbose==T) print(paste("Plot Sequence alignment with consensus and links"))
    pdf(paste0(OutFolder,"/","SeqAlignmentCircleWithLinks.pdf"))
    drawConsWithGenes(SeqInfo,SeqAligned)
    dev.off()
  }

  if (Verbose==T) print(paste("Plot Sequence alignment with consensus and No links"))
  #Plot Sequence alignment with consensus and No links
  pdf(paste0(OutFolder,"/","SeqAlignmentCircleWithNoLinks.pdf"),width = 15,height = 15)
  drawConsWithNoGenes(SeqInfo,SeqAligned,cex.SeqLabels = fontscale)
  dev.off()

  if (Verbose==T) print(paste("Phylogenetic trees analysis"))
  if (Verbose==T) print(paste("Calculate Distance Table"))
  DistTable<-getDistanceMatrixTabel(SeqInfo,myClustalWAlignment)
  if (Verbose==T) print(paste("Save Distance Table"))
  write.table(DistTable,paste0(OutFolder,"/Distance_Table.tsv"),sep="\t")
  if (Verbose==T) print(paste("Calculate Phylogenetic Tree"))
  myTree<-getTree(DistTable)

  if (Verbose==T) print(paste("Save Phylogenetic Tree as Text"))
  writeNexus(myTree,paste0(OutFolder,"/Tree.nexus"))

  if (Verbose==T) print(paste("Save Tree Summary"))
  sink(file=paste0(OutFolder,"/TreeSummary.txt"))
  summary(myTree)
  sink()

  if (Verbose==T) print(paste("Plot similarity distance matrix"))
  ## Similarity distance matrix
  pdf(paste0(OutFolder,"/","Distance_Matrix.pdf"),width = 15 + nrow(SeqInfo)/5,height = 15 + nrow(SeqInfo)/5)
  distanceHeatmap(DistTable,fontsizescale = fontscale)
  dev.off()

  if (Verbose==T) print(paste("Phylogenetic tree simple plot"))
  pdf(paste0(OutFolder,"/","Tree.pdf"),width = 7,height = 10)
  plotTreeWithRuler(SeqInfo,myClustalWAlignment)
  dev.off()

  if (AnnoFile!="") {
    if (Verbose==T) print(paste("Phylogenetic tree with genes"))
    plotTreeWithGenes(SeqInfo,myClustalWAlignment,AnnoFile)
    ggsave(paste0(OutFolder,"/","Tree_With_Genes.pdf"),width = 10,height = nrow(SeqInfo)/5)
  }

  if (Verbose==T) print(paste("Tree and similarity matrix"))
  pdf(paste0(OutFolder,"/","Tree_With_Similarity_Matrix.pdf"),width = 10,height = 10)
  plotSimilarityMatrixWithTree(SeqInfo,myClustalWAlignment)
  dev.off()

  if (Verbose==T) print(paste("Calculate Nucleotide Frequency"))
  # Sequence alignment visualization plots
  #Convert alignment To Table
  SeqAlignedTable<-alignment2Table(SeqInfo,SeqAligned)

  #Filter Table for missing and Mono
  SeqAlignedTableFiltered<-nucTableFilter(SeqAlignedTable,
                                          MaxMissPer = MaxMissPer,
                                          removeMono = T)

  if (Verbose==T) print(paste("Save Nucleotide Frequency"))
  #Calculate Frequency
  NucCount<-nucFrequency(SeqAlignedTableFiltered)
  write.table(t(NucCount),paste0(OutFolder,"/NucCount_Frequency.tsv"),sep="\t")

  ## plot sequence alignment statistics
  ### Frequency heatmap
  if (Verbose==T) print(paste("Genes PCA using Alignment"))
  p<-plotPCA(SeqInfo,myClustalWAlignment)
  ggsave(plot=p,paste0(OutFolder,"/","Genes_PCA.pdf"),device = "pdf",
         width = 10, height = 8, dpi = 150, units = "in")

  #plot sample
  if (Verbose==T) print(paste("Plot Nucleotide Frequency ... Does not work for very long sequences"))
  p<-nucTableHeatmap(SeqAlignedTableFiltered,cex.NucLabels = 0.1)
  ggsave(plot=p,paste0(OutFolder,"/","Nucleotide HeatMap Frequency.pdf"),device = "pdf",
         width = 15, height = 8, dpi = 150, units = "in")

  p<-nucTableHeatmap(SeqAlignedTableFiltered[,1:100])
  ggsave(plot=p,paste0(OutFolder,"/","Nucleotide HeatMap Frequency _ SmallRegion1:100.pdf"),device = "pdf",
         width = 15, height = 8, dpi = 150, units = "in")

  ### Frequency plot
  if (Verbose==T) print(paste("Plot Nucleotide Frequency Chart "))
  ggsave(plot=p,paste0(OutFolder,"/","Nucleotide Frequency Chart.pdf"),device = "pdf",
         width = 15, height = 8, dpi = 150, units = "in")

  ### Frequency and heat-plot
  #plot First 50 nucleotide variations
  if (Verbose==T) print(paste("Frequency and heat-plot "))
  p<-nucTableFreqHeatmap(SeqAlignedTableFiltered[,1:100])
  ggsave(plot=p,paste0(OutFolder,"/","Frequency and heat-plot_First100.pdf"),device = "pdf",
         width = 15, height = 8, dpi = 150, units = "in")

  if (Verbose==T) print(paste("Creating Folder for Frequency and heat-plots"))
  #If the sequence is very long it can be split and saved to a folder
  dir.create(file.path(paste(OutFolder,"HeatMap_Freq",sep="/")), showWarnings = FALSE)
  # If The sequence was very long this can be used
  PlotList<-nucTableFreqHeatmapSplit(SeqAlignedTableFiltered,100)
  outPdfDir<-paste(OutFolder,"/","HeatMap_Freq","/",sep="")
  # #Save Plots
  saveSeqPlotList(PlotList,outPdfDir)

  # Alignment nucleotide frequency logoplot
  if (Verbose==T) print(paste("Creating Alignment nucleotide frequency logoplots"))
  #Plot Sequence Logos for nucleotide Frequency
  SplitLen<-60
  NumberOfpLots<-length(SeqAligned[[1]])/SplitLen
  if (NumberOfpLots>10) {
    dir.create(file.path(paste(OutFolder,"LogoPLots",sep="/")), showWarnings = FALSE)
    drawSeqLogo(SeqAligned,SplitLen,outFolder = paste(OutFolder,"LogoPLots",sep="/"),joinPlot = F,width = 15,height = 5)
  }else
  {
    drawSeqLogo(SeqAligned,SplitLen)
    ggplot2::ggsave(paste0(OutFolder,"/NucLogo.pdf"),height = 30,width = 15)
  }

  #Draw Sequences nucleotide percent in logo format in one file
  if (Verbose==T) print(paste("Converting data to binary format"))
  # Using Non-reference conversion
  #The fisrt step will be to remove non-biallailic variations (tri-, tetra-, ..) and assign 0 or 1 for alleles. This is the default way for data conversion.
  if (Verbose==T) print(paste("Remvoing biallelic Nucleotides"))
  biallelicNuc<-getBiallelicByFreq(NucCount)

  #Create a reference genotype.
  GenotypeRef<-getRefGenotypeForbiallelic(NucCount,biallelicNuc)
  #Convert data using this genotype as a reference
  SeqBinaryTableByFreqRef<-seqTableToBinary(SeqAlignedTableFiltered,GenotypeRef,RemoveNonRefNuc = T,RefsNames = F)

  if (Verbose==T) print(paste("SNP Clustering"))
  #Nucleotide variation clustering is a PCA-based analysis that clusters SNP data across genes. It aids in identifying the variation that occurs across genes, where some alleles tend to appear together.
  ## clustering
  #Allele Based Variations
  Cluster<-SNPCluster(SeqAlignedTableFiltered)
  if (Verbose==T) print(paste("SNP Clustering Plotting"))
  pdf(paste0(OutFolder,"/","ClusterTree3D.pdf"),width = 10,height = 10)
  SNPClusterPlot3DTree(Cluster,60)
  dev.off()

  #Problem
  if (Verbose==T) print(paste("SNP Clustering PCA"))
  p<-SNPClusterPlotPCAMap(Cluster)
  ggsave(plot=p,paste0(OutFolder,"/","ClusterPCA.pdf"),device = "pdf",
         width = 15, height = 8, dpi = 150, units = "in")

  if (Verbose==T) print(paste("SNP Clustering On Genes"))
  p<-SNPClusterPlot(SeqInfo,SeqAligned,Cluster,MaxCluster = MaxCluster,MinimumClusterLength = MinimumClusterLength)
  ggsave(plot=p,paste0(OutFolder,"/","SNPClusterGenes.pdf"),device = "pdf",
         width = 15, height = 8, dpi = 150, units = "in")

  p<-SNPClusterPlotWithTree(SeqInfo,myClustalWAlignment,Cluster,MaxCluster = MaxCluster, MinimumClusterLength = MinimumClusterLength)
  ggsave(plot=p,paste0(OutFolder,"/","SNPClusterGenes_Tree.pdf"),device = "pdf",
          width = 15, height = 8, dpi = 150, units = "in")

  print(paste("All analyses were completed successfully and saved to a folder:" ,OutFolder))
}

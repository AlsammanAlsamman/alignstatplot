.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "Please cite alignstatplot in published work:\n",
    "  Alsamman, A.M., El Allali, A., Mokhtar, M.M., Al-Sham'aa, K., Nassar, A.E., Mousa, K.H. and\n",
    "  Kehel, Z., 2023. AlignStatPlot: An R package and online tool for robust sequence alignment\n",
    "  statistics and innovative visualization of big data. PLoS ONE, 18(9), p.e0291204.\n",
    "  https://doi.org/10.1371/journal.pone.0291204\n",
    "Run citation(\"alignstatplot\") for a BibTeX entry."
  )
}

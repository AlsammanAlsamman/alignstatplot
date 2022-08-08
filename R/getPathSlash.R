#' Format Folder Path according to operating system
#'
#' @param Folder Folder Path
#'
#' @return Slash
#' @export
formatFolderPath<-function(Folder)
{
  slash="/"
  SystemType<-get_os()
  if (SystemType=="windows") {
    slash="\\"
  }

  FoLast<-unlist(strsplit(Folder,split = ""))[nchar(Folder)]
  if (FoLast!=slash) {
    Folder<-paste0(Folder,slash)
  }
  Folder
}
#' Get OS Type
#'
#' @return windows linux or osx
#' @export
get_os <- function(){
  sysinf <- Sys.info()
  if (!is.null(sysinf)){
    os <- sysinf['sysname']
    if (os == 'Darwin')
      os <- "osx"
  } else { ## mystery machine
    os <- .Platform$OS.type
    if (grepl("^darwin", R.version$os))
      os <- "osx"
    if (grepl("linux-gnu", R.version$os))
      os <- "linux"
  }
  tolower(os)
}

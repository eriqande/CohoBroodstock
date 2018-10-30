

#' read in a two-column formatted genotype file and turn it into something KINSHIP can read
#'
#' Nothing very cool about this.  Just some formatting.  It will read a file in and then
#' create a new file in the same spot as the other one with "_kinship_input" appended to it.
#'
#' Note that some of the files I have gotten from Libby have empty columns on the end (probably
#' a microsoft excel thing.)  So, I will drop any columns that start with X followed by a number.
#'
#' @param TCF path to the two-column formatted file
#' @param outdir name of output directory to write the kinship file to.  If this is left unspecified
#' (or is passed in as NULL), then the output directory is the same as that of the input two-column
#' genotype file.
#' @return Invisibly returns the data frame formatted for Kinship.  But, also writes the thing
#' out, so typically you won't use the return value.
#' @export
#' @examples
#' # get path to example file in package directory
#' tcffile <- system.file("extdata", "WSH_W1718_v5_two_column_data.txt", package = "CohoBroodstock")
#'
#' # print it to see what that looks like:
#' tcffile
#'
#' # now make a Kinship input version in the current directory
#' two_column2kinship(tcffile, outdir = ".")
#'
#' # Note that when you do this you will get a few error messages:
#' # 1. missing column names filled in --- This is because the input file has two
#' # empty columns in it (i.e., it has the tabs but no content).
#' # 2. The two column names for each locus are the same and they get deduplicated.
#' # 3. See #1.
#'
two_column2kinship <- function(TCF, outdir = NULL) {

  outf <- paste0(TCF, "_kinship_input")
  if(!is.null(outdir)) {
    outf <- file.path(outdir, basename(TCF))
  }
  DF <- readr::read_tsv(TCF)

  droppers <- stringr::str_detect(names(DF), "X[1-9][0-9]*")

  if(sum(droppers) > 0) {
    warning("Dropping ", sum(droppers), " columns that had no column names.")
  }

  # drop empty columns
  DF2 <- DF[, !droppers]

  # turn 0's into nothings
  DF2[DF2 == 0] <- ""

  DL <- as.list(DF2)
  # now cycle over the columns and make the slash-separated
  listy <- lapply(seq(3, length(DL), by = 2), function(i) {
    paste(as.character(DL[[i-1]]), as.character(DL[[i]]), sep = "/")
  })
  names(listy) <- names(DL)[seq(3, length(DL), by = 2) - 1]

  listy2 <- c(DF2[1], listy)

  df3 <- tibble::as_data_frame(listy2)
  names(df3)[1] <- "Indiv_ID"

  # now just write it out
  readr::write_tsv(df3, path = outf)

  message("Printed kinship output file to: ", outf)
}

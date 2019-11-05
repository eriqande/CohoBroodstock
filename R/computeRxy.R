
#' compute Rxy from a simple 2-column formatted file
#'
#' This reads the file, strips off the first row (the column
#' headers) and then writes it back out to a temporary file.
#' Then reads it and does computations with the "related" package
#' @param file path to the two-column formatted file.  0 is used to
#' denote missing data.
#' @export
#' @examples
#' file <- system.file("extdata",
#'                     "WSH_W1718_v5_two_column_data.txt.gz",
#'                     package = "CohoBroodstock")
#' rxy <- computeRxy(file)
#'
#' # here is one that uses a file that has some loci that must be dropped
#' file2 <- system.file("extdata",
#'                     "IGH_W1920_v1_norefs.txt.gz",
#'                     package = "CohoBroodstock")
#' rxy <- computeRxy(file2)

computeRxy <- function(file) {
  # read in the lines and then print them back after removing the first
  X <- read.table(file, stringsAsFactors = FALSE, header = TRUE)

  # if any columns are all NA (happens with microsoft excel-saved files, I think)
  # then remove them.
  X <- X[!sapply(X, function(x) all(is.na(x)))]

  # now, it turns out that any loci that have nothing by missing data at them
  # must be removed, or related will bomb on it.  So, we do some quick machinations to
  # find those.  Recall that 0 means missing data.
  # first, get the data in single column format
  xm <- matrix(as.matrix(X[,-1]), ncol = (ncol(X) - 1) / 2)
  # then figure out which loci have only a single observed allele
  bad_hombres <- which(apply(xm, 2, function(col) {
    all(col == 0)
  }))
  if(length(bad_hombres) > 0) {
    # figure out which indexes in X to drop:
    drop_these <- rep(2 * bad_hombres, each = 2) + c(0, 1)
    X <- X[, -drop_these]
  }



  tmpf <- tempfile()
  readr::write_tsv(X, tmpf, col_names = FALSE)

  dat <- related::readgenotypedata(tmpf)

  # it appears that the program can't deal with slashes in the ID names
  new_names <- tibble::tibble(real_name = dat$gdata$V1, simple_name = paste0("DD", sprintf(1:nrow(dat$gdata), fmt = "%04d")))
  dat$gdata$V1 <- new_names$simple_name

  rel <- related::coancestry(dat$gdata, quellergt=1)

  # then put those names back in there:
  nn1 <- new_names %>% dplyr::rename(ind1 = real_name, ind1.id = simple_name)
  nn2 <- new_names %>% dplyr::rename(ind2 = real_name, ind2.id = simple_name)


  # print a message if loci were dropped
  # and print a message
  if(length(bad_hombres) > 0) {
    message("Dropped these loci b/c they were all missing data: ", paste(names(X)[bad_hombres * 2], collapse = ", "), ".")
  }

  ret <- tibble::as_tibble(rel$relatedness) %>%
    dplyr::select(ind1.id, ind2.id, quellergt) %>%
    dplyr::left_join(nn1, by = "ind1.id") %>%
    dplyr::left_join(nn2, by = "ind2.id") %>%
    dplyr::select(ind1, ind2, quellergt)

  ret
}

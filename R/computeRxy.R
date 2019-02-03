
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
computeRxy <- function(file) {
  # read in the lines and then print them back after removing the first
  X <- read.table(file, stringsAsFactors = FALSE, header = TRUE)

  # if any columns are all NA (happens with microsoft excel-saved files, I think)
  # then remove them.
  X <- X[!sapply(X, function(x) all(is.na(x)))]

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

  ret <- tibble::as_tibble(rel$relatedness) %>%
    dplyr::select(ind1.id, ind2.id, quellergt) %>%
    dplyr::left_join(nn1, by = "ind1.id") %>%
    dplyr::left_join(nn2, by = "ind2.id") %>%
    dplyr::select(ind1, ind2, quellergt)

  ret
}

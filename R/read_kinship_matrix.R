

#' read a tab-delimited kinship matrix into a tidy tibble of rxy values
#'
#' It has to be the full symmetric matrix.  Can't be the lower half. Males have
#' to be named "MXXX" and females "FXXX" where XXX are some numbers or
#' characters or whatever.  The main thing is that females have to start
#' with an F and males with an M.
#' @param path path to the file
#' @param skip number of lines to skip in the beginning
#' This forces the first column to be a female and the second a male.
#' So, our null distribution will be between males and females (not
#' between females and females, for exmample).
#' @examples
#' kfile <- system.file("extdata/IGH_W1718_master_Kinsh_res.txt.gz", package = "CohoBroodstock")
#' @export
read_kinship_matrix <- function(path, skip = 8) {
  readr::read_tsv(path, skip = skip, na = "*", skip_empty_rows = FALSE) %>%
    tidyr::gather(key = "X2", value = "rxy", -X1) %>%
    dplyr::mutate(rxy = as.numeric(rxy)) %>%
    dplyr::filter(!is.na(rxy)) %>%
    dplyr::filter(stringr::str_detect(X1, "^F") & stringr::str_detect(X2, "^M")) %>%
    dplyr::rename(Female = X1, Male = X2)
}


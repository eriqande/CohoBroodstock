#' Clean up ComputeRxy() output in order to use in aor_pairs
#'
#' ComputeRxy() returns an rxy value for every single pair in the data
#' set, but when we compare Actual, to Optimal, to Random rxys
#' we want to only focus on the Males and Females denoted by a leading "F"
#' or "M" in their names, respectively.  This function filters things
#' down to just those individuals, and then also makes a column Female and
#' a Column Male and another called rxy.  This might be necessary for a number of
#' different things like creating spawning matrices.
#' @param D a tibble holding the output of \code{\link{ComputeRxy}()}. This should be
#' a tibble with columns named \code{ind1}, \code{ind2}, and \code{quellergt}
#' @export
clean_computeRxy_output <- function(D) {
  D %>%
    dplyr::filter( (str_detect(ind1, "^F") & str_detect(ind2, "^M")) |
              (str_detect(ind1, "^M") & str_detect(ind2, "^F"))
    ) %>%
    dplyr::mutate(Female = ifelse(str_detect(ind1, "^F"), ind1, ind2),
           Male = ifelse(str_detect(ind1, "^M"), ind1, ind2)
           ) %>%
    dplyr::rename(rxy = quellergt) %>%
    select(Female, Male, rxy)
}

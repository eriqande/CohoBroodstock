

#' deliver the rxy values for the actual, optimal, and random pairs
#'
#' @param SP two column tibble with columns Female and Male giving the actual spawn pairs
#' @param Rxy the Rxy matrix in tidy format. (The output of \code{\link{read_kinship_matrix}}).
#' @export
aor_pairs <- function(SP, Rxy) {

  # check for errors
  check_sp_rxy_ids(SP, Rxy)

  # first get the actual rxys for the spawn pairs
  actual <- dplyr::left_join(SP, Rxy, by = c("Female", "Male")) %>%
    dplyr::group_by(Female) %>%
    dplyr::mutate(idx = 1:(dplyr::n())) %>%
    dplyr::ungroup()

  # get the number of males mated to each female
  nums <- actual %>%
    dplyr::count(Female) %>%
    dplyr::rename(num = n)

  # now get a data frame for getting the optimals
  opts <- dplyr::left_join(nums, Rxy, by = "Female") %>%
    dplyr::group_by(Female) %>%
    dplyr::do(.data = ., dplyr::top_n(x = ., n = .$num[1], wt = -.$rxy)) %>%
    dplyr::mutate(idx = 1:(dplyr::n())) %>%
    dplyr::ungroup()

  # and now get another for the randoms
  randos <- dplyr::left_join(nums, Rxy, by = "Female") %>%
    dplyr::group_by(Female) %>%
    dplyr::do(.data = ., dplyr::sample_n(tbl = ., size = .$num[1])) %>%
    dplyr::mutate(idx = 1:(dplyr::n())) %>%
    dplyr::ungroup()


  # put them together into a single data frame
  list(actual = actual,
       optimal = opts,
       random = randos) %>%
    dplyr::bind_rows(.id = "pair_type") %>%
    dplyr::arrange(Female, pair_type, idx) %>%
    dplyr::select(Female, Male, pair_type, idx, pair_type, rxy)

}


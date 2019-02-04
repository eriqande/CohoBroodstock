#' arrange the rxy values and IDs into a matrix for spawning guidance purposes
#'
#' This will write out the matrix to two files, as well.  One for Libby and the other
#' for the hatchery (in which the Rxy values are not given)
#' @param Rxy_tidy a long-format (tidy, three columns) spawning matrix
#' like you would get out of compute Rxy.  Must be given if Rxy_path is not.
#' @param Rxy_path the path to the Rxy matrix. Must be given if Rxy_tidy is not.
#' @param rxy_cutoff  Any male with an Rxy value greater than this to a certain female will
#' have two asterices attached to its name so that the hatchery knows not to spawn him with this
#' female. Defaults to 0.1.
#' @param file_prefix Files will come out named file_prefix + spawn_matrix_full.csv and file_prefix + spawn_matrix.csv.
#' By default this is blank. You can use this to specify a path to use as well.  By default it comes out
#' in the current working directory.
#' @return Returns a list of the two matrices.  Typically not used so they are returned invisibly.
#' @export
#' @examples
#' Rxy_tidy <- computeRxy_example_output
#' spawning_matrix(Rxy_tidy)
spawning_matrix <- function(Rxy_tidy = NULL, Rxy_path = NULL, rxy_cutoff = 0.1, file_prefix = "") {

  if(!(xor(is.null(Rxy_path), is.null(Rxy_tidy)))) stop("You must supply exactly one of Rxy_tidy or Rxy_path, but not both")

  if(!is.null(Rxy_path)) {
    Rxy <- read_kinship_matrix(path = Rxy_path, skip = 6)  # note skip=6 is needed for readr1.2.1 that seems to have a bug in which it doesn't count empty lines before the header
  }
  if(!is.null(Rxy_tidy)) {
    Rxy <- prep_rxy_for_spawn_matrix(Rxy_tidy)
  }

  rsorted <- Rxy %>%
    dplyr::arrange(Female, rxy) %>%
    dplyr::mutate(aste = ifelse(rxy > rxy_cutoff, "**", ""),
                  Male_aste = paste0(aste, Male)) %>%
    dplyr::group_by(Female) %>%
    dplyr::mutate(rank = 1:n()) %>%
    dplyr::ungroup()

  # now, first make the matrix that has no Rxy values in it:
  for_hatch <- rsorted %>%
    dplyr::select(rank, Female, Male_aste) %>%
    tidyr::spread(key = Female, value = Male_aste)

  # now, make the one that does have the rxy values in it, but just
  # stuck in the same column as a string...
  for_libby <- rsorted %>%
    dplyr::mutate(mstr = paste0(Male_aste, " : ", rxy)) %>%
    dplyr::select(rank, Female, mstr) %>%
    tidyr::spread(key = Female, value = mstr)


  hatch_name <- paste0(file_prefix, "spawn_matrix.csv")
  lib_name <- paste0(file_prefix, "spawn_matrix_full.csv")

  readr::write_csv(for_hatch, path = hatch_name)
  readr::write_csv(for_libby, path = lib_name)

  invisible(list(for_libby = for_libby, for_hatch = for_hatch))
}

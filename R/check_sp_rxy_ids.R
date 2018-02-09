

#' check to make sure that all the spawn pair IDs occur in the rxys
#'
#' Makes sure that every female and male spawn pair have an rxy.
#' I will add other checks here as they come up as problems.
#' @param SP spawn pairs tibble
#' @param Rxy rxy matrix
#' @export
check_sp_rxy_ids <- function(SP, Rxy) {
  throw <- FALSE

  missers <- anti_join(SP, Rxy, by = c("Female", "Male"))

  if (nrow(missers) > 0) {
    message("Error: The following table shows spawn pairs not found in Rxy")
    print(missers)
    throw <- TRUE

    miss_fem <- setdiff(SP$Female, Rxy$Female)
    if (length(miss_fem) > 0)
      message("These females in SP, missing from Rxy: ", paste(miss_fem, collapse = ", "))

    miss_male <- setdiff(SP$Male, Rxy$Male)
    if (length(miss_male) > 0)
      message("These males in SP, missing from Rxy: ", paste(miss_male, collapse = ", "))

  }

  if (throw == TRUE) {
    stop("Fatal error.  Please fix your input errors...")
  }
  invisible("")
}

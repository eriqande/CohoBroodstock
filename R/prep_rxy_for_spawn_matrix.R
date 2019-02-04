

#' prepare output from computeRxy for use in the spawning matrix
#'
#' @param rxy the output from \code{\link{computeRxy}}.  Note that the IDs used for the
#' individuals in the data set that was fed into \code{\link{computeRxy}}
#' must start with F for females and M for males.
#' @export
#' @examples
#' input = computeRxy_example_output
#' prepped <- prep_rxy_for_spawn_matrix(input)
#' prepped
prep_rxy_for_spawn_matrix <- function(rxy) {
  # first, figure out which column has the male and which the female
  r2 <- rxy %>%
    mutate(   # get two columns saying who is what
      col1type = case_when(
        str_detect(ind1, "^F") ~ "F",
        str_detect(ind1, "^M") ~ "M"
      ),
      col2type = case_when(
        str_detect(ind2, "^F") ~ "F",
        str_detect(ind2, "^M") ~ "M"
      )
    )

  # now, give a warning if you are tossing any individuals
  tossers <- unique(
    c(
      r2 %>%
        filter(is.na(col1type)) %>%
        .$ind1,
      r2 %>%
        filter(is.na(col2type)) %>%
        .$ind2
    )
  )

  if(length(tossers) > 0) warning("These IDs not recognized as male or female and hence discarded: ",
                                  paste(tossers, collapse = ", "),
                                  "\nPlease add a leading M or F to them if required.")

  # now make a Female column and a Male column and select
  # them and rename them appropriately
  ret <- r2 %>%
        filter((!is.na(col1type) & !is.na(col2type)) & (
          (col1type == "M" & col2type == "F") |
            (col1type == "F" & col2type == "M")
        )) %>%
    mutate(
      Female = case_when(
        col1type == "F" ~ ind1,
        col2type == "F" ~ ind2
      ),
      Male = case_when(
        col1type == "M" ~ ind1,
        col2type == "M" ~ ind2
      )
    ) %>%
    rename(rxy = quellergt) %>%
    select(Female, Male, rxy)

  ret
}

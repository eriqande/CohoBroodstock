% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prep_rxy_for_spawn_matrix.R
\name{prep_rxy_for_spawn_matrix}
\alias{prep_rxy_for_spawn_matrix}
\title{prepare output from computeRxy for use in the spawning matrix}
\usage{
prep_rxy_for_spawn_matrix(rxy)
}
\arguments{
\item{rxy}{the output from \code{\link{computeRxy}}.  Note that the IDs used for the
individuals in the data set that was fed into \code{\link{computeRxy}}
must start with F for females and M for males.}
}
\description{
prepare output from computeRxy for use in the spawning matrix
}
\examples{
input = computeRxy_example_output
prepped <- prep_rxy_for_spawn_matrix(input)
prepped
}

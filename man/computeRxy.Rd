% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/computeRxy.R
\name{computeRxy}
\alias{computeRxy}
\title{compute Rxy from a simple 2-column formatted file}
\usage{
computeRxy(file)
}
\arguments{
\item{file}{path to the two-column formatted file.  0 is used to
denote missing data.}
}
\description{
This reads the file, strips off the first row (the column
headers) and then writes it back out to a temporary file.
Then reads it and does computations with the "related" package
}
\examples{
file <- system.file("extdata",
                    "WSH_W1718_v5_two_column_data.txt.gz",
                    package = "CohoBroodstock")
rxy <- computeRxy(file)

# here is one that uses a file that has some loci that must be dropped
file2 <- system.file("extdata",
                    "IGH_W1920_v1_norefs.txt.gz",
                    package = "CohoBroodstock")
rxy <- computeRxy(file2)
}

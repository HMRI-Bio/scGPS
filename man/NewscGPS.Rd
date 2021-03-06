% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/scgps_object.R
\name{NewscGPS}
\alias{NewscGPS}
\title{NewscGPS}
\usage{
NewscGPS(ExpressionMatrix = NULL, GeneMetadata = NULL,
  CellMetadata = NULL)
}
\arguments{
\item{ExpressionMatrix}{An expression matrix in data.frame or matrix format.
Rows should represent a transcript and its normalised counts,
while columns should represent individual cells.}

\item{GeneMetadata}{A data frame or vector containing gene identifiers used in
the expression matrix. The first column should hold the gene identifiers
you are using in the expression matrix. Other columns contain information about
the genes, such as their corresponding ENSEMBL transcript identifiers.}

\item{CellMetadata}{A data frame containing cell identifiers (usually barcodes)
and an integer representing which batch they belong to.
The column containing clustering information needs to be the first column in the CellMetadata dataframe
If clustering information is not available, users can run CORE function and add the information
to the scGPS before running scGPS prediction}
}
\value{
This function generates an scGPS object belonging to the \linkS4class{SingleCellExperiment}.
}
\description{
\code{\link{NewscGPS}} generates a scGPS object in the \linkS4class{SingleCellExperiment} class
for use with the scGPS package.This object contains an expression matrix, associated
metadata (cells, genes, clusters). The data are expected to be normalised counts.
}
\examples{
day2 <- sample1
t <-NewscGPS(ExpressionMatrix = day2$dat2_counts, GeneMetadata = day2$dat2geneInfo, CellMetadata = day2$dat2_clusters)
colData(t); show(t); colnames(t)
}
\seealso{
\linkS4class{SingleCellExperiment}
}
\author{
Quan Nguyen, 2018-04-06
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/scgps_prediction_summary.R
\name{summary_accuracy}
\alias{summary_accuracy}
\title{get percent accuracy for Lasso model, from \code{n} bootstraps}
\usage{
summary_accuracy(object = LSOLDA_dat)
}
\arguments{
\item{LSOLDA_dat}{is a list containing the training results from \code{training_scGPS}
the object \code{LSOLDA_dat}, the \code{summary_accuracy} summarise \code{n} bootstraps}
}
\value{
a vector of percent accuracy for the selected subpopulation
}
\description{
The training results from \code{training_scGPS} were written to
}
\examples{
c_selectID<-1
day2 <- sample1
mixedpop1 <-NewscGPS(ExpressionMatrix = day2$dat2_counts, GeneMetadata = day2$dat2geneInfo,
                    CellMetadata = day2$dat2_clusters)
day5 <- sample2
mixedpop2 <-NewscGPS(ExpressionMatrix = day5$dat5_counts, GeneMetadata = day5$dat5geneInfo,
                    CellMetadata = day5$dat5_clusters)
genes <-GeneList
genes <-genes$Merged_unique
LSOLDA_dat <- bootstrap_scGPS(nboots = 2,mixedpop1 = mixedpop1, mixedpop2 = mixedpop2, genes=genes, c_selectID, listData =list())
summary_accuracy(LSOLDA_dat)
summary_deviance(LSOLDA_dat)
}
\author{
Quan Nguyen, 2017-11-25
}

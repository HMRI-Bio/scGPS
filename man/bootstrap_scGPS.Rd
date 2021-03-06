% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/MainLassoLDATraining.R
\name{bootstrap_scGPS}
\alias{bootstrap_scGPS}
\title{BootStrap runs for both scGPS training and prediction}
\usage{
bootstrap_scGPS(nboots = 1, genes = genes, mixedpop1 = mixedpop1,
  mixedpop2 = mixedpop2, c_selectID, listData = list())
}
\arguments{
\item{nboots}{a number specifying how many bootstraps to be run}

\item{genes}{a gene list to build the model}

\item{mixedpop1}{a \linkS4class{SingleCellExperiment} object from a mixed population for training}

\item{mixedpop2}{a \linkS4class{SingleCellExperiment} object from a target mixed population for prediction}

\item{listData}{a \code{list} object, which contains trained results for the first mixed population}
}
\value{
a \code{list} with prediction results written in to the index \code{out_idx}
}
\description{
ElasticNet and LDA prediction for each of all the subpopulations in
the new mixed population after training the model for a subpopulation in the
first mixed population. The number of bootstraps to be run can be specified.
}
\examples{
day2 <- sample1
mixedpop1 <-NewscGPS(ExpressionMatrix = day2$dat2_counts, GeneMetadata = day2$dat2geneInfo,
                     CellMetadata = day2$dat2_clusters)
day5 <- sample2
mixedpop2 <-NewscGPS(ExpressionMatrix = day5$dat5_counts, GeneMetadata = day5$dat5geneInfo,
                     CellMetadata = day5$dat5_clusters)
genes <-GeneList
genes <-genes$Merged_unique
test <- bootstrap_scGPS(nboots = 2,mixedpop1 = mixedpop1, mixedpop2 = mixedpop2, genes=genes, c_selectID=1, listData =list())
names(test)
test$ElasticNetPredict
test$LDAPredict
}
\seealso{
\code{\link{bootstrap_scGPS_parallel}} for parallel options
}
\author{
Quan Nguyen, 2017-11-25
}

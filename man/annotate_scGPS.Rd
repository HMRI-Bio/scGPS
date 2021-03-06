% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Utilities.R
\name{annotate_scGPS}
\alias{annotate_scGPS}
\title{annotate_scGPS functionally annotates the identified clusters}
\usage{
annotate_scGPS(DEgeneList, pvalueCutoff = 0.05, gene_symbol = TRUE,
  output_filename = "PathwayEnrichment.xlsx", output_path = NULL)
}
\arguments{
\item{DEgeneList}{is a vector of gene symbols, convertable to ENTREZID}
}
\value{
write enrichment test output to a file and an enrichment test object for plotting
}
\description{
often we need to label clusters with unique biological characters.
One of the common approach to annotate a cluster is to perform functional enrichment
analysis. The annotate_scGPS implements ReactomePA and clusterProfiler for this analysis
type in R. The function require installation of several databases as described below.
}
\examples{
genes <-GeneList
genes <-genes$Merged_unique
LSOLDA_dat <- bootstrap_scGPS(nboots = 2,mixedpop1 = mixedpop1, mixedpop2 = mixedpop2, genes=genes, c_selectID, listData =list())
enrichment_test <- annotate_scGPS(genes$Merged_unique, pvalueCutoff=0.05, gene_symbol=TRUE,output_filename = "PathwayEnrichment.xlsx", output_path = NULL )
dotplot(enrichment_test, showCategory=15)

}

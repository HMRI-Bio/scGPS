
#' select top variable genes
#' @description subset a matrix by top variable genes
#' @param expression.matrix is a matrix with genes in rows and cells in columns
#' @return a subsetted expression matrix with the top n most variable genes
#' @examples
#' day2 <- sample1
#' mixedpop1 <-NewscGPS(ExpressionMatrix = day2$dat2_counts, GeneMetadata = day2$dat2geneInfo,
#'                     CellMetadata = day2$dat2_clusters)
#' SortedExprsMat <-topvar_scGPS(expression.matrix=assay(mixedpop1))

topvar_scGPS <- function(expression.matrix = NULL, ngenes = 1500) {
    CalcRowVariance <- function(x) {
        row.variance <- rowSums((x - rowMeans(x))^2)/(dim(x)[2] - 1)
        return(row.variance)
    }
    gene.variance <- CalcRowVariance(expression.matrix)
    names(gene.variance) <- rownames(expression.matrix)
    # Filter by position, exclude NA variances
    gene.order.variance <- order(gene.variance, decreasing = TRUE, na.last=NA)
    nn <- min(ngenes, length(gene.order.variance))
    subset.matrix <- expression.matrix[gene.order.variance[1:nn], ]
    return(subset.matrix)
}

#' plot reduced data
#' @description plot PCA, tSNE, and CIDR reduced datasets
#' @param reduced_dat is a matrix with genes in rows and cells in columns
#' @return a matrix with the top 20 CIDR dimensions
#' @examples
#' day2 <- sample1
#' mixedpop1 <-NewscGPS(ExpressionMatrix = day2$dat2_counts, GeneMetadata = day2$dat2geneInfo,
#'                     CellMetadata = day2$dat2_clusters)
#' CIDR_dim <-CIDR_scGPS(expression.matrix=assay(mixedpop1))
#' p <-plotReduced_scGPS(CIDR_dim)
#' plot(p)
#' tSNE_dim <-tSNE_scGPS(expression.matrix=assay(mixedpop1))
#' p2 <-plotReduced_scGPS(tSNE_dim)
#' plot(p2)
#'
#'
plotReduced_scGPS <- function(reduced_dat, color_fac = factor(Sample_id), dims = c(1,
  2), dimNames = c("Dim 1", "Dim 2"), palletes = NULL, legend_title = "Cluster") {
  library(cowplot)
  library(RColorBrewer)
  reduced_dat_toPlot <- as.data.frame(reduced_dat[, dims])
  sample_num <- length(unique(color_fac))
  if(is.null(palletes)){
    palletes <- colorRampPalette(brewer.pal(sample_num, "Set1"))(sample_num)
  }
  reduced_dat_toPlot <- as.data.frame(reduced_dat[, dims])
  sample_num <- length(unique(color_fac))
  colnames(reduced_dat_toPlot) <- dimNames
  reduced_dat_toPlot$color_fac <- color_fac
  p <- qplot(x = reduced_dat[, dims[1]], y = reduced_dat[, dims[2]], alpha = I(0.7),
             geom = "point", color = color_fac) + theme_bw()
  p <- p + ylab(dimNames[2]) + xlab(dimNames[1]) + scale_color_manual(name = legend_title,
                                                                      values = palletes[1:sample_num], limits = sort(as.character(as.vector(unique(color_fac)))))
  p <- p + theme(panel.border = element_rect(colour = "black", fill = NA, size = 1.5)) +
    theme(legend.position = "bottom") + theme(text = element_text(size = 20))
  
  yaxis <- axis_canvas(p, axis = "y", coord_flip = TRUE) + geom_density(data = reduced_dat_toPlot,
                                                                        aes(`Dim 2`, ..count.., fill = color_fac), size = 0.2, alpha = 0.7) + coord_flip() +
    scale_fill_manual(name = "Samples", values = palletes[1:sample_num], limits = sort(as.character(as.vector(unique(color_fac)))))
  
  xaxis <- axis_canvas(p, axis = "x") + geom_density(data = reduced_dat_toPlot,
                                                     aes(`Dim 1`, ..count.., fill = color_fac), size = 0.4, alpha = 0.7) + scale_fill_manual(name = "Samples",
                                                                                                                                             values = palletes[1:sample_num], limits = sort(as.character(as.vector(unique(color_fac)))))
  
  p1_x <- insert_xaxis_grob(p, xaxis, grid::unit(0.2, "null"), position = "top")
  p1_x_y <- insert_yaxis_grob(p1_x, yaxis, grid::unit(0.2, "null"), position = "right")
  p2 <- ggdraw(p1_x_y)
  return(p2)
}


#' find marker genes
#'
#' @description  Find DE genes from comparing one clust vs remaining
#' @param expression_matrix is  a normalised expression matrix.
#' @param cluster corresponding cluster information in the expression_matrix
#' by running CORE clustering or using other methods.
#' @param selected_cluster a vector of unique cluster ids to calculate
#' @param fitType string specifying "local" or "parametric" for DEseq dispersion estimation
#' @return a \code{list} containing sorted DESeq analysis results
#' @export
#' @author Quan Nguyen, 2017-11-25
#' @examples
#' day2 <- sample1
#' mixedpop1 <-NewscGPS(ExpressionMatrix = day2$dat2_counts, GeneMetadata = day2$dat2geneInfo,
#'                     CellMetadata = day2$dat2_clusters)
#' DEgenes <- findMarkers_scGPS(expression_matrix=assay(mixedpop1), cluster = colData(mixedpop1)[,1])
#' names(DEgenes)


findMarkers_scGPS <- function(expression_matrix = NULL, cluster = NULL, selected_cluster = NULL, fitType="local") {
    library(DESeq)

    DE_exprsMat <- round(expression_matrix + 1)

    DE_results <- list()
    for (cl_id in unique(selected_cluster)) {
        # arrange clusters and exprs matrix
        cl_index <- which(as.character(cluster) == as.character(cl_id))
        mainCl_idx <- which(as.character(cluster) != as.character(cl_id))
        diff_mat <- DE_exprsMat[, c(mainCl_idx, cl_index)]
        # start DE

        condition_cluster = as.vector(cluster)
        condition_cluster[1:length(mainCl_idx)] <- rep("Others", length(mainCl_idx))
        condition_cluster[(length(mainCl_idx) + 1):ncol(diff_mat)] <- rep(as.character(cl_id),
            length(cl_index))

        print(paste0("Start estimate dispersions for cluster ", as.character(cl_id),
            "..."))
        cds = newCountDataSet(diff_mat, condition_cluster)
        cds = estimateSizeFactors(cds)
        cds = estimateDispersions(cds, method = "per-condition", fitType = fitType)
        print(paste0("Done estimate dispersions. Start nbinom test for cluster ",
            as.character(cl_id), "..."))
        res1 = nbinomTest(cds, "Others", as.character(cl_id))
        print(paste0("Done nbinom test for cluster ", as.character(cl_id), " ..."))
        # adjust folchange
        print(paste0("Adjust foldchange by subtracting basemean to 1..."))
        res1 <- mutate(res1, AdjustedFC = (baseMeanB - 1)/(baseMeanA - 1))
        res1 <- mutate(res1, AdjustedLogFC = log2((baseMeanB - 1)/(baseMeanA - 1)))
        # order
        res1_order <- arrange(res1, pval, desc(abs(AdjustedLogFC)))
        # write to list
        DE_results <- c(DE_results, list(res1_order))
        name_list = paste0("DE_Subpop", cl_id, "vsRemaining")
        names(DE_results)[length(DE_results)] <- name_list
    }

    return(DE_results)
}

#' annotate_scGPS functionally annotates the identified clusters
#'
#' @description often we need to label clusters with unique biological characters.
#' One of the common approach to annotate a cluster is to perform functional enrichment
#' analysis. The annotate_scGPS implements ReactomePA and clusterProfiler for this analysis
#' type in R. The function require installation of several databases as described below.
#' @param DEgeneList is a vector of gene symbols, convertable to ENTREZID
#' @return write enrichment test output to a file and an enrichment test object for plotting
#' @examples
#' genes <-GeneList
#' genes <-genes$Merged_unique
#' LSOLDA_dat <- bootstrap_scGPS(nboots = 2,mixedpop1 = mixedpop1, mixedpop2 = mixedpop2, genes=genes, c_selectID, listData =list())
#' enrichment_test <- annotate_scGPS(genes$Merged_unique, pvalueCutoff=0.05, gene_symbol=TRUE,output_filename = "PathwayEnrichment.xlsx", output_path = NULL )
#' dotplot(enrichment_test, showCategory=15)
#'


# Installation needed for reactome pathway analysis reactome in R---------------
# source('https://bioconductor.org/biocLite.R') biocLite('ReactomePA') Package
# Genome wide annotation for Human
# http://bioconductor.org/packages/release/data/annotation/html/org.Hs.eg.db.html
# biocLite('org.Hs.eg.db') biocLite('clusterProfiler') install.packages('xlsx')
# Note: users may need to download and install clusterProfiler from source
# clusterProfiler_3.6.0.tgz' use: manual installing
# install.packages(path_to_file, repos = NULL, type='source') Done installation
# needed for reactome pathway analysis reactome in R----------------------------

annotate_scGPS <- function(DEgeneList, pvalueCutoff = 0.05, gene_symbol = TRUE, output_filename = "PathwayEnrichment.xlsx",
    output_path = NULL) {
    library(ReactomePA)
    library(clusterProfiler)
    library(org.Hs.eg.db)
    library(xlsx)
    # assumming the geneList is gene symbol (common for 10X data)
    if (gene_symbol == TRUE) {
        convert_to_gene_ID = bitr(DEgeneList, fromType = "SYMBOL", toType = "ENTREZID",
            OrgDb = "org.Hs.eg.db")
        print("Original gene number in geneList")
        print(length(DEgeneList))
        print("Number of genes successfully converted")
        print(nrow(convert_to_gene_ID))
    } else {
        stop("The list must contain gene symbols")
    }

    Reactome_pathway_test <- enrichPathway(gene = convert_to_gene_ID$ENTREZID, pvalueCutoff = 0.05,
        readable = TRUE)

    # plot some results: note Reactome_pathway_test is a reactomePA object write
    # Reactome_pathway_test results, need to convert to data.frame
    output_df <- as.data.frame(Reactome_pathway_test)
    write.xlsx(output_df, paste0(output_path, output_filename))
    return(Reactome_pathway_test)
    # note can conveniently plot the outputs by running the followings
    # dotplot(Reactome_pathway_test, showCategory=15) barplot(Reactome_pathway_test,
    # showCategory=15)
}


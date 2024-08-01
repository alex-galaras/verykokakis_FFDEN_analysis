#buildAnnotationDatabase(c("mm10","hg38","hg19"))
#utrs <- loadAnnotation(genome="mm10",refdb="ensembl",level="gene",type="utr")

library(metaseqR2)
the.path <- "/media/raid/users/alexandros/verykokakis_rna_seq/quantseq_MV437/analysis"
the.contrasts <- "FFDEN_vs_FFctrl"

metaseqr2(sampleList = file.path(the.path, "targets_for_paper.txt"), 
          contrast = the.contrasts, 
          org = "mm10",
          countType = "utr", 
          #annotation="embedded",
          normalization = "deseq", 
          statistics = c("deseq2", "edger", "limma", "nbpseq", "noiseq"), 
          metaP = "pandora", 
          #weight = w5, 
          figFormat = c("png", "pdf"), 
          exportWhere = file.path(the.path, "metaseqR2_for_paper"), 
          restrictCores = 0.25,
          qcPlots = c("mds", "biodetection", "countsbio", "saturation", "readnoise", "correl", "pairwise", "boxplot", "gcbias", "lengthbias", "rnacomp", "deheatmap", "volcano", "biodist", "filtered", "mastat", "statvenn", "foldvenn", "deregulogram"), 
          exonFilters = NULL, 
          geneFilters = list(length = list(length = 500),                                                                           
                             avgReads = list(averagePerBp = 100, quantile = 0.25), 
                             expression = list(median = TRUE, 
                                               mean = FALSE, 
                                               quantile = NA, 
                                               known = NA, 
                                               custom = NA), 
                             biotype = getDefaults("biotypeFilter", "mm10"), 
                             presence = list(frac = 0.5, minCount = 5, perCondition = TRUE)),                
          pcut = 0.05, 
          exportWhat=c("annotation","p_value", "adj_p_value", "meta_p_value", "adj_meta_p_value", "fold_change", "counts", "flags"),
          exportScale = c("natural","log2", "rpgm"), 
          exportValues = "normalized", 
          exportCountsTable = TRUE,
          saveGeneMode = TRUE,
          reportTop = 0.1,
          reportDb= "dexie"
)

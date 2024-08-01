The analysis includes 2 parts:
1. Alignment
2. Differential expression analysis using metaseqR2

Fastq files were mapped to mouse genomic build mm10 using a two-step alignment process. In the first round, reads were mapped with hisat2 (Kim et. al)using the default parameters and then, the unmapped reads were mapped with bowtie2 (Ben Langmead &amp; Steven L Salzberg, 2012) using the --local and --very-sensitive parameters. The code is included in the script hisat.sh.

RNA-seq analysis was conducted with the Bioconductor package metaseqR2 (https://pubmed.ncbi.nlm.nih.gov/32778872/). Raw reads were estimated through metaseqR2 and were normalized with the DESEQ algorithm. Differential gene expression was conducted with the PANDORA algorithm by combining the algorithms DESeq2, edgeR, limma NBPSeq, and NOISeq analyzed using the DESeq algorithm. Genes exhibiting a meta-p-valueDESeq p-value < 0.05 and a fold change greater than 1.0 or less than −1.0 on the log2 scale (corresponding to a 2-fold change in the natural scale) were considered differentially expressed. The volcano plot was generated using ggplot2. The analyses can be found in scripts metaseqR2.R and volcano.R.

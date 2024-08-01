#!/bin/bash

# Directory variables
HOME_PATH=/home/alexandros/verykokakis_rna_seq/quantseq_MV437
FASTQ_PATH=$HOME_PATH/fastq
HISAT2_OUTPUT=$HOME_PATH/fastq/hisat_files #the dir inside home_path dir, where hisat2 output files will be stored 

# Command tool variables
SAMTOOLS_COMMAND=`which samtools`
HISAT2_COMMAND=`which hisat2`
BOWTIE2_COMMAND=`which bowtie2`
BEDTOOLS_COMMAND=`which bedtools`

# Reference Genome Index
HISAT2_INDEXES=/home/alexandros/tools/hisat2/hisat2-2.1.0/indexes/mm10/genome 
TRANSCRIPTOME_INDEX=/media/raid/users/alexandros/tools/hisat2/hisat2-2.1.0/indexes/mm10_spliced_sites.txt

#Bowtie Index
BOWTIE2_INDEX=/media/raid/resources/igenomes/Mus_musculus/UCSC/mm10/Sequence/Bowtie2Index/genome # the path and lastly the basename where ref.genome index is stored

# Organism; just for reference as it is not used anywhere 
ORG=mm10

# Number of cores to use
CORES=20

#Execute HISAT2
for FILE in $FASTQ_PATH/*.fastq
do	
	SAMPLE=`basename $FILE | sed s/\.fastq// | sed s/\.fastq// | sed s/\.IonXpress*//`  
	echo "==================== Mapping with hisat2 for $SAMPLE..."
	mkdir -p $HISAT2_OUTPUT/$SAMPLE #making a sample specific dir for storing the analysis results
	$HISAT2_COMMAND -p $CORES --un $HISAT2_OUTPUT/$SAMPLE/unmapped.fastq -x $HISAT2_INDEXES \
		-U $FILE -S $HISAT2_OUTPUT/$SAMPLE/hisat2.sam --add-chrname   # ".fq" is used because hisat anticipates it
	echo " "
	echo "==================== Trying now to map unmapped reads with bowtie2 for $SAMPLE..."
   $BOWTIE2_COMMAND --local --very-sensitive-local -p $CORES -x $BOWTIE2_INDEX -U $HISAT2_OUTPUT/$SAMPLE/unmapped.fastq | $SAMTOOLS_COMMAND view -bhS -o $HISAT2_OUTPUT/$SAMPLE/unmapped_remap_tmp.bad -
    echo "==================== Merging all reads for $SAMPLE..." 
	$SAMTOOLS_COMMAND view -@ 20 -HS $HISAT2_OUTPUT/$SAMPLE/hisat2.sam > $HISAT2_OUTPUT/$SAMPLE/header.sam #taking the header of hisat2.sam and redirecting it to header.sam
	# A reheader MUST be done as Bowtie2 returns different header than hisat2 ??!!?? (@&#^*&^$
	$SAMTOOLS_COMMAND reheader $HISAT2_OUTPUT/$SAMPLE/header.sam $HISAT2_OUTPUT/$SAMPLE/unmapped_remap_tmp.bad > $HISAT2_OUTPUT/$SAMPLE/unmapped_remap_tmp.uns #replace the header of unmapped_remap_tmp.bad with the header of header.sam
	$SAMTOOLS_COMMAND sort -@ 20 $HISAT2_OUTPUT/$SAMPLE/unmapped_remap_tmp.uns > $HISAT2_OUTPUT/$SAMPLE/unmapped_remap.bam
    # SAM file created by HISAT2 must be transformed into BAM before merging the files
	$SAMTOOLS_COMMAND view -@ 20 -bhS $HISAT2_OUTPUT/$SAMPLE/hisat2.sam > $HISAT2_OUTPUT/$SAMPLE/hisat2.bam
	$SAMTOOLS_COMMAND merge -@ 20 -f $HISAT2_OUTPUT/$SAMPLE/tmp.bam $HISAT2_OUTPUT/$SAMPLE/hisat2.bam $HISAT2_OUTPUT/$SAMPLE/unmapped_remap.bam   
	echo "==================== Coordinate sorting all reads for $SAMPLE..."
    $SAMTOOLS_COMMAND sort -@ 20 $HISAT2_OUTPUT/$SAMPLE/tmp.bam > $HISAT2_OUTPUT/$SAMPLE/$SAMPLE".bam"
    echo "==================== Indexing all merged reads for $SAMPLE..."
    $SAMTOOLS_COMMAND index -@ 20 $HISAT2_OUTPUT/$SAMPLE/$SAMPLE.bam
    echo "==================== Removing intermediate garbage for $SAMPLE..."
    rm $HISAT2_OUTPUT/$SAMPLE/hisat2.bam $HISAT2_OUTPUT/$SAMPLE/tmp.bam $HISAT2_OUTPUT/$SAMPLE/unmapped*.fastq $HISAT2_OUTPUT/$SAMPLE/unmapped_remap.bam $HISAT2_OUTPUT/$SAMPLE/unmapped_remap_tmp.bad $HISAT2_OUTPUT/$SAMPLE/unmapped_remap_tmp.uns
    echo " "
done


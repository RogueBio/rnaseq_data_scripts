#!/bin/bash
#SBATCH -p short          # Partition name
#SBATCH -t 0-2:00         # Time limit (D-HH:MM)
#SBATCH -c 6              # Number of cores
#SBATCH --mem 6G          # Requested memory
#SBATCH -o %x_%j.out      # File to which stdout will be written
#SBATCH -e %x_%j.err      # File to which stderr will be written


STAR --runThreadN 8
-- runMode genomeGenerate 
--genomeDir $GENOMEDIR 
-- genomeFastaFiles path to genome/ 
--genomeFastaFiles $GENOMEDIR/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
--sjdbGTFfile gencode.v36.annotation.gtf
--sjdbOverhang readlength -1 #(or 100, check on booklet)

STAR --runThreadN 8
--genomeDir $GENOMEDIR 
--readFilesIn <sample>_R1.trimmed.fastq.gz <sample>_R2.trimmed.fastq.gz
--outFileNamePrefix <sample> 
--readFilesCommand zcat 
--outSAMtype BAM Unsorted 
--quantTranscriptomeBan Singleend 
--alignSJoverhangMin 8 
--alignSJDBoverhangMin 1 
--quantMode TranscriptomeSAM 
--outSAMattributes NH HI AS NM MD



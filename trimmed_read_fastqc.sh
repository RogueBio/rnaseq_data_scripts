#!/bin/bash
#SBATCH --job-name=fastqc
#SBATCH --array=0-99        # Adjust based on number of files
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=00:30:00
#SBATCH --output=logs/fastqc_%A_%a.out

module load fastqc

# Get list of files
FILES=(trimmed_reads/*_paired.fastq.gz)
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}

# Run FastQC
fastqc -o fastqc_output "$FILE"

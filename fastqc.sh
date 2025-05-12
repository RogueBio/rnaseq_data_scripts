#!/bin/bash
#SBATCH --partition=cpu-standard
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --job-name=fastqc_rerun
#SBATCH --output=fastqc_%j.log

module load FastQC/0.12.1-Java-17 

if [ -z "$fastq_file" ] || [ ! -f "$fastq_file" ]; then
    echo "Error: FASTQ file '$fastq_file' not found."
    exit 1
fi

mkdir -p "$output_dir"

# Run FastQC using all allocated threads
fastqc --threads "$SLURM_CPUS_PER_TASK" -o "$output_dir" "$fastq_file"

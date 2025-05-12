#!/bin/bash
#SBATCH --partition=cpu-standard
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --array=0-<MAX_INDEX>
#SBATCH --job-name=fastqc_array
#SBATCH --output=logs/fastqc_%A_%a.log

module load FastQC/0.12.1-Java-17

# Setup
raw_data_dir="'Manuela Data'/220211_A00181_0425_BHVMJNDSX2"
output_dir="mosquito_test/fastqc_results"
mkdir -p "$output_dir"

# Generate fastq list only once — do this before submitting
fastq_list="fastq_list.txt"

# Read file based on SLURM array task ID
fastq_file=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$fastq_list")

if [ ! -f "$fastq_file" ]; then
    echo "FASTQ file not found: $fastq_file"
    exit 1
fi

# Run FastQC
fastqc --threads "$SLURM_CPUS_PER_TASK" -o "$output_dir" "$fastq_file"

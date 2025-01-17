#!/bin/bash
#SBATCH -p short          # Partition name
#SBATCH -t 0-2:00         # Time limit (D-HH:MM)
#SBATCH -c 6              # Number of cores
#SBATCH --mem 6G          # Requested memory
#SBATCH -o %x_%j.out      # File to which stdout will be written
#SBATCH -e %x_%j.err      # File to which stderr will be written

# Load modules required for script commands
module load fastqc/0.12.1

# Check if variables are passed correctly
if [ -z "$fastq_file" ] || [ -z "$output_dir" ]; then
    echo "Error: Required variables 'fastq_file' and 'output_dir' are not set."
    exit 1
fi

# Ensure the output directory exists
mkdir -p "$output_dir"

# Run FASTQC
fastqc -o "$output_dir" -t "$SLURM_CPUS_PER_TASK" "$fastq_file"

# Archive the results in the output directory
cd "$output_dir"
zip -r fastqc_reports_$SLURM_JOB_ID.zip *.html *.zip

#!/bin/bash
#SBATCH --partition=cpu-standard
#SBATCH --cpus-per-task=4
#SBATCH --mem=50G
#SBATCH --time=02:00:00
#SBATCH --job-name=fastqc_rerun

# Load modules required for script commands
module load FastQC/0.12.1-Java-17 

# Check if variables are passed correctly
if [ -z "$fastq_file" ] || [ ! -f "$fastq_file" ]; then
    echo "Error: FASTQ file '$fastq_file' is either not set or does not exist."
    exit 1
fi

# Run FASTQC
fastqc -o "$output_dir" "$fastq_file"

# Archive the results in the output directory
cd "$output_dir"
zip -r "fastqc_reports_${SLURM_JOB_ID}.zip" *.html *.zip

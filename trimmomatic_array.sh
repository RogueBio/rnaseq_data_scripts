#!/bin/bash
#SBATCH --partition=cpu-standard
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --array=0-36
#SBATCH --job-name=trimmomatic_array
#SBATCH --output=logs/trim_%A_%a.log

# Load required modules
module load Java/17.0.6
module load Trimmomatic/0.39-Java-17

# Adapter file 
adapter_file="/home/ar9416e/git_repos/Illumina_adapters/illumina_full_adapters.fa"

# Check adapter file exists
if [[ ! -f "$adapter_file" ]]; then
  echo "Error: Adapter file not found at $adapter_file"
  exit 1
fi

# Setup directories
raw_data_dir="/home/ar9416e/Manuela Data/220211_A00181_0425_BHVMJNDSX2"  # Fixed path
output_dir="/home/ar9416e/mosquito_test/trimmed_reads"
mkdir -p "$output_dir"

# Find all R1 and R2 fastq.gz files
R1_files=($(find "$raw_data_dir" -maxdepth 1 -name '*R1_*.fastq.gz'))
R2_files=($(find "$raw_data_dir" -maxdepth 1 -name '*R2_*.fastq.gz'))

# Debugging: check number of files
echo "Number of R1 files: ${#R1_files[@]}"
echo "Number of R2 files: ${#R2_files[@]}"

# Get the index from SLURM_ARRAY_TASK_ID to select corresponding R1 and R2 files
R1=${R1_files[$SLURM_ARRAY_TASK_ID]}
R2=${R2_files[$SLURM_ARRAY_TASK_ID]}

# Debugging: check selected R1 and R2 files
echo "SLURM_ARRAY_TASK_ID: $SLURM_ARRAY_TASK_ID"
echo "R1 file selected: $R1"
echo "R2 file selected: $R2"

# Extract the base name for the sample (without R1 or R2 part)
base=$(basename "$R1" _R1.fastq.gz)
echo

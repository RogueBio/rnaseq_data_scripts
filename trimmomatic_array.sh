#!/bin/bash
#SBATCH --partition=cpu-standard
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=02:00:00
#SBATCH --array=0-14,17-30,33,35-36
#SBATCH --job-name=trimmomatic_array
#SBATCH --output=logs/trim_%A_%a.log

# Load required modules
module load Java/17.0.6
module load Trimmomatic/0.39-Java-17

# Adapter file 
adapter_file="/home/ar9416e/git_repos/Illumina_adapters/illumina_adapters_trimmomatic.fa"

# Check adapter file exists
if [[ ! -f "$adapter_file" ]]; then
  echo "Error: Adapter file not found at $adapter_file"
  exit 1
fi

# Setup directories
raw_data_dir="/home/ar9416e/temperature_samples/220211_A00181_0425_BHVMJNDSX2/"  # Fixed path
output_dir="/home/ar9416e/mosquito_test/trimmed_reads"
mkdir -p "$output_dir"
mkdir -p logs

# Find all R1 and R2 fastq.gz files
R1_files=($(find "$raw_data_dir" -type f -name '*R1_*.fastq.gz'))
R2_files=($(find "$raw_data_dir" -type f -name '*R2_*.fastq.gz'))

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

# Define output file paths
output_R1_paired="${output_dir}/${base}_R1_paired.fastq.gz"
output_R1_unpaired="${output_dir}/${base}_R1_unpaired.fastq.gz"
output_R2_paired="${output_dir}/${base}_R2_paired.fastq.gz"
output_R2_unpaired="${output_dir}/${base}_R2_unpaired.fastq.gz"
trim_log="${output_dir}/${base}_trim_log.txt"

# Output for debugging
echo "Output files:"
echo "$output_R1_paired"
echo "$output_R1_unpaired"
echo "$output_R2_paired"
echo "$output_R2_unpaired"
echo "$trim_log"

# Run Trimmomatic
echo "Running Trimmomatic for sample: $base"
java -jar /opt/software/eb/software/Trimmomatic/0.39-Java-17/trimmomatic-0.39.jar \
  PE \
  -threads 4 \
  -phred33 \
  "$R1" "$R2" \
  "$output_R1_paired" "$output_R1_unpaired" \
  "$output_R2_paired" "$output_R2_unpaired" \
  ILLUMINACLIP:/home/ar9416e/git_repos/Illumina_adapters/illumina_adapters_trimmomatic.fa:2:30:10 \
  LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 \
  -trimlog "$trim_log"

# Check for success or failure
if [[ $? -eq 0 ]]; then
  echo "Trimmomatic completed successfully for $base"
else
  echo "Trimmomatic failed for $base"
  exit 1
fi

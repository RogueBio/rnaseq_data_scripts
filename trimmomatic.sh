#!/bin/bash
#SBATCH --partition=cpu-standard
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --job-name=trimmomatic_single
#SBATCH --output=logs/trim_%A_%a.log

# Load required modules
module load Java/17.0.6
module load Trimmomatic/0.39-Java-17

# Adapter file 
adapter_file="/home/ar9416e/git_repos/Illumina_adapters/illumina_full_adapters.fa"

# Check if adapter file exists
if [[ ! -f "$adapter_file" ]]; then
  echo "Error: Adapter file not found at $adapter_file"
  exit 1
fi

# Get sample directory from argument
sample_dir="$1"

# Check if sample directory exists
if [[ ! -d "$sample_dir" ]]; then
  echo "Error: Invalid sample directory: $sample_dir"
  exit 1
fi

sample_name=$(basename "$sample_dir")

# Find R1 and R2 fastq files in the sample directory
R1=$(find "$sample_dir" -maxdepth 1 -name '*R1*.fastq.gz' | head -n 1)
R2=$(find "$sample_dir" -maxdepth 1 -name '*R2*.fastq.gz' | head -n 1)

# Check if both R1 and R2 files exist
if [[ -z "$R1" || -z "$R2" ]]; then
  echo "Error: Could not find R1 or R2 for $sample_name"
  exit 1
fi

# Output directory
output_dir="/home/ar9416e/mosquito_test/trimmed_reads/trimmed/${sample_name}"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Output files
base=$(basename "$R1" _R1.fastq.gz)
paired_fwd="${output_dir}/${base}_R1_paired.fastq.gz"
unpaired_fwd="${output_dir}/${base}_R1_unpaired.fastq.gz"
paired_rev="${output_dir}/${base}_R2_paired.fastq.gz"
unpaired_rev="${output_dir}/${base}_R2_unpaired.fastq.gz"
trim_log="${output_dir}/${base}_trim.log"

# Print out which files will be used
echo "Running Trimmomatic for sample: $sample_name"
echo "Forward Read 1 (R1): $R1"
echo "Forward Read 2 (R2): $R2"
echo "Output Directory: $output_dir"

# Run Trimmomatic
java -jar /path/to/trimmomatic-0.39.jar \
  -threads "$SLURM_CPUS_PER_TASK" \
  -phred33 \
  "$R1" "$R2" \
  "$paired_fwd" "$unpaired_fwd" \
  "$paired_rev" "$unpaired_rev" \
  ILLUMINACLIP:"$adapter_file":2:30:10 \
  LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 \
  -trimlog "$trim_log"

# Check if Trimmomatic ran successfully
if [[ $? -eq 0 ]]; then
  echo "Trimmomatic completed successfully for $sample_name"
else
  echo "Trimmomatic failed for $sample_name"
fi

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

if [[ ! -f "$adapter_file" ]]; then
  echo "Error: Adapter file not found at $adapter_file"
  exit 1
fi

# Get sample directory from argument
sample_dir="$1"

if [[ ! -d "$sample_dir" ]]; then
  echo "Error: Invalid sample directory: $sample_dir"
  exit 1
fi

sample_name=$(basename "$sample_dir")

# Find R1 and R2
R1=$(find "$sample_dir" -maxdepth 1 -name '*R1*001.fastq.gz' | head -n 1)
R2=$(find "$sample_dir" -maxdepth 1 -name '*R2*001.fastq.gz' | head -n 1)

if [[ -z "$R1" || -z "$R2" ]]; then
  echo "Error: Could not find R1 or R2 for $sample_name"
  exit 1
fi

# Output directory
output_dir="/home/ar9416e/mosquito_test/trimmed_reads/trimmed/${sample_name}"
mkdir -p "$output_dir"

# Output files
base=$(basename "$R1" _R1.fastq.gz)
paired_fwd="${output_dir}/${base}_R1_paired.fastq.gz"
unpaired_fwd="${output_dir}/${base}_R1_unpaired.fastq.gz"
paired_rev="${output_dir}/${base}_R2_paired.fastq.gz"
unpaired_rev="${output_dir}/${base}_R2_unpaired.fastq.gz"
trim_log="${output_dir}/${base}_trim.log"

echo "Running Trimmomatic for sample: $sample_name"
java -jar "$EBROOTTRIMMOMATIC/trimmomatic-0.39.jar" \
  -threads "$SLURM_CPUS_PER_TASK" \
  -phred33 \
  "$R1" "$R2" \
  "$paired_fwd" "$unpaired_fwd" \
  "$paired_rev" "$unpaired_rev" \
  ILLUMINACLIP:"$adapter_file":2:30:10 \
  LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 \
  -trimlog "$trim_log"

[[ $? -eq 0 ]] && echo "Trimmomatic completed successfully" || echo "Trimmomatic failed"

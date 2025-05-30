#!/bin/bash
#SBATCH --partition=cpu-standard
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --job-name=trim_polyA
#SBATCH --output=logs/polyA_trim_%A_%a.log
#SBATCH --array=0-36

# Load Cutadapt
module load cutadapt/4.2-GCCcore-11.3.0

# Directories
input_dir="/home/ar9416e/mosquito_test/trimmed_reads"
output_dir="/home/ar9416e/mosquito_test/trimmed_reads_polyA"
mkdir -p "$output_dir"
mkdir -p logs

# Collect input files
R1_files=($(find "$input_dir" -type f -name '*_R1_paired.fastq.gz' | sort))
R2_files=($(find "$input_dir" -type f -name '*_R2_paired.fastq.gz' | sort))

# Select file based on SLURM_ARRAY_TASK_ID
R1=${R1_files[$SLURM_ARRAY_TASK_ID]}
R2=${R2_files[$SLURM_ARRAY_TASK_ID]}

## Extract base name (no extension)
base=$(basename "$R1" .fastq.gz)

# Insert '_cut' before .fastq.gz
cut_base_R1="${base/_R1_paired/_cut_R1_paired}"

# Replace only the paired part for R2 too
cut_base_R2="${cut_base/_R1_paired/_R2_paired}"

# Final output paths
R1_out="${output_dir}/${cut_base_R1}.fastq.gz"
R2_out="${output_dir}/${cut_base_R2}.fastq.gz"

# Run Cutadapt to remove polyA/T tails
echo "Processing $base"
cutadapt \
  -a "A{20}" -A "T{20}" \
  -o "$R1_out" \
  -p "$R2_out" \
  "$R1" "$R2"

# Check result
if [[ $? -eq 0 ]]; then
  echo "PolyA/T trimming done for $base"
else
  echo "Cutadapt failed for $base"
  exit 1
fi

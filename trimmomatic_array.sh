#!/bin/bash
#SBATCH --partition=cpu-standard
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=01:00:00
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

# Get the index from SLURM_ARRAY_TASK_ID to select corresponding R1 and R2 files
R1=${R1_files[$SLURM_ARRAY_TASK_ID]}
R2=${R2_files[$SLURM_ARRAY_TASK_ID]}

# Extract the base name for the sample (without R1 or R2 part)
base=$(basename "$R1" _R1.fastq.gz)
sample_name="$base"

# Define output file paths
paired_fwd="${output_dir}/${base}_R1_paired.fastq.gz"
unpaired_fwd="${output_dir}/${base}_R1_unpaired.fastq.gz"
paired_rev="${output_dir}/${base}_R2_paired.fastq.gz"
unpaired_rev="${output_dir}/${base}_R2_unpaired.fastq.gz"
trim_log="${output_dir}/${base}_trim.log"

# Output file names for debugging
echo "Output files:"
echo "$paired_fwd"
echo "$unpaired_fwd"
echo "$paired_rev"
echo "$unpaired_rev"
echo "$trim_log"

# Run Trimmomatic
echo "Running Trimmomatic for sample: $sample_name"
java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar \
  -threads "$SLURM_CPUS_PER_TASK" \
  -phred33 \
  "$R1" "$R2" \
  "$paired_fwd" "$unpaired_fwd" \
  "$paired_rev" "$unpaired_rev" \
  ILLUMINACLIP:"$adapter_file":2:30:10 \
  LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 \
  -trimlog "$trim_log"

# Check for success or failure
if [[ $? -eq 0 ]]; then
  echo "Trimmomatic completed successfully for $sample_name"
else
  echo "Trimmomatic failed for $sample_name"
  exit 1
fi

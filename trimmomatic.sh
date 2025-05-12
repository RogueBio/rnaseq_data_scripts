#!/bin/bash
#SBATCH --partition=cpu-standard
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --array=0
#SBATCH --job-name=trimmomatic_array
#SBATCH --output=logs/trim_%A_%a.log

# Load required modules
module load java

# Path to Trimmomatic JAR
TRIMMOMATIC_JAR="/path/to/trimmomatic-0.39.jar"  # <-- UPDATE THIS

# Adapter file (must be accessible and valid)
adapter_file="/path/to/adapters.fa"  # <-- UPDATE THIS

# Check adapter file exists
if [[ ! -f "$adapter_file" ]]; then
  echo "❌ Error: Adapter file not found at $adapter_file"
  exit 1
fi

# Get sample directory from array task ID
sample_dir=$(sed -n "$((SLURM_ARRAY_TASK_ID+1))p" sample_list.txt)
sample_name=$(basename "$sample_dir")

# Identify R1 and R2
R1=$(find "$sample_dir" -name '*_R1.fastq.gz')
R2=$(find "$sample_dir" -name '*_R2.fastq.gz')

if [[ -z "$R1" || -z "$R2" ]]; then
  echo "❌ Error: Could not find R1 or R2 for $sample_name"
  exit 1
fi

# Output directory
output_dir="trimmed/${sample_name}"
mkdir -p "$output_dir"

# Output file names
base=$(basename "$R1" _R1.fastq.gz)
paired_fwd="${output_dir}/${base}_R1_paired.fastq.gz"
unpaired_fwd="${output_dir}/${base}_R1_unpaired.fastq.gz"
paired_rev="${output_dir}/${base}_R2_paired.fastq.gz"
unpaired_rev="${output_dir}/${base}_R2_unpaired.fastq.gz"
trim_log="${output_dir}/${base}_trim.log"

# Run Trimmomatic
echo "🔧 Running Trimmomatic for sample: $sample_name"
java -jar "$TRIMMOMATIC_JAR" PE \
  -threads "$SLURM_CPUS_PER_TASK" \
  -phred33 \
  "$R1" "$R2" \
  "$paired_fwd" "$unpaired_fwd" \
  "$paired_rev" "$unpaired_rev" \
  ILLUMINACLIP:"$adapter_file":2:30:10 \
  LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 \
  -trimlog "$trim_log"

# Check status
if [[ $? -eq 0 ]]; then
  echo "✅ Trimmomatic completed successfully for $sample_name"
else
  echo "❌ Trimmomatic failed for $sample_name"
  exit 1
fi

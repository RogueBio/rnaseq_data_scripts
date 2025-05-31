#!/bin/bash
#SBATCH --job-name=salmon_quant
#SBATCH --partition=cpu-standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=40G
#SBATCH --time=04:00:00
#SBATCH --array=0-117
#SBATCH --output=logs/salmon_%x_%j.out
#SBATCH --error=logs/salmon_%x_%j.err

# Load Salmon module if needed
# module load salmon

# Define index and output directory
salmon_index="/home/ar9416e/mosquito_test/alignments/salmon_index"
output_dir="/home/ar9416e/mosquito_test/alignments"

# Define read file arrays
R1_files=(/home/ar9416e/mosquito_test/trimmed_reads_polyA/*_R1_paired.fastq.gz)
R2_files=(/home/ar9416e/mosquito_test/trimmed_reads_polyA/*_R2_paired.fastq.gz)

# Get the correct input files based on the array task ID
R1="${R1_files[$SLURM_ARRAY_TASK_ID]}"
R2="${R2_files[$SLURM_ARRAY_TASK_ID]}"

# Debugging: Print file paths to verify correct assignment
echo "Using files: $R1 and $R2"
ls -l "$R1" "$R2"

# Extract base filename from R2 file
base_filename=$(basename "$R2")

# Extract sample name from base filename (up to _S, adjust if needed)
sample_name="${base_filename%%_S*}"

# Run Salmon
echo "Processing sample ${sample_name}"
salmon quant -i "$salmon_index" -l A \
  -1 "$R1" \
  -2 "$R2" \
  -p 6 \
  --validateMappings \
  -o "${output_dir}/${sample_name}_quant"

# Check if Salmon finished successfully
if [ $? -eq 0 ]; then
    echo "Salmon completed successfully for ${sample_name}."
else
    echo "Error: Salmon failed for ${sample_name}. Check logs for details."
    exit 1
fi

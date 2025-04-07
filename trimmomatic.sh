#!/bin/bash
#SBATCH --partition=cpu-standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=50G

# Load modules required for script commands
module load java 
module load trimmomatic-0.39.jar

# Ensure variables are defined
if [[ -z "$fastq_file" || -z "$output_dir" ]]; then
  echo "Error: fastq_file and output_dir must be provided."
  exit 1
fi

# Input and output file names
input_file="$fastq_file"
base_filename=$(basename "$fastq_file" .fastq)  # Extract base name without extension
output_paired="${output_dir}/${base_filename}_paired.fastq.gz"
output_unpaired="${output_dir}/${base_filename}_unpaired.fastq.gz"
trim_log="${output_dir}/${base_filename}_trim.log"  # Log file path

# Set adapter file path (you need to specify this)
adapter_file=<path_to_adapter_file>  # Replace with the actual path to adapter FASTA file
if [[ ! -f "$adapter_file" ]]; then
  echo "Error: Adapter file not found at $adapter_file."
  exit 1
fi

## I need to work out some metrics for this:
# I need to know if I must remove adapters, if so, I must run ILLUMINACLIP: <Pathtofastaqithadapters>:<max mismatch count which 
#will still allow ful matchseed mismatches>:<EITHER thereshold palindromeclip>:<OR simpleclip>
#I'm going to assume adapters in a random file and simple clip

java -jar <pathtotrimmomatic.jar> PE \
-threads 6 \
-phred33 \
"$input_file" "${input_file}" \
"$output_paired" "$output_unpaired" \
ILLUMINACLIP:"$adapter_file":2:30:10 MINLEN:36 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 \
  -trimlog "$trim_log"

# Check if Trimmomatic ran successfully
if [[ $? -eq 0 ]]; then
  echo "Trimmomatic completed successfully for $input_file."
else
  echo "Error: Trimmomatic failed for $input_file."
  exit 1
fi


#!/bin/bash
#SBATCH --job-name=trimmomatic_job  # Name of the job
#SBATCH --output=trimmomatic_%A_%a.out  # Standard output file
#SBATCH --error=trimmomatic_%A_%a.err  # Standard error file
#SBATCH --time=12:00:00  # Max run time (adjust as needed)
#SBATCH --mem=8G  # Memory per node (adjust as needed)
#SBATCH --cpus-per-task=4  # Number of CPUs per task (adjust as needed)
#SBATCH --array=1-$(ls -d */ | wc -l)  # Job array to process each folder

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

# Set the working directory (adjust path if needed)
raw_data_dir="/home/ar9416e/Manuela Data/220211_A00181_0425_BHVMJNDSX2"

# Get the current folder based on the job array ID
dir_name=$(ls -d */ | sed -n "${SLURM_ARRAY_TASK_ID}p")
cd "$raw_data_dir/$dir_name"

# Find paired-end files (assuming they are named with '_B' and '_H' suffix)
R1=$(ls *B.fastq.gz)
R2=$(ls *H.fastq.gz)

# Check that both paired files exist
if [[ -z "$R1" || -z "$R2" ]]; then
    echo "Error: Could not find paired files in $dir_name"
    exit 1
fi

# Create the output directory if it doesn't exist
output_dir="/home/ar9416e/mosquito_test/trimmed_reads"
mkdir -p "$output_dir"

# Define output file names within the trimmed directory
paired_fwd="${output_dir}/${dir_name}_trimmed_1.fastq.gz"
unpaired_fwd="${output_dir}/${dir_name}_unpaired_1.fastq.gz"
paired_rev="${output_dir}/${dir_name}_trimmed_2.fastq.gz"
unpaired_rev="${output_dir}/${dir_name}_unpaired_2.fastq.gz"
trim_log="${output_dir}/${dir_name}_trim_log.txt"

# Run Trimmomatic
java -jar /opt/software/eb/software/Trimmomatic/0.39-Java-17/trimmomatic-0.39.jar \
    PE -threads "$SLURM_CPUS_PER_TASK" \
    -phred33 \
    "$R1" "$R2" \
    "$paired_fwd" "$unpaired_fwd" \
    "$paired_rev" "$unpaired_rev" \
    ILLUMINACLIP:"$adapter_file":2:30:10 \
    LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 \
    -trimlog "$trim_log"

# Check if Trimmomatic ran successfully
if [[ $? -eq 0 ]]; then
    echo "Trimmomatic completed successfully for $dir_name"
else
    echo "Trimmomatic failed for $dir_name"
    exit 1
fi

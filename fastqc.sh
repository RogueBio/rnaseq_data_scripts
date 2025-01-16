#SBATCH -p short 		# partition name
#SBATCH -t 0-2:00 		# time limit
#SBATCH -c 6 		# number of cores
#SBATCH --mem 6G   # requested memory
#SBATCH --job-name rnaseq_mov10_fastqc 		# Job name
#SBATCH -o %j.out			# File to which standard output will be written
#SBATCH -e %j.err 		# File to which standard error will be written

## Load modules required for script commands
module load fastqc/0.12.1

# Define input and output directories
INPUT_DIR="/path/to/fastq/files"
OUTPUT_DIR="/path/to/fastqc/results"
mkdir -p $OUTPUT_DIR  # Ensure output directory exists

## Run FASTQC
fastqc -o "$OUTPUT_DIR" -t "$SLURM_CPUS_PER_TASK" "$INPUT_DIR"/*.fastq.gz

cd "$OUTPUT_DIR"
zip -r fastqc_reports.zip *.html *.zip

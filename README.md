# mosquito_phagostimulants

Pipeline to run transcriptomic analysis of an experiment where _Anopheles coluzzii_ mosquitoes were fed three phagostimulant meals, to determine the neuromodulatory mechanisms, chemosensory gene activity, neuropeptide regulation, and early transport gut mechanisms. Summarising pre-ingestive and immediate post-contact events.

* Sample types: Heads (n=10) and Guts (n=40)
* For each sample type, conditions: Blood-fed (n=4 replicates), Mix Feeding Solution fed (MFS) (n=4 replicates), MFS + HMBPP (n=4 replicates), and MFS + ATP (n=4 replicates)

 ## Data organisation

All commands were submitted from the project-specific directory:

  ProjDir=/home/ar9416e/mosquito_phagostimulants/
  mkdir -p $ProjDir
  cd $ProjDir

Project directory:

```text
mosquito_phagostimulants/
│
├── raw_data/              # Original FASTQ files (read-only)
├── qc_reports/            # FastQC, MultiQC reports
├── trimmed_reads/         # After trimming (e.g., Cutadapt)
├── alignments/            # BAM files, STAR/Hisat2 output
├── counts/                # Gene count matrices (from featureCounts, Salmon, etc.)
├── scripts/               # All analysis scripts (R, Python, bash)
├── results/
│   ├── DE/                # Differential expression results
│   ├── figures/           # Plots, heatmaps, PCA, etc.
│   └── enrichment/        # Pathway or GO analysis
├── notebooks/             # Jupyter/R Markdown/Quarto notebooks
├── metadata/              # Sample metadata, experimental design
└── logs/                  # Pipeline logs and error outputs
```

# Steps of pipeline

1) Fast QC, loop iterating through all fastq files (paired read) and then to run the fastqc.sh script to submit fastqc job to SLURM on HPC2
2) Loop iterating through same read files, then running trimmomatic.sh script to submit the job to SLURM to use trimmomatic (http://www.usadellab.org/cms/?page=trimmomatic). The specifications use were:
3) Loop iterating through the trimmed files to submit to fastqc to check again
4) Alignment using Salmon: As opposed to simple counts, can correct for positional bias -l A (run automatically), for paired read -1 and -2 represent each of the pairs
5) DESeq sample conversion from Salmon output
6) DESeq


# Trimmomatic

Had some issues with naming system, I have changeed the naming as it was adding some extra information, as I had already ran the samples I renamed using:

``` cd /home/ar9416e/mosquito_test/trimmed_reads

for file in *.fastq.gz *.txt; do
  # Get base sample name (e.g., UJ-3092-25-1B)
  base=$(echo "$file" | sed -E 's/(_S[0-9]+_L[0-9]{3}_R[12]_001\.fastq\.gz)?_R[12]_(un)?paired\.fastq\.gz$//')
  base=$(echo "$base" | sed -E 's/(_S[0-9]+_L[0-9]{3}_R[12]_001\.fastq\.gz)?_trim_log\.txt$//')

  # Figure out the suffix
  if [[ "$file" == *"_R1_paired.fastq.gz" ]]; then
    suffix="_trimmed_R1_paired.fastq.gz"
  elif [[ "$file" == *"_R1_unpaired.fastq.gz" ]]; then
    suffix="_trimmed_R1_unpaired.fastq.gz"
  elif [[ "$file" == *"_R2_paired.fastq.gz" ]]; then
    suffix="_trimmed_R2_paired.fastq.gz"
  elif [[ "$file" == *"_R2_unpaired.fastq.gz" ]]; then
    suffix="_trimmed_R2_unpaired.fastq.gz"
  elif [[ "$file" == *"_trim_log.txt" ]]; then
    suffix="_trimmed_trim_log.txt"
  else
    echo "Skipping unknown file format: $file"
    continue
  fi

  new_name="${base}${suffix}"

  echo "Renaming: $file → $new_name"
  mv "$file" "$new_name"
done
```

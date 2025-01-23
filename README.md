# rnaseq_data_scripts

Pipeline to run RNA-seq

1) Fast QC, loop iterating through all fastq files (paired read) and then to run the fastqc.sh script to submit fastqc job to SLURM on HPC2
2) Loop iterating through same read files, then running trimmomatic.sh script to submit the job to SLURM to use trimmomatic (http://www.usadellab.org/cms/?page=trimmomatic). The specifications use were:
3) Loop iterating through the trimmed files to submit to fastqc to check again
4) Alignment using Salmon 

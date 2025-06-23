#!/bin/bash
#SBATCH --job-name=snakemake_run      # Job name
#SBATCH --partition=workq    # Partition (queue) name
#SBATCH --ntasks=1                    # Number of tasks (usually 1 for Snakemake)
#SBATCH --cpus-per-task=2             # Number of CPU cores per task
#SBATCH --mem=8G                     # Total memory per node
#SBATCH --output=snakemake_%j.log     # Standard output and error log
#SBATCH --error=snakemake_%j.err      # Error log
#SBATCH --mail-type=ALL               # Email notifications
#SBATCH --mail-user=danielpovedam@gmail.com  # Your email address

# Load necessary modules
module load devel/Miniconda/Miniconda3
module load bioinfo/ANGSD/0.940
module load bioinfo/samtools/1.18 
# Activate conda environment
source activate loco-pipe

# Run Snakemake
snakemake --use-conda --conda-frontend mamba \
  --directory /home/dpoveda/micetral/software/mice \
  --rerun-triggers mtime \
  --scheduler greedy \
  --printshellcmds \
  --snakefile /home/dpoveda/micetral/software/loco-pipe/workflow/pipelines/loco-pipe.smk \
  --profile /home/dpoveda/micetral/software/loco-pipe/workflow/profiles/slurm/ \
  --default-resources mem_mb=128000 disk_mb=none

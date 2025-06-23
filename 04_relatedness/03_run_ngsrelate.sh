#!/bin/bash
#SBATCH --job-name=ngs_relate       # Job name
#SBATCH --partition=workq           # Partition (queue) name
#SBATCH --ntasks=2                  # Number of tasks (usually 1)
#SBATCH --cpus-per-task=8           # Number of CPU cores per task
#SBATCH --mem=64G                  # Total memory
#SBATCH --output=ngsrelate_%A_%a.log     # Standard output and error log
#SBATCH --error=ngsrelate_%A_%a.err

# Load necessary modules

module load bioinfo/NgsRelate/2.0

ngsRelate -h concatenated_all_chromosomes.vcf.gz -O vcf.res

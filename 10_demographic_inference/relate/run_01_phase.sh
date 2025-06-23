#!/bin/bash
#SBATCH --job-name=filter_and_phase
#SBATCH --output=filter_and_phase_%A_%a.out
#SBATCH --error=filter_and_phase_%A_%a.err
#SBATCH --time=72:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=8
#SBATCH --array=1-19

# Load necessary modules
module load bioinfo/Bcftools/1.9
#module load bioinfo/SHAPEIT/2.r904

# List of chromosomes (one per array task)
CHROMS=(NC_000067.7 NC_000068.8 NC_000069.7 NC_000070.7 NC_000071.7 NC_000072.7 NC_000073.7 NC_000074.7 NC_000075.7 NC_000076.7 NC_000077.7 NC_000078.7 NC_000079.7 NC_000080.7 NC_000081.7 NC_000082.7 NC_000083.7 NC_000084.7 NC_000085.7)

# Get the chromosome for the current array task
CHR=${CHROMS[$SLURM_ARRAY_TASK_ID-1]}

# Directories
FILTERED_DIR=~/micetral/software/relate/filtered_vcfs_05
PHASED_DIR=~/micetral/software/relate/phased_vcfs

# Create output directories if they don't exist
mkdir -p $FILTERED_DIR
mkdir -p $PHASED_DIR

# Input and output VCFs
FILTERED_VCF=$FILTERED_DIR/${CHR}.vcf.gz
PHASED_OUTPUT=$PHASED_DIR/${CHR}.phased


# Step 2: Phase the filtered VCF using SHAPEIT
shapeit -V $FILTERED_VCF -O $PHASED_OUTPUT --thread 8


#!/bin/bash
#SBATCH --job-name=concat_vcf
#SBATCH --output=concat_vcf_%j.out
#SBATCH --error=concat_vcf_%j.err
#SBATCH --ntasks=1
#SBATCH --time=24:00:00
#SBATCH --mem=16G

# Load the bcftools module
module load bioinfo/Bcftools/1.9

# Define the directory with VCF files and the output file
VCF_DIR="/home/dpoveda/micetral/steps/06_angsd_results"
OUTPUT_VCF="$VCF_DIR/concatenated_all_chromosomes.vcf.gz"

# List all VCF files (ensure they are ordered by chromosome)
VCF_FILES=$(ls $VCF_DIR/angsd_NC_*.vcf.gz)

# Concatenate VCFs across chromosomes
bcftools concat -Oz -o $OUTPUT_VCF $VCF_FILES

# Index the concatenated VCF file
bcftools index $OUTPUT_VCF

echo "VCF files concatenated and indexed successfully."


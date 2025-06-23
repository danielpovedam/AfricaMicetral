#!/bin/bash
#SBATCH --cpus-per-task=2                    # Number of CPUs per task
#SBATCH --mem=16G                             # Memory allocation
#SBATCH --time=12:00:00                       # Runtime
#SBATCH --output=chr_filter_%A_%a.out         # Standard output
#SBATCH --error=chr_filter_%A_%a.err          # Standard error

# Load necessary modules
module load bioinfo/Bcftools/1.9
#module load bioinfo/tabix/1.18
#module load bioinfo/Beagle/4.0



# Extract common SNPs between the two VCF files (both high-coverage and imputed)
bcftools isec -n=2 -c all filtered_merged_swapped.vcf.gz subset_imputed_stitch.vcf.gz -O z -p common_snps


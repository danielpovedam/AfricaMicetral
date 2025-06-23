#!/bin/bash
# Load PLINK2 module
module load bioinfo/PLINK/2.00a4

# Define input and output file names
VCF="merged_common_variants.vcf.gz"
PREFIX="merged_common_variants"
PCA_PREFIX="pca_results"

# Step 1. Convert the VCF to PLINK binary format
plink2 --vcf ${VCF} --make-bed --out ${PREFIX}

# Step 2. Perform PCA (here computing the first 10 principal components)
plink2 --bfile ${PREFIX} --pca 10 --out ${PCA_PREFIX}

echo "PCA complete. Results saved with prefix: ${PCA_PREFIX}"


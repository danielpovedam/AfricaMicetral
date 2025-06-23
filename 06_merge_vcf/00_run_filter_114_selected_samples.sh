#!/bin/bash
# Script: filter_exome.sh
# Purpose: Filter exome VCF to:
#          1. Retain only samples in popexome.txt.
#          2. Keep only SNP variants.
#          3. Remove sites that become monomorphic after filtering.
# Author: Your Name
# Date: YYYY-MM-DD

# Set paths (adjust as needed)
DATA_DIR="/home/dpoveda/micetral/software/exone/data"
INPUT_VCF="$DATA_DIR/merged.renamed.vcf.gz"
SAMPLE_LIST="$DATA_DIR/popexome.txt"
INTERMEDIATE_VCF="$DATA_DIR/merged.renamed.filtered.vcf.gz"
FINAL_VCF="$DATA_DIR/merged.renamed.filtered_polymorphic.vcf.gz"

echo "=============================================="
echo "Starting exome VCF filtering process"
echo "----------------------------------------------"
echo "Input VCF: $INPUT_VCF"
echo "Sample list: $SAMPLE_LIST"
echo "=============================================="
echo ""

module load bioinfo/Bcftools/1.9 

# Step 1: Filter VCF to retain only the samples in the list and SNPs
echo "Step 1: Filtering for selected samples and SNP variants..."
echo "Running: bcftools view --samples-file $SAMPLE_LIST -Ou $INPUT_VCF | bcftools view -v snps -Oz -o $INTERMEDIATE_VCF"
bcftools view --samples-file "$SAMPLE_LIST" -Ou "$INPUT_VCF" | \
    bcftools view -v snps -Oz -o "$INTERMEDIATE_VCF"
if [ $? -ne 0 ]; then
    echo "Error during sample and SNP filtering. Exiting."
    exit 1
fi
echo "Intermediate VCF created: $INTERMEDIATE_VCF"
echo ""

# Index the intermediate VCF
echo "Indexing intermediate VCF..."
bcftools index "$INTERMEDIATE_VCF"
echo "Indexing completed."
echo ""

# Step 2: Remove monomorphic sites (where AC==0 or AC==AN)
echo "Step 2: Filtering out monomorphic sites..."
echo "Running: bcftools view -e 'AC==0 || AC==AN' -Oz -o $FINAL_VCF $INTERMEDIATE_VCF"
bcftools view -e 'AC==0 || AC==AN' -Oz -o "$FINAL_VCF" "$INTERMEDIATE_VCF"
if [ $? -ne 0 ]; then
    echo "Error during monomorphic site filtering. Exiting."
    exit 1
fi
echo "Final VCF with polymorphic sites: $FINAL_VCF"
echo ""

# Index the final VCF
echo "Indexing final VCF..."
bcftools index "$FINAL_VCF"
echo "Indexing of final VCF completed."
echo ""

echo "=============================================="
echo "Exome VCF filtering process completed successfully."
echo "Final output file: $FINAL_VCF"
echo "=============================================="


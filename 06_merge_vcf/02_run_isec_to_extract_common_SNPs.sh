#!/bin/bash
# Define file paths
EXOME_VCF="/home/dpoveda/micetral/software/exone/data/new/exome_lifted_mm39_gatk.vcf.gz"
IMPUTED_VCF="/home/dpoveda/micetral/software/exone/data/new/vcf_imputated_filtered_fixed_chr.vcf.gz"
SAMPLES_FILE="/home/dpoveda/micetral/software/exone/data/new/popexome_lcwgs.txt"
OUTPUT_DIR="/home/dpoveda/micetral/software/exone/data/new/isec_output_new_ref_v4"

module load bioinfo/Bcftools/1.9

# Create output directory if needed
mkdir -p "$OUTPUT_DIR"

##############################################
# Step 1. Identify common variant positions with bcftools isec
##############################################
bcftools isec -n =2 -O z -p "$OUTPUT_DIR/isec" "$EXOME_VCF" "$IMPUTED_VCF"

# Choose the intersection file.
# Typically, with two VCFs, the common variants are in "0002.vcf.gz".
if [ -f "$OUTPUT_DIR/isec/0002.vcf.gz" ]; then
    INTERSECTION_VCF="$OUTPUT_DIR/isec/0002.vcf.gz"
else
    echo "WARNING: Intersection file 0002.vcf.gz not found. Using 0001.vcf.gz instead."
    INTERSECTION_VCF="$OUTPUT_DIR/isec/0001.vcf.gz"
fi

##############################################
# Step 2. Extract common positions (CHROM and POS) from the intersection VCF
##############################################
COMMON_POSITIONS="$OUTPUT_DIR/common_positions.txt"
bcftools query -f '%CHROM\t%POS\n' "$INTERSECTION_VCF" > "$COMMON_POSITIONS"

##############################################
# Step 3. Merge original VCFs restricted to common positions,
#         then subset to only the desired samples,
#         filter for biallelic SNPs, and add AF/MAF tags.
##############################################
bcftools merge --force-samples -Ou -R "$COMMON_POSITIONS" "$EXOME_VCF" "$IMPUTED_VCF" | \
    bcftools view -Ou --samples-file "$SAMPLES_FILE" --force-samples | \
    bcftools view -Ou -m2 -M2 --type snps | \
    bcftools +fill-tags -Oz -o "$OUTPUT_DIR/merged_common_variants.vcf.gz"

##############################################
# Step 4. Index the final merged VCF
##############################################
bcftools index --tbi "$OUTPUT_DIR/merged_common_variants.vcf.gz"

echo "Merged VCF created and indexed at: $OUTPUT_DIR/merged_common_variants.vcf.gz"


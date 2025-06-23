#!/bin/bash

# Set paths
VCF_DIR="/work/project/Micetral/software/gone/data/subsets"
VCF_FILE="$VCF_DIR/vcf_imputated_filtered_fixed.vcf.gz"
POP_FILE_LIST="/work/project/Micetral/software/gone/data/subsets/listPop"

# Read population files from the listPop file
while IFS= read -r POP_FILE; do
  # Extract population name
  POP_NAME=$(basename "$POP_FILE" .txt)
  OUTPUT_VCF="$VCF_DIR/${POP_NAME}.vcf.gz"

  # Run a background job for each population file
  sbatch <<EOT
#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=02:00:00
#SBATCH --job-name=subset_vcf_${POP_NAME}
#SBATCH --output=/work/project/Micetral/software/gone/data/subsets/logs/${POP_NAME}_%A.out

module load bioinfo/Bcftools/1.9

echo "Processing $POP_NAME..."

# Subset VCF by population
bcftools view -S "$VCF_DIR/$POP_FILE" -Oz -o "$OUTPUT_VCF" "$VCF_FILE"

# Remove monomorphic sites
bcftools view -c 1 -Oz -o "$VCF_DIR/${POP_NAME}_filtered.vcf.gz" "$OUTPUT_VCF"

# Remove intermediate unfiltered VCF
rm "$OUTPUT_VCF"

echo "Subsetting and filtering for $POP_NAME completed."
EOT

done < "$POP_FILE_LIST"










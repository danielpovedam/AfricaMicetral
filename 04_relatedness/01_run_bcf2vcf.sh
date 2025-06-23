#!/bin/bash
#SBATCH --job-name=bcf_to_vcf_by_chromosome
#SBATCH --output=bcf_to_vcf_by_chromosome.out
#SBATCH --error=bcf_to_vcf_by_chromosome.err
#SBATCH --mem=32G
#SBATCH --ntasks=2

# Load bcftools module
module load bioinfo/Bcftools/1.9

# Path to BCF files and chromosome list
BCF_DIR="/home/dpoveda/micetral/steps/06_angsd_results"
CHROM_LIST="/home/dpoveda/micetral/steps/06_angsd_results/chromosome.list"

# Loop through each chromosome in the list
while read -r CHROM; do
    # Find the corresponding BCF file for the chromosome
    BCF_FILE="$BCF_DIR/angsd_${CHROM}.bcf"

    # Check if the BCF file exists
    if [ -f "$BCF_FILE" ]; then
        echo "Processing chromosome $CHROM..."

        # Convert BCF to VCF and compress it to VCF.GZ
        bcftools view "$BCF_FILE" -Oz -o "${BCF_FILE%.bcf}.vcf.gz"

        # Index the resulting VCF.GZ file
        bcftools index "${BCF_FILE%.bcf}.vcf.gz"

        echo "Finished processing $CHROM"
    else
        echo "BCF file for chromosome $CHROM not found!"
    fi

done < "$CHROM_LIST"



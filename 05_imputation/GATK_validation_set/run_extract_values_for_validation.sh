#!/bin/bash
#SBATCH --cpus-per-task=2                    # Number of CPUs per task
#SBATCH --mem=16G                             # Memory allocation
#SBATCH --time=12:00:00                       # Runtime


# Load necessary modules
module load bioinfo/Bcftools/1.9



bcftools query -f '%CHROM\t%POS\t%REF\t%ALT[\t%GT]\n' common_snps/0000.vcf.gz > common_snps/filtered_final_genotypes.txt

bcftools query -f '%CHROM\t%POS\t%REF\t%ALT[\t%GT]\n' common_snps/0001.vcf.gz > common_snps/imputed_genotypes.txt

bcftools query -f '%CHROM\t%POS\t%REF\t%ALT[\t%DS]\n' common_snps/0001.vcf.gz > imputed_dosage.txt


#!/bin/bash
#SBATCH --job-name=filter_merge_sort
#SBATCH --output=/home/dpoveda/micetral/software/imputation/gatk/merged_filter_final_vcf_%j.log
#SBATCH --error=/home/dpoveda/micetral/software/imputation/gatk/merged_filter_final_vcf_%j.err
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G

# Load required modules
module load bioinfo/Bcftools/1.9 # Ensure bcftools is loaded
module load bioinfo/GATK/4.2.6.1   # Ensure GATK is loaded

# Set variables
WORKDIR="/home/dpoveda/micetral/software/imputation/gatk"
OUTPUT_PREFIX="merged_filtered_variants"


cd "$WORKDIR"


# Step 2: Merge 
echo "Merging filtered VCFs..."
bcftools merge -o merged_shared_genotypes.vcf.gz -Oz ERR899393_final_variants.vcf.gz ERR899394_final_variants.vcf.gz ERR899395_final_variants.vcf.gz ERR899396_raw_variants.vcf.gz ERR899397_final_variants.vcf.gz ERR899398_final_variants.vcf.gz ERR899399_raw_variants.vcf.gz ERR899400_raw_variants.vcf.gz ERR899401_final_variants.vcf.gz ERR899402_raw_variants.vcf.gz ERR899403_final_variants.vcf.gz ERR899404_final_variants.vcf.gz ERR899405_raw_variants.vcf.gz ERR899407_raw_variants.vcf.gz ERR899409_raw_variants.vcf.gz ERR899410_raw_variants.vcf.gz ERR899411_raw_variants.vcf.gz ERR899415_raw_variants.vcf.gz ERR899416_raw_variants.vcf.gz


# Step 3 filtering missing genotypes




bcftools view -i 'GT!="./."' merged_shared_genotypes.vcf.gz -O z -o filtered_merged.vcf.gz




# Step 4: Index the sorted VCF with GATK
echo "Indexing the sorted VCF..."
gatk IndexFeatureFile -I  filtered_merged.vcf.gz

echo "Done!"


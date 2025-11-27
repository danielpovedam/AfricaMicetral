#!/bin/bash
#SBATCH --job-name=vcf_filter_stepwise
#SBATCH --output=vcf_filter_stepwise_%A_%a.out
#SBATCH --error=vcf_filter_stepwise_%A_%a.err
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --array=1-19%19

module load bioinfo/Bcftools/1.9

# Directories
VCF_DIR=~/micetral/software/gone/filtered_vcfs_05
OUT_DIR=~/micetral/software/gone/filtered_vcfs_stepwise_0.99
LOG_DIR=${OUT_DIR}/logs

mkdir -p ${OUT_DIR} ${LOG_DIR}

# File list
VCF_LIST=($(ls ${VCF_DIR}/NC_*.vcf.gz))
VCF=${VCF_LIST[$SLURM_ARRAY_TASK_ID-1]}
CHR=$(basename ${VCF} .vcf.gz)

echo "Processing $CHR"

# Step 0: Original count
N_ORIG=$(bcftools view -H ${VCF} | wc -l)

# Step 1: INFO/INFO_SCORE >= 0.99
bcftools view -i 'INFO/INFO_SCORE>=0.99' -Oz -o ${OUT_DIR}/${CHR}.info.vcf.gz ${VCF}
bcftools index -f ${OUT_DIR}/${CHR}.info.vcf.gz
N_INFO=$(bcftools view -H ${OUT_DIR}/${CHR}.info.vcf.gz | wc -l)

# Step 2: F_MISSING <= 0.05
bcftools view -e 'F_MISSING>0.01' -Oz -o ${OUT_DIR}/${CHR}.final.vcf.gz ${OUT_DIR}/${CHR}.info.vcf.gz
bcftools index -f ${OUT_DIR}/${CHR}.final.vcf.gz
N_MISS=$(bcftools view -H ${OUT_DIR}/${CHR}.final.vcf.gz | wc -l)


# Calculate losses
L_INFO=$((N_ORIG - N_INFO))
L_MISS=$((N_INFO - N_MISS))
L_TOTAL=$((N_ORIG - N_MISS))

# Write log entry
echo -e "${CHR}\t${N_ORIG}\t${N_INFO}\t${N_MISS}\t${L_INFO}\t${L_MISS}\t${L_TOTAL}" \
  >> ${LOG_DIR}/snp_filter_stepwise_summary.tsv


#!/bin/bash -l
#SBATCH -J filter

#SBATCH --ntasks=16
#SBATCH --mem=16GB

module load bioinfo/VCFtools/0.1.16

module load bioinfo/Bcftools/1.9
module load bioinfo/PLINK/2.00a4
module load bioinfo/PLINK/1.90b7
#vcftools --gzvcf high_confidence_snps_stitch_maf05.vcf.gz --max-missing 0.9 --recode --recode-INFO-all --out high_conf_filtered

#vcftools --vcf high_conf_filtered.recode.vcf --missing-indv --out filtered_missing_data_individuals

#bgzip -c high_conf_filtered.recode.vcf > high_conf_filtered.vcf.gz

#plink2 --bfile roh_analysis --geno 0.05 --mind 0.05 --allow-extra-chr --make-bed --out roh_filtered

plink --bfile roh_filtered \
  --allow-extra-chr \
  --homozyg \
  --homozyg-density 100 \
  --homozyg-kb 500 \
  --homozyg-snp 50 \
  --homozyg-window-het 5 \
  --homozyg-window-missing 20 \
  --homozyg-window-snp 50 \
  --out roh_results


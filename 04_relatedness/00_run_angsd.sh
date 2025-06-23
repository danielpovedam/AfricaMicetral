#!/bin/bash
#SBATCH -J angsd_analysis
#SBATCH -o /home/dpoveda/micetral/logs/angsd_to_vcf_%j_%a.out
#SBATCH -e /home/dpoveda/micetral/logs/angsd_to_vcf_%j_%a.err
#SBATCH -t 72:00:00
#SBATCH -p workq
#SBATCH --array=1-19%19  # Adjust to the number of chromosomes
#SBATCH --ntasks=4
#SBATCH --mem=32G

# Load necessary modules
module purge
module load bioinfo/ANGSD/0.940

# Set paths
BAM_LIST=/work/project/Micetral/software/mouse/docs/bamlist.txt
REF_GENOME=/home/dpoveda/micetral/data/raw/reference_genome/GCF_000001635.27_GRCm39_genomic.fna
CHROM_LIST=/home/dpoveda/micetral/scripts/07_angsd/chromosome.list  # Adjust to the actual path
SITES_DIR=/home/dpoveda/micetral/software/mouse/angsd/snp_calling_global/sites/subsampled

# Get chromosome for this task
chr=$(sed -n "$SLURM_ARRAY_TASK_ID"p $CHROM_LIST)
echo "### Chromosome: $chr"

# Define SNP list file based on chromosome
snp_list="${SITES_DIR}/${chr}.subsampled.snp_list"
echo "SNP list: $snp_list"

# Number of individuals (half the number of lines in bam.list)
nind=$(wc -l < $BAM_LIST)
minInd=$((nind / 2))
echo "Number of individuals: $nind"
echo "Minimum individuals: $minInd"

# Run ANGSD with the sites option
angsd -nThreads 4 \
  -b $BAM_LIST \
  -ref $REF_GENOME \
  -out /home/dpoveda/micetral/steps/06_angsd_results/angsd_${chr} \
  -r $chr \
  -sites $snp_list \
  -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -skipTriallelic 1 -trim 0 -C 50 -baq 1 \
  -minMapQ 20 -minInd $minInd -minQ 20 -setMinDepthInd 1 -setMaxDepthInd 15 \
  -setMinDepth 716 -setMaxDepth 1245 -minmaf 0.05 \
  -doCounts 1 -GL 2 -doGlf 3 -doMajorMinor 1 -doMaf 1 -SNP_pval 1e-6 \
  -dobcf 1 -doPost 1 -doGeno 32 -doPlink 2

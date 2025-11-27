#!/bin/bash
#SBATCH --job-name=heterozygosity      # Job name
#SBATCH --partition=workq              # Partition name
#SBATCH --ntasks=1                     # Number of tasks
#SBATCH --cpus-per-task=8              # Threads per task
#SBATCH --mem=64G                      # Memory per task
#SBATCH --time=24:00:00                # Max runtime
#SBATCH --output=heterozygosity_%A_%a.out
#SBATCH --error=heterozygosity_%A_%a.err
#SBATCH --array=1-360                  # Adjust to the number of individuals

# ========================
# Load software
# ========================
module load bioinfo/ANGSD/0.940
module load bioinfo/htslib/1.14

# ========================
# Paths and files
# ========================
# BAM list file — one sample per line
SAMPLE_LIST="/home/dpoveda/micetral/software/mouse/docs/bamlist.txt"
REF="/home/dpoveda/micetral/data/raw/reference_genome/GCF_000001635.27_GRCm39_genomic.fna"
OUT_DIR="/home/dpoveda/micetral/software/mouse/heterozygosity_ind"
mkdir -p "$OUT_DIR"

# ========================
# Get the sample for this array job
# ========================
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SAMPLE_LIST})
BAM="/path/to/bams/${SAMPLE}.bam"

# ========================
# Run ANGSD to estimate SAF
# ========================
echo "Processing $SAMPLE..."

angsd -i $BAM -anc $REF -dosaf 1 -gl 2 -ref $REF -C 50 -minMapQ 30 -minQ 30 -nThreads 8 -out $OUT_DIR/${SAMPLE}

# ========================
# Estimate SFS with realSFS
# ========================
realSFS $OUT_DIR/${SAMPLE}.saf.idx > $OUT_DIR/${SAMPLE}.sfs

# ========================
# Parse heterozygosity
# ========================
# SFS file contains 3 numbers: hom-anc, het, hom-der
HOM_ANC=$(awk '{print $1}' $OUT_DIR/${SAMPLE}.sfs)
HET=$(awk '{print $2}' $OUT_DIR/${SAMPLE}.sfs)
HOM_DER=$(awk '{print $3}' $OUT_DIR/${SAMPLE}.sfs)
TOTAL=$(echo "$HOM_ANC + $HET + $HOM_DER" | bc -l)
HET_PROP=$(echo "$HET / $TOTAL" | bc -l)

# Save heterozygosity proportion per individual
echo -e "${SAMPLE}\t${HET_PROP}" >> $OUT_DIR/heterozygosity_per_individuals.tsv


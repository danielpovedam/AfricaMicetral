#!/bin/bash
#SBATCH --job-name=relate_generate_annotations
#SBATCH --output=logs/generate_annotations_%A_%a.out
#SBATCH --error=logs/generate_annotations_%A_%a.err
#SBATCH --array=1-19%5   # Adjust based on the number of chromosomes in chr_list.txt
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=72:00:00

# Load necessary modules
module load devel/Miniconda/Miniconda3

# Set file paths
CHROM_LIST="/home/dpoveda/micetral/software/mouse/docs/chr_list.txt"
CHROM=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $CHROM_LIST)   # Get the chromosome for this array task
HAPS_FILE="/home/dpoveda/micetral/software/relate/phased_vcfs/${CHROM}.phased.haps"
SAMPLE_FILE="/home/dpoveda/micetral/software/relate/phased_vcfs/${CHROM}.phased.sample"
POP_LABELS="/home/dpoveda/micetral/software/relate/pop_info/mmd.poplabels"

# Create output directories if they don't exist
OUTPUT_DIR="/home/dpoveda/micetral/software/relate/annotations_relate"
LOG_DIR="/home/dpoveda/micetral/software/relate/logs"
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

# Run Relate for SNP annotations
/home/dpoveda/micetral/software/relate/relate/bin/RelateFileFormats \
    --mode GenerateSNPAnnotations \
    --haps $HAPS_FILE \
    --sample $SAMPLE_FILE \
    --poplabels $POP_LABELS \
    -o ${OUTPUT_DIR}/${CHROM}

echo "Job for $CHROM completed."


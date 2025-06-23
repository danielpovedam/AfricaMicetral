#!/bin/bash
#SBATCH --job-name=relate_all
#SBATCH --output=logs_relate/relate_%A_%a.out
#SBATCH --error=logs_relate/relate_%A_%a.err
#SBATCH --array=1-19%5  # Adjust the range based on the number of chromosomes in chr_list.txt
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=72:00:00

# Ensure required directories exist
mkdir -p logs_relate
mkdir -p output_relate

# Paths and parameters
CHR_LIST="/home/dpoveda/micetral/software/mouse/docs/chr_list.txt"
CHROM=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $CHR_LIST)
HAPS_FILE="/home/dpoveda/micetral/software/relate/phased_vcfs/${CHROM}.phased.haps"
SAMPLE_FILE="/home/dpoveda/micetral/software/relate/phased_vcfs/${CHROM}.phased.sample"
ANNOT_FILE="/home/dpoveda/micetral/software/relate/annotations_relate/${CHROM}.annot"
MAP_FILE="/home/dpoveda/micetral/software/relate/block_penalty100/${CHROM}.map"

# Output file prefix (must be in the current working directory)
OUTPUT_PREFIX="${CHROM}"

# Run Relate for the specified chromosome
/home/dpoveda/micetral/software/relate/relate/bin/Relate \
    --mode All \
    -m 6e-9 \
    -N 212000 \
    --haps $HAPS_FILE \
    --sample $SAMPLE_FILE \
    --annot $ANNOT_FILE \
    --map $MAP_FILE \
    --seed 1 \
    -o $OUTPUT_PREFIX

# Move output files to the output directory
mv ${OUTPUT_PREFIX}* output_relate/

echo "Chromosome ${CHROM} processing completed."


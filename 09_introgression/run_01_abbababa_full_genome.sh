#!/bin/bash
#SBATCH --job-name=abba_sequential
#SBATCH --output=logs/abba_seq_%A_%a.out
#SBATCH --error=logs/abba_seq_%A_%a.err
#SBATCH --time=72:00:00
#SBATCH --mem=128G
#SBATCH --cpus-per-task=4

# Load ANGSD module
module load bioinfo/ANGSD/0.940

# Set working directory
WORK_DIR="/home/dpoveda/micetral/software/introgression/abbababa/all_genome"
cd "$WORK_DIR"

# Define common input files
REGIONS_FILE="regions_array.txt"

# Run ABBA-BABA sequentially for each bamlist and sizeFile pair (2 to 13)
for i in {1..25}; do
    BAM_LIST="bamlist${i}.txt"
    SIZEFILE="sizeFile${i}.txt"
    
    if [[ -f "$BAM_LIST" && -f "$SIZEFILE" ]]; then
        echo "Processing: $BAM_LIST and $SIZEFILE"

        angsd -doAbbababa2 1 \
              -doCounts 1 \
              -bam "$BAM_LIST" \
              -sizeFile "$SIZEFILE" \
              -rf "$REGIONS_FILE" \
              -useLast 1 \
              -minQ 20 \
              -minMapQ 30 \
              -blockSize 500000 \
              -out "abbababa_output_${i}"

        echo "Finished processing: $BAM_LIST and $SIZEFILE"
    else
        echo "Skipping missing files: $BAM_LIST or $SIZEFILE"
    fi
done

echo "All jobs completed."


#!/bin/bash
#SBATCH --job-name=run_DSTAT
#SBATCH --output=run_DSTAT_%j.out
#SBATCH --error=run_DSTAT_%j.err
#SBATCH --time=72:00:00
#SBATCH --mem=128G
#SBATCH --cpus-per-task=4

# Load an appropriate R module (adjust version as needed)
module load devel/Miniconda/Miniconda3
source activate bio-env

# Set working directory
cd /home/dpoveda/micetral/software/introgression/abbababa/all_genome

# Loop from 2 to 13 and process each dataset sequentially
for i in {1..25}; do
    SIZEFILE="sizeFile${i}.txt"
    NAMEFILE="popNames${i}.name"
    ANGSD_OUT="abbababa_output_${i}"
    RESULT_OUT="result_${i}"
    
    if [[ -f "$SIZEFILE" && -f "$NAMEFILE" ]]; then
        echo "Processing: $ANGSD_OUT with $SIZEFILE and $NAMEFILE"
        Rscript ../DSTAT angsdFile="$ANGSD_OUT" out="$RESULT_OUT" sizeFile="$SIZEFILE" nameFile="$NAMEFILE"
        echo "Finished processing: $ANGSD_OUT"
    else
        echo "Skipping missing files: $SIZEFILE or $NAMEFILE"
    fi

done


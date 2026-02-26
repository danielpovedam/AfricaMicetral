#!/bin/bash
#SBATCH --job-name=treemix_analysis
#SBATCH --output=treemix_analysis.out
#SBATCH --error=treemix_analysis.err
#SBATCH --time=48:00:00
#SBATCH --mem=12G
#SBATCH --cpus-per-task=4
#SBATCH --partition=workq
#SBATCH --chdir=/home/dpoveda/micetral/software/mmd/treemix/old_angsd

# Load modules
module load bioinfo/PHYLIP/3.697
module load bioinfo/TreeMix/1.13

# Input variables
INPUT_FILE="mice_final.gz"
CORES=30
OUTGROUP="OUTGROUP"
BOOTSTRAP=1000
CONSENSE="/usr/local/bioinfo/src/PHYLIP/phylip-3.697/exe/consense"
OUTPUT_DIR="mice_output"
M_MIN=0
M_MAX=10
REPLICATES=50     # important for Evanno variance

mkdir -p ${OUTPUT_DIR}

echo "Starting TreeMix with variable block sizes to enable Evanno method."

for m in $(seq $M_MIN $M_MAX); do
    for r in $(seq 1 $REPLICATES); do
        
        # Random block size between 300–900 (introduces variance for OptM Evanno)
        BLOCK_SIZE=$(( ( RANDOM % 600 ) + 300 ))

        OUT_PREFIX="${OUTPUT_DIR}/treemix.${m}.${r}"
        
        echo "Running m=$m replicate=$r with block size k=$BLOCK_SIZE"

        treemix \
            -i $INPUT_FILE \
            -o $OUT_PREFIX \
            -m $m \
            -root $OUTGROUP \
            -k $BLOCK_SIZE \
            -global \
            -se \
            -noss \
            -bootstrap \
            >/dev/null 2>&1
    done
done

echo "TreeMix analyses complete."
echo "Now your folder contains variance in likelihoods and OptM (Evanno method) will work."


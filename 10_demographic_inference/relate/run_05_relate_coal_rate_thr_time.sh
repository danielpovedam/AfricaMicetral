#!/bin/bash
#SBATCH --job-name=relate_coalescence
#SBATCH --output=logs_relate_coalescence/relate_coalescence_%j.out
#SBATCH --error=logs_relate_coalescence/relate_coalescence_%j.err
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=72:00:00

module load devel/Miniconda/Miniconda3
source activate bio-env

# Ensure required directories exist
mkdir -p logs_relate_coalescence
mkdir -p output_relate_coalescence

# Paths and parameters
POP_LABELS="/home/dpoveda/micetral/software/relate/pop_info/mmd.poplabels"
CHR_LIST="/home/dpoveda/micetral/software/relate/chr_list.txt"
OUTPUT_PREFIX="/home/dpoveda/micetral/software/relate/output_relate_coalescence/coalescence"
MUTATION_RATE="6e-9"

# Run the coalescence rate estimation
/home/dpoveda/micetral/software/relate/relate/bin/RelateCoalescentRate \
    --mode EstimatePopulationSize \
    -i /home/dpoveda/micetral/software/relate/output_relate_popsize_all_pops/popsize \
    -o /home/dpoveda/micetral/software/relate/output_relate_coalescence/coalescence \
    -m $MUTATION_RATE \
    --poplabels $POP_LABELS \
    --first_chr 1 \
    --last_chr 19 \
    --years_per_gen 0.5 \
    --bins 0,7,0.25

echo "Coalescence rate estimation completed."


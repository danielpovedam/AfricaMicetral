#!/bin/bash
#SBATCH --job-name=relate_finalize
#SBATCH --output=logs_relate_finalize/relate_finalize_%j.out
#SBATCH --error=logs_relate_finalize/relate_finalize_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=24:00:00

module load devel/Miniconda/Miniconda3
source activate bio-env

# Ensure required directories exist
mkdir -p logs_relate_finalize
mkdir -p output_relate_finalize

# Run the finalization of population size estimation
/home/dpoveda/micetral/software/relate/relate/bin/RelateCoalescentRate  \
    --mode FinalizePopulationSize \
    --poplabels /home/dpoveda/micetral/software/relate/pop_info/mmd.poplabels \
    -i /home/dpoveda/micetral/software/relate/output_relate_popsize_all_pops/popsize.pairwise \
    -o /home/dpoveda/micetral/software/relate/output_relate_finalize/finalized

echo "Population size finalization completed."


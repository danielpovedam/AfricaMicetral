#!/bin/bash
#SBATCH --job-name=relate_popsize
#SBATCH --output=logs_relate_popsize/relate_popsize2_%j.out
#SBATCH --error=logs_relate_popsize/relate_popsize2_%j.err
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=72:00:00


module load devel/Miniconda/Miniconda3
source activate bio-env

# Ensure required directories exist
mkdir -p logs_relate_popsize
mkdir -p output_relate_popsize_all_pops

# Paths and parameters
RELATE_SCRIPT="/home/dpoveda/micetral/software/relate/relate/scripts/EstimatePopulationSize/EstimatePopulationSize.sh"
#INPUT_PREFIX="/home/dpoveda/micetral/software/relate/output_relate/mmd"
POP_LABELS="/home/dpoveda/micetral/software/relate/pop_info/mmd.poplabels"
CHR_LIST="/home/dpoveda/micetral/software/relate/chr_list.txt"
#OUTPUT_PREFIX="output_relate_popsize_all_pops"
MUTATION_RATE="6e-9"
SEED=1

# Run the script
bash $RELATE_SCRIPT \
    -i /home/dpoveda/micetral/software/relate/output_relate/mmd \
    -m $MUTATION_RATE \
    --years_per_gen 0.5 \
    --bins 0,7,0.25 \
    --poplabels $POP_LABELS \
    --pop_of_interest ALGO,BENC,FRAF,FRAM,FRAT,GABF,GABM,GABN,GBRL,GERC,GERCB,IRAA,ISRK,ISRS,ITAC,LEBE,MALB,MORC,MORT,NIGN,SEND,SENK,SENS,SPAC,TUNB,USAB,USAF,USAG,USAN,USAP,USAV \
    --first_chr 1 \
    --last_chr 19 \
    --seed $SEED \
    -o /home/dpoveda/micetral/software/relate/output_relate_popsize_all_pops/popsize \
    --threads 32

echo "Population size estimation completed."


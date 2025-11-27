#!/bin/bash
#SBATCH --job-name=rzoo_array
#SBATCH --output=rzoo_morgan_clean%A_%a.out
#SBATCH --error=rzoo_morgan_clean%A_%a.err
#SBATCH --array=1-26
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=72:00:00

module load devel/Miniconda/Miniconda3
source activate bio-env


POPS=(ALGO BENC FRAF FRAM FRAT GABF GABM GABN GBRL GERC GERB IRAA ISRK ISRS ITAC LEBE MALB MORC MORT NIGN SEND SENK SENS SPAC TUNB USA)

POP=${POPS[$SLURM_ARRAY_TASK_ID-1]}
echo "Running rZooRoH for population $POP"

Rscript /home/dpoveda/micetral/software/rzooroh/run_rzoo_pop.R $POP


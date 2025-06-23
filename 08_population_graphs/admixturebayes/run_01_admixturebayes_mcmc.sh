#!/bin/bash
#SBATCH --job-name=run_admixbaye      # Job name
#SBATCH --partition=unlimitq    # Partition (queue) name
#SBATCH --ntasks=8                    # Number of tasks (usually 1 for Snakemake)
#SBATCH --mem=8G                     # Total memory per node
#SBATCH --output=admix_%j.log     # Standard output and error log
#SBATCH --error=admix_%j.err      # Error log
#SBATCH --mail-type=ALL               # Email notifications
#SBATCH --mail-user=danielpovedam@gmail.com  # Your email address


# Run 
for i in {1..3}
do
python runMCMC.py --input_file house_mouse.txt --outgroup OUTGROUP --n 500000 --result_file  chain${i}.txt --MCMC_chains 40 --max_admixes 5

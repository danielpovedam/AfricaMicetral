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
mkdir resultsadm.${i}
cd resultsadm.${i}
python ./admixturebayes/analyzeSamples.py --mcmc_results chain${i}.txt
cd ..
done

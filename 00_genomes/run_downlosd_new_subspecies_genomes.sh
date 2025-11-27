#!/bin/bash
#SBATCH --job-name=download_CRA018990
#SBATCH --partition=workq
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=72:00:00
#SBATCH --output=download.%j.out
#SBATCH --error=download.%j.err

#module load lftp   # or wget, depending on availability

# Use lftp for robust download
lftp -c "open ftp://download.big.ac.cn; mirror --parallel=4 --continue --verbose /gsa4/CRA018990 ./CRA018990"


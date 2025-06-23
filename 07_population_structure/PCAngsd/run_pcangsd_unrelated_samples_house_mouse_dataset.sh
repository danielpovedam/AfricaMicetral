#!/bin/bash
#SBATCH --job-name=pcangsd_pca
#SBATCH --output=pcangsd_pca.out
#SBATCH --error=pcangsd_pca.err
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --partition=workq

# Load the module (if needed)
module load bioinfo/PCAngsd/0.99

# Define input/output variables
PCANGSD="/home/dpoveda/micetral/software/pca_pcangsd/pcangsd"
BEAGLE="/home/dpoveda/micetral/software/pca_pcangsd/house_mouse2.beagle.gz"
OUT="/home/dpoveda/micetral/software/pca_pcangsd/house_mouse_pca"
LOG="/home/dpoveda/micetral/software/pca_pcangsd/pcangsd.log"

# Run PCAngsd
python $PCANGSD -beagle $BEAGLE -minMaf 0.05 -threads 8 -o $OUT > $LOG 2>&1

# Run PCA with eigenvalues up to 12
python $PCANGSD -e 12 -beagle $BEAGLE -minMaf 0.05 -threads 8 -o ${OUT}_e12 > ${LOG}_e12.log 2>&1



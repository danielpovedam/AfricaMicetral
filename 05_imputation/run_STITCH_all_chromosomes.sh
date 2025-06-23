#!/bin/bash
#SBATCH --job-name=STITCH_all_chrs     # Job name
#SBATCH --partition=unlimitq              # Partition (queue) name
#SBATCH --ntasks=1                     # Number of tasks
#SBATCH --cpus-per-task=4              # Number of CPU cores per task
#SBATCH --mem=32G                      # Total memory per node
#SBATCH --output=STITCH_all_chrs_%j.log # Standard output log
#SBATCH --error=STITCH_all_chrs_%j.err  # Error log

# Load necessary modules
module load devel/Miniconda/Miniconda3
module load bioinfo/Bcftools/1.9
# Activate conda environment
source activate bio-env

# Define working directory and input files
WORK_DIR="/home/dpoveda/micetral/software/STITCH/mice_imputation"
BAMLIST="/work/project/Micetral/software/mouse/docs/bamlist.txt"
CHR_LIST="/home/dpoveda/micetral/software/STITCH/mice_imputation/sites/chr_list.txt"  # Path to the chromosome list

# Change to the working directory
cd $WORK_DIR

# Set K and nGen values
K=10
nGen=$(( (4 * 106000) / K ))

# Loop through each chromosome in chr_list.txt
while IFS= read -r CHR; do
    echo "Processing chromosome: $CHR"
    
    # Define posfile and output directory based on chromosome
    POSFILE="/work/project/Micetral/software/mouse/angsd/snp_calling_global/sites/${CHR}.snp_list"
    OUTPUT_DIR="${WORK_DIR}/results_${CHR}_K${K}"
    mkdir -p $OUTPUT_DIR

    # Run STITCH for the current chromosome
    /home/dpoveda/micetral/software/STITCH/STITCH.R \
        --chr=$CHR \
        --bamlist=$BAMLIST \
        --posfile=$POSFILE \
        --sampleNames_file=$SAMPLES \
        --outputdir=$OUTPUT_DIR \
        --K=$K \
        --nGen=$nGen \
        --nCores=4  # Reduced core count to avoid memory issues

    echo "Completed STITCH for chromosome: $CHR"
done < "$CHR_LIST"

echo "All chromosomes processed."


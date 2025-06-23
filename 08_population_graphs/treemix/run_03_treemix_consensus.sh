#!/bin/bash
#SBATCH --job-name=treemix_analysis_s3      # Job name
#SBATCH --output=treemix_analysis_s3.out    # Standard output and error log
#SBATCH --error=treemix_analysis_s3.err     # Error log
#SBATCH --time=24:00:00                  # Time limit hrs:min:sec
#SBATCH --mem=16G                        # Memory limit
#SBATCH --cpus-per-task=4                # Number of CPU cores per task
#SBATCH --partition=workq              # Partition to run on

# Set the working directory
#SBATCH --chdir=/home/dpoveda/micetral/software/mmd/treemix/old_angsd

# Load necessary modules
module load bioinfo/PHYLIP/3.697
module load bioinfo/TreeMix/1.13   # Adjust based on your environment

# Set variables for the script
INPUT_FILE="mice_final.gz"
CORES=30
BLOCK_SIZE=300
OUTGROUP="OUTGROUP"
BOOTSTRAP=1000
CONSENSE="/usr/local/bioinfo/src/PHYLIP/phylip-3.697/exe/consense"
OUTPUT_DIR="mice_output"
M=1
REPLICATES=25

# Run the Step1_TreeMix.sh script with the specified arguments
bash Step3_TreeMix.sh $INPUT_FILE $CORES $BLOCK_SIZE $OUTGROUP $BOOTSTRAP $M MICE_OUT $REPLICATES mice_output_constree.newick $CONSENSE



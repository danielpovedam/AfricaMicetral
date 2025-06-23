#!/bin/bash
#SBATCH --job-name=filter_missing_data
#SBATCH --output=filter_missing_data_%A_%a.out
#SBATCH --error=filter_missing_data_%A_%a.err
#SBATCH --time=24:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4

# Load the required module
module load bioinfo/Bcftools/1.9

# Define input and output directories
INPUT_DIR=~/micetral/software/relate/split_vcfs
OUTPUT_DIR=~/micetral/software/relate/filtered_vcfs_05

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

#!/bin/bash
#SBATCH --job-name=split_vcf   # Job name
#SBATCH --output=split_vcf_%A_%a.out  # Standard output log
#SBATCH --error=split_vcf_%A_%a.err   # Standard error log
#SBATCH --time=02:00:00       # Time limit (hh:mm:ss)
#SBATCH --cpus-per-task=4     # Number of CPU cores
#SBATCH --mem=8G              # Memory per node
#SBATCH --array=1-19          # Array for chromosomes 1-19 (adjust as needed)

# Load bcftools module
module load bioinfo/Bcftools/1.9

# Set paths
INPUT_VCF="/home/dpoveda/micetral/software/relate/filtered_high_confidence.vcf.gz"
OUTPUT_DIR="/home/dpoveda/micetral/software/relate/split_vcfs"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Chromosome mapping
CHROMOSOMES=(
    "NC_000067.7"
    "NC_000068.8"
    "NC_000069.7"
    "NC_000070.7"
    "NC_000071.7"
    "NC_000072.7"
    "NC_000073.7"
    "NC_000074.7"
    "NC_000075.7"
    "NC_000076.7"
    "NC_000077.7"
    "NC_000078.7"
    "NC_000079.7"
    "NC_000080.7"
    "NC_000081.7"
    "NC_000082.7"
    "NC_000083.7"
    "NC_000084.7"
    "NC_000085.7"
)

# Get the chromosome ID based on the SLURM array task ID
CHR="${CHROMOSOMES[$SLURM_ARRAY_TASK_ID-1]}"  # SLURM_ARRAY_TASK_ID is 1-based; arrays in bash are 0-based.

# Split VCF by chromosome
bcftools view -r $CHR $INPUT_VCF -Oz -o ${OUTPUT_DIR}/${CHR}.vcf.gz

# Index the split VCF
bcftools index ${OUTPUT_DIR}/${CHR}.vcf.gz

# Loop over all VCF files in the input directory
for VCF in $INPUT_DIR/*.vcf.gz; do
    # Extract the file name (without the path)
    FILENAME=$(basename $VCF)
    
    # Define the output file name
    OUTPUT_VCF=$OUTPUT_DIR/$FILENAME

    # Run bcftools to filter out variants with >10% missing data
    bcftools view -e 'F_MISSING > 0.05' $VCF -Oz -o $OUTPUT_VCF

    # Index the filtered VCF
    bcftools index $OUTPUT_VCF
done


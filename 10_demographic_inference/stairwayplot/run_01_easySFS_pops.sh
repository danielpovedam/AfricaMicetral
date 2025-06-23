#!/bin/bash

# Set paths
VCF_FILE="/work/project/Micetral/software/gone/data/subsets/NC_000085.7.vcf.gz"
POP_FILE_LIST="/work/project/Micetral/software/gone/data/subsets/listPop"
OUTPUT_DIR="/work/project/Micetral/software/gone/data/subsets/easySFS_output_chr19"
LOG_DIR="/work/project/Micetral/software/gone/data/subsets/logs"

# Create necessary directories if they don't exist
mkdir -p "$OUTPUT_DIR" "$LOG_DIR"

# Projection values for each population
declare -A PROJ_VALUES=(
    ["FRA_ITA"]=41
    ["GABON"]=41
    ["GER_ENG_FRT"]=40
    ["MOR_ALG"]=31
    ["NIGER"]=17
    ["SEN_MAL"]=86
    ["SPA"]=11
    ["TUNEZ"]=20
    ["USA"]=25
    ["WEST_ASIA"]=22
)

# Read population files from listPop and submit jobs
while IFS= read -r POP_FILE; do
  # Skip empty lines
  [[ -z "$POP_FILE" ]] && continue

  # Ensure the file exists before proceeding
  if [[ ! -f "/work/project/Micetral/software/gone/data/subsets/$POP_FILE" ]]; then
    echo "Warning: Population file $POP_FILE not found. Skipping..."
    continue
  fi

  POP_NAME=$(basename "$POP_FILE" .txt)  # Extract population name
  PROJ=${PROJ_VALUES[$POP_NAME]}  # Get the projection value

  if [[ -z "$PROJ" ]]; then
    echo "Projection value missing for $POP_NAME. Skipping..."
    continue
  fi

  # Submit SLURM job
  sbatch <<EOT
#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=12:00:00
#SBATCH --job-name=easySFS_${POP_NAME}
#SBATCH --output=$LOG_DIR/${POP_NAME}_chr19_%A.out
#SBATCH --error=$LOG_DIR/${POP_NAME}_chr19_%A.err

module load bioinfo/easySFS/0.0.1

echo "Processing $POP_NAME with projection $PROJ..."

# Run easySFS with automatic confirmation
printf "yes\n" | easySFS.py -i "$VCF_FILE" -p "/work/project/Micetral/software/gone/data/subsets/$POP_FILE" -a --proj $PROJ -o "$OUTPUT_DIR/$POP_NAME"

echo "Processing for $POP_NAME completed."
EOT

done < "$POP_FILE_LIST"


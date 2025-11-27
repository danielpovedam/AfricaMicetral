#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --job-name=easySFS_array
#SBATCH --output=/home/dpoveda/micetral/software/easySFS/logs/%A_%a.out
#SBATCH --error=/home/dpoveda/micetral/software/easySFS/logs/%A_%a.err
#SBATCH --array=0-323  # 17 pops × 19 chrs = 306 tasks (index 0..305)

module load bioinfo/easySFS/0.0.1

# -------------------------------------------------------------------
# Directories
VCF_DIR="/home/dpoveda/micetral/software/gone/filtered_vcfs_stepwise_0.99_strict"
POP_DIR="/home/dpoveda/micetral/software/easySFS/pops"
OUTPUT_BASE="/home/dpoveda/micetral/software/easySFS/easySFS_output"

# Projection values
declare -A PROJ_VALUES=(
    ["FRAF"]=17
    ["ITAC"]=16
    ["GABON"]=34
    ["BENC"]=21
    ["GER_ALL"]=15
    ["FRAT"]=20
    ["NIGER"]=17
    ["MOR_ALG"]=31
    ["SENS"]=20
    ["SENK"]=22
    ["SEND"]=22
    ["MALI"]=22
    ["SPAC"]=11
    ["TUNEZ"]=20
    ["USA"]=25
)

# Chromosome list
CHROMS=(NC_000067.7 NC_000068.8 NC_000069.7 NC_000070.7 NC_000071.7 NC_000072.7 NC_000073.7 NC_000074.7 \
        NC_000075.7 NC_000076.7 NC_000077.7 NC_000078.7 NC_000079.7 NC_000080.7 NC_000081.7 NC_000082.7 \
        NC_000083.7 NC_000084.7 NC_000085.7)

# -------------------------------------------------------------------
# Build pop–chr combinations
COMBOS=()
for POP_PATH in "$POP_DIR"/*.txt; do
    POP_NAME=$(basename "$POP_PATH" .txt)
    PROJ=${PROJ_VALUES[$POP_NAME]}
    [[ -z "$PROJ" ]] && continue  # skip if proj missing

    for CHR in "${CHROMS[@]}"; do
        COMBOS+=("${POP_NAME}:${POP_PATH}:${CHR}:${PROJ}")
    done
done

# -------------------------------------------------------------------
# Get the combo for this SLURM_ARRAY_TASK_ID
TASK=${COMBOS[$SLURM_ARRAY_TASK_ID]}
IFS=":" read -r POP_NAME POP_PATH CHR PROJ <<< "$TASK"

VCF_FILE="$VCF_DIR/${CHR}.final.vcf.gz"
OUT_DIR="$OUTPUT_BASE/${POP_NAME}/${CHR}"
mkdir -p "$OUT_DIR"

echo "[$(date)] Running easySFS for pop=$POP_NAME chr=$CHR proj=$PROJ"

printf "yes\n" | easySFS.py -i "$VCF_FILE" -p "$POP_PATH" -a --proj $PROJ -o "$OUT_DIR"

echo "[$(date)] Done."


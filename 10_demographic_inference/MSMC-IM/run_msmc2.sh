#!/usr/bin/env bash
#SBATCH --job-name=msmc_im_fixedNe
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=12:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail
module load  devel/Miniconda/Miniconda3
source activate bio-env


MU=4.1e-9
N1=50000
N2=40000
IN_DIR=./inputs
OUT_DIR=./results
MSMC_IM=./MSMC-IM/MSMC_IM.py
mkdir -p "$OUT_DIR" logs

for f in "$IN_DIR"/*.txt; do
    b=$(basename "$f")
    pair="${b%.txt}"
    out_prefix="$OUT_DIR/${pair//-/_}.im"

    echo ">>> Processing $pair"
    echo "    Cleaning zero λ values…"
    clean_file=$(mktemp)
    awk 'NR==1 || ($4>0 && $5>0 && $6>0)' "$f" > "$clean_file"

    # ---- detect number of epochs and adjust pattern ----
    n_epochs=$(($(awk 'END{print NR-1}' "$clean_file")))
    P_PARAM="1*${n_epochs}"
    echo "    Using pattern: -p $P_PARAM (detected $n_epochs epochs)"

    python3 "$MSMC_IM" \
        -mu "$MU" \
        -o "$out_prefix" \
        --printfittingdetails --plotfittingdetails \
        --xlog --ylog \
        -p "$P_PARAM" \
        -N1 "$N1" -N2 "$N2" \
        "$clean_file"

    rm -f "$clean_file"
done

echo ">>> All MSMC-IM runs completed. Results saved in: $OUT_DIR"


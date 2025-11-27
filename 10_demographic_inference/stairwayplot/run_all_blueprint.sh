#!/bin/bash
#SBATCH --job-name=stairway_plot
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=24:00:00
#SBATCH --array=1-8   # because you have 18 blueprint .sh files
#SBATCH --output=/home/dpoveda/micetral/software/stairway_plot/stairway-plot-v2/stairway_plot_v2.1.2/logs/job_%A_%a.out
#SBATCH --error=/home/dpoveda/micetral/software/stairway_plot/stairway-plot-v2/stairway_plot_v2.1.2/logs/job_%A_%a.err

module load devel/java/1.8.0_391

# Disable X11-dependent plotting
export _JAVA_OPTIONS="-Djava.awt.headless=true"
unset DISPLAY

# Set working directory where blueprint scripts are
WORK_DIR="/home/dpoveda/micetral/software/stairway_plot/stairway-plot-v2/final_stair"
cd "$WORK_DIR"

# Collect all blueprint scripts in an array
SCRIPTS=(*.blueprint.sh)

# Select the script for this array index
SCRIPT_TO_RUN="${SCRIPTS[$SLURM_ARRAY_TASK_ID-1]}"

if [[ -z "$SCRIPT_TO_RUN" ]]; then
  echo "No script found for task ID $SLURM_ARRAY_TASK_ID"
  exit 1
fi

echo "[$(date)] Starting $SCRIPT_TO_RUN"
bash "$SCRIPT_TO_RUN"
echo "[$(date)] Finished $SCRIPT_TO_RUN"


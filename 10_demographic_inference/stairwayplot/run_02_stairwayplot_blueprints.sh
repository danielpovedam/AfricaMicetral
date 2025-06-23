#!/bin/bash

#SBATCH --job-name=stairway_plot
#SBATCH --array=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=24:00:00
#SBATCH --output=/home/dpoveda/micetral/software/stairway_plot/stairway-plot-v2/stairway_plot_v2.1.2/logs/job_%A_%a.out

module load devel/java/1.8.0_391

# Set working directory
WORK_DIR="/home/dpoveda/micetral/software/stairway_plot/stairway-plot-v2/stairway_plot_v2.1.2"
cd "$WORK_DIR"

# Get the list of script files 
SCRIPTS=(*.blueprint.sh)

# Get the script corresponding to the array task ID
SCRIPT_TO_RUN="${SCRIPTS[$SLURM_ARRAY_TASK_ID - 1]}"

# Ensure a valid script is selected
if [[ -z "$SCRIPT_TO_RUN" ]]; then
  echo "No script found for task ID $SLURM_ARRAY_TASK_ID"
  exit 1
fi

# Disable X11-dependent plotting
export _JAVA_OPTIONS="-Djava.awt.headless=true"
unset DISPLAY

# Run the script
bash "$SCRIPT_TO_RUN"

echo "Finished processing $SCRIPT_TO_RUN"


#!/bin/bash
#SBATCH --job-name=ngsadmix_run
#SBATCH --output=ngsadmix_%j.out
#SBATCH --error=ngsadmix_%j.err
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=8            # adjust number of threads if needed
#SBATCH --time=72:00:00              # adjust run time as required
#SBATCH --mem=16G                     # adjust memory if needed

# Load the required module (adjust version/path if needed)
module load bioinfo/ANGSD/0.940
module load devel/Miniconda/Miniconda3

source activate bio-env

# Input variables
BEAGLE="/home/dpoveda/micetral/software/pca_pcangsd/house_mouse2.beagle.gz"      # your input beagle file
OUTDIR="/home/dpoveda/micetral/software/ngsAdmix/ngsadmix_output"            # base output directory
PREFIX="house_mouse"                # prefix for output files
MAXITER=4000                      # maximum number of iterations per K
P=8                               # number of threads/cores
NGSADMIX="/home/dpoveda/micetral/software/ngsAdmix/NGSadmix"  # full path to NGSadmix executable

# Loop over K values from 2 to 9
for K in {2..9}; do
    echo "Starting analysis for K=${K}"
    # Create output directory for this K
    mkdir -p ${OUTDIR}/${K}
    
    # Remove any existing likelihood file
    LIKES="${OUTDIR}/${K}/${PREFIX}.${K}.likes"
    rm -f ${LIKES}
    
    # Loop over seeds/iterations for current K
    for SEED in $(seq 1 ${MAXITER}); do
         echo "K=${K}, running seed ${SEED}"
         
         # Run NGSadmix
         ${NGSADMIX} -minMaf 0.05 \
                     -likes ${BEAGLE} \
                     -seed ${SEED} \
                     -K ${K} \
                     -P ${P} \
                     -printInfo 1 \
                     -outfiles ${OUTDIR}/${K}/${PREFIX}.${K}.${SEED}
         
         # Extract the likelihood from the log file and append to the likelihood file
         grep "like=" ${OUTDIR}/${K}/${PREFIX}.${K}.${SEED}.log | cut -f2 -d " " | cut -f2 -d "=" >> ${LIKES}
         
         # Convergence check: Count how many runs are within the threshold of the best run.
         CONV=$(Rscript -e "r<-read.table('${LIKES}'); r<-r[order(-r[,1]),]; cat(sum(r[1]-r<0.2),'\n')")
         echo "K=${K}, seed ${SEED} convergence check: ${CONV}"
         
         # If at least 3 runs are within the threshold, we consider it converged for this K.
         if [ ${CONV} -gt 2 ]; then
             # Optionally copy output files with a suffix to mark convergence
             cp ${OUTDIR}/${K}/${PREFIX}.${K}.${SEED}.qopt ${OUTDIR}/${K}/${PREFIX}.${K}.${SEED}.qopt_conv
             cp ${OUTDIR}/${K}/${PREFIX}.${K}.${SEED}.fopt.gz ${OUTDIR}/${K}/${PREFIX}.${K}.${SEED}.fopt_conv.gz
             cp ${OUTDIR}/${K}/${PREFIX}.${K}.${SEED}.log ${OUTDIR}/${K}/${PREFIX}.${K}.${SEED}.log_conv
             echo "Convergence achieved for K=${K} at seed ${SEED}."
             break
         fi
    done
done


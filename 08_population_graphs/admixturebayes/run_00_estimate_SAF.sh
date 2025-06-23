#!/bin/bash
#SBATCH --job-name=treemix_sfs_array
#SBATCH --output=%x_%A_%a.out
#SBATCH --error=%x_%A_%a.err
#SBATCH --array=0-28 # Cambia el rango según el número de poblaciones
#SBATCH --cpus-per-task=8
#SBATCH --time=24:00:00
#SBATCH --mem=32G

# Módulos requeridos


# Directorios y variables
WORKDIR=/work/project/Micetral/software/mmd/
BAMDIR=/work/project/Micetral/software/mmd/docs
REF=/home/dpoveda/micetral/data/raw/reference_genome/GCF_000001635.27_GRCm39_genomic.fna
SITES=/work/project/Micetral/software/mmd/treemix/combined.subsetted.snp_list
CHR_LIST=/work/project/Micetral/software/mmd/docs/chr_list.txt

# Listado de poblaciones
POPS=(MORC MORT TUNB MALB SENK SEND SENS BENC NIGN GABF GABM GABN USAF USAG USAN USAP USAV USAB FRAF FRAT FRAM GERB GERC ITAC SPAC LEBE IRAA OUTGROUP)


# Seleccionar la población correspondiente al índice del array
POP=${POPS[$SLURM_ARRAY_TASK_ID]}

# Establecer nombres de archivo y salidas
BAMLIST=${BAMDIR}/${POP}_bamlist.txt
OUT=${WORKDIR}/${POP}

# Estimar el archivo .saf
/home/dpoveda/micetral/software/mmd/treemix/angsd/angsd -b $BAMLIST -anc $REF -ref $REF -out $OUT -doSaf 1 -GL 2 -P 8 -minQ 20 -minmapq 20 -sites $SITES -rf $CHR_LIST -remove_bads 1 -only_proper_pairs 1

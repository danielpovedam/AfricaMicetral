#!/bin/bash -l
#SBATCH -J map
#SBATCH -o /work/project/Micetral/steps/logs/map_%j_%a.out
#SBATCH -e /work/project/Micetral/steps/logs/map_%j_%a.err
#SBATCH -t 72:00:00
#SBATCH -p workq
#SBATCH --array=1-335%10
#SBATCH --ntasks=8
#SBATCH --mem=32G

# Load necessary modules
module purge
module load bioinfo/fastp/0.23.2
module load bioinfo/bwa/0.7.18
module load bioinfo/samtools/1.20
module load bioinfo/Sambamba/1.0.1

# Set paths
rawFASTQ=/work/project/bactrack/Projects_EOA/micetral/data/rawdata
trimFASTQ=/work/project/Micetral/steps/02_seq_cleaning
rawBAM=/work/project/Micetral/steps/03_alignment
filtBAM=/work/project/Micetral/steps/04_filtered_bam
refgenome=/work/project/Micetral/data/raw/reference_genome/GCF_000001635.27_GRCm39_genomic.fna

pathlist=/work/project/Micetral/steps/filepath.list # list of filenames from rawFASTQ for each sample (one per line) without R1 - R2
rglist=/work/project/Micetral/steps/readgroup.list # short names for read groups, same order and length as pathlist

# Create output directories if they don't exist
mkdir -p $trimFASTQ $rawBAM $filtBAM

# 1. Get file name (SLURM_ARRAY_TASK_ID=1)
sample=$(sed -n "$SLURM_ARRAY_TASK_ID"p $pathlist)
rg=$(sed -n "$SLURM_ARRAY_TASK_ID"p $rglist)
echo "### full path: $sample"
echo "### sample ID: $sample"
echo "### short name: $rg"

# 2. Trim adapters and low-quality bases
fastp -i $rawFASTQ/${sample}_R1_001.fastq.gz \
  -I $rawFASTQ/${sample}_R2_001.fastq.gz \
  -o $trimFASTQ/${sample}_cleaned_R1.fq.gz \
  -O $trimFASTQ/${sample}_cleaned_R2.fq.gz \
  -j $trimFASTQ/${sample}_fastp.json \
  -h $trimFASTQ/${sample}_fastp.html \
  -l 80 -w 8

# 3. Map reads to reference genome
bwa mem -t 8 $refgenome \
  -R "@RG\tID:$rg\tSM:$rg"  \
  $trimFASTQ/${sample}_cleaned_R1.fq.gz \
  $trimFASTQ/${sample}_cleaned_R2.fq.gz |\
samtools sort -@ 8 -m 1G -o $rawBAM/${rg}.tmp.bam -

# 4. Mark duplicates, index, and compute stats
sambamba markdup -t 8 $rawBAM/${rg}.tmp.bam $filtBAM/${rg}.bam --overflow-list-size=600000 --sort-buffer-size=8000 --tmpdir=/work/project/Micetral/temp && \
samtools index $filtBAM/${rg}.bam && \
samtools flagstat $filtBAM/${rg}.bam > $filtBAM/${rg}.bam.flagstat

# 5. To save disk space, delete trimmed fastq files and temporary bam files if step 4 succeeded
if [ -f $filtBAM/${rg}.bam.bai ]; then
  rm $rawBAM/${rg}.tmp.bam
  rm $trimFASTQ/${sample}_cleaned_R1.fq.gz
  rm $trimFASTQ/${sample}_cleaned_R2.fq.gz
fi

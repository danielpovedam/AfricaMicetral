#!/bin/bash
#SBATCH --job-name=gatk_pipeline
#SBATCH --output=/home/cbrouat/work/mice/logs/gatk_%A_%a.out  # Log output folder
#SBATCH --error=/home/cbrouat/work/mice/logs/gatk_%A_%a.err   # Log error folder
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=128G
#SBATCH -p unlimitq
#SBATCH --array=0-18%1  # Adjust this range for the number of sample pairs

# Load required modules
module load devel/python/Python-3.9.18
module load devel/java/17.0.6
module load bioinfo/bwa-mem2/2.2.1
module load bioinfo/samtools/1.20
module load bioinfo/GATK/4.2.6.1
module load bioinfo/fastp/0.23.2
module load bioinfo/picard-tools/3.0.0

# Define directories
BASE_DIR="/home/cbrouat/work/mice"
FASTQ_DIR="${BASE_DIR}/fastq"
REFERENCE_DIR="${BASE_DIR}/reference"
REFERENCE_GENOME="${REFERENCE_DIR}/GCF_000001635.27_GRCm39_genomic.fna"
WORK_DIR="${BASE_DIR}/results"
TRIMMED_DIR="${BASE_DIR}/trimmed_fastq"
VCF_DIR="${BASE_DIR}/vcf"
LOG_DIR="${BASE_DIR}/logs"

# Create necessary directories if they don't exist
mkdir -p ${TRIMMED_DIR} ${VCF_DIR} ${WORK_DIR} ${LOG_DIR}

# List of samples to process
SAMPLES=("ERR899412" "ERR899413" "ERR899414" "ERR899417") # Add all samples selected for validation dataset - 19 in total

# Get the sample pair to process based on the SLURM_ARRAY_TASK_ID
SAMPLE1=${SAMPLES[$((SLURM_ARRAY_TASK_ID * 2))]}
SAMPLE2=${SAMPLES[$((SLURM_ARRAY_TASK_ID * 2 + 1))]}

echo "Processing sample pair: ${SAMPLE1} and ${SAMPLE2}"

# 1. Download FASTQ files for both samples - the same for the 19 samples
wget -P ${FASTQ_DIR} ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR899/${SAMPLE1}/${SAMPLE1}_1.fastq.gz
wget -P ${FASTQ_DIR} ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR899/${SAMPLE1}/${SAMPLE1}_2.fastq.gz
wget -P ${FASTQ_DIR} ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR899/${SAMPLE2}/${SAMPLE2}_1.fastq.gz
wget -P ${FASTQ_DIR} ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR899/${SAMPLE2}/${SAMPLE2}_2.fastq.gz

# 2. Perform quality control using fastp
fastp -i ${FASTQ_DIR}/${SAMPLE1}_1.fastq.gz -I ${FASTQ_DIR}/${SAMPLE1}_2.fastq.gz \
      -o ${TRIMMED_DIR}/${SAMPLE1}_1_trimmed.fastq.gz -O ${TRIMMED_DIR}/${SAMPLE1}_2_trimmed.fastq.gz

fastp -i ${FASTQ_DIR}/${SAMPLE2}_1.fastq.gz -I ${FASTQ_DIR}/${SAMPLE2}_2.fastq.gz \
      -o ${TRIMMED_DIR}/${SAMPLE2}_1_trimmed.fastq.gz -O ${TRIMMED_DIR}/${SAMPLE2}_2_trimmed.fastq.gz

# 3. Align reads to the reference genome using BWA-MEM2
bwa-mem2 mem -M -t 32 -R "@RG\tID:${SAMPLE1}\tSM:${SAMPLE1}\tLB:${SAMPLE1}\tPL:ILLUMINA" \
    ${REFERENCE_GENOME} ${TRIMMED_DIR}/${SAMPLE1}_1_trimmed.fastq.gz ${TRIMMED_DIR}/${SAMPLE1}_2_trimmed.fastq.gz \
    > ${WORK_DIR}/${SAMPLE1}.sam

bwa-mem2 mem -M -t 32 -R "@RG\tID:${SAMPLE2}\tSM:${SAMPLE2}\tLB:${SAMPLE2}\tPL:ILLUMINA" \
    ${REFERENCE_GENOME} ${TRIMMED_DIR}/${SAMPLE2}_1_trimmed.fastq.gz ${TRIMMED_DIR}/${SAMPLE2}_2_trimmed.fastq.gz \
    > ${WORK_DIR}/${SAMPLE2}.sam

# 4. Convert SAM to BAM and sort
samtools view -bS ${WORK_DIR}/${SAMPLE1}.sam | samtools sort -o ${WORK_DIR}/${SAMPLE1}_sorted.bam
samtools view -bS ${WORK_DIR}/${SAMPLE2}.sam | samtools sort -o ${WORK_DIR}/${SAMPLE2}_sorted.bam

# Remove intermediate SAM files
rm ${WORK_DIR}/${SAMPLE1}.sam ${WORK_DIR}/${SAMPLE2}.sam
# Clean up intermediate trimmed FASTQ files
rm ${TRIMMED_DIR}/${SAMPLE1}_1_trimmed.fastq.gz ${TRIMMED_DIR}/${SAMPLE1}_2_trimmed.fastq.gz
rm ${TRIMMED_DIR}/${SAMPLE2}_1_trimmed.fastq.gz ${TRIMMED_DIR}/${SAMPLE2}_2_trimmed.fastq.gz

# Clean up raw FASTQ files
rm ${FASTQ_DIR}/${SAMPLE1}_1.fastq.gz ${FASTQ_DIR}/${SAMPLE1}_2.fastq.gz
rm ${FASTQ_DIR}/${SAMPLE2}_1.fastq.gz ${FASTQ_DIR}/${SAMPLE2}_2.fastq.gz


# 5. Mark duplicates
gatk MarkDuplicates -I ${WORK_DIR}/${SAMPLE1}_sorted.bam -O ${WORK_DIR}/${SAMPLE1}_dedup.bam \
    -M ${WORK_DIR}/${SAMPLE1}_dedup.metrics.txt

gatk MarkDuplicates -I ${WORK_DIR}/${SAMPLE2}_sorted.bam -O ${WORK_DIR}/${SAMPLE2}_dedup.bam \
    -M ${WORK_DIR}/${SAMPLE2}_dedup.metrics.txt

# 6. Index the BAM files
samtools index ${WORK_DIR}/${SAMPLE1}_dedup.bam
samtools index ${WORK_DIR}/${SAMPLE2}_dedup.bam

# 7. Call variants using GATK HaplotypeCaller
gatk --java-options "-Xmx32G" HaplotypeCaller \
    -R ${REFERENCE_GENOME} -I ${WORK_DIR}/${SAMPLE1}_dedup.bam \
    -O ${VCF_DIR}/${SAMPLE1}_raw_variants.vcf \
    --native-pair-hmm-threads 32

gatk --java-options "-Xmx32G" HaplotypeCaller \
    -R ${REFERENCE_GENOME} -I ${WORK_DIR}/${SAMPLE2}_dedup.bam \
    -O ${VCF_DIR}/${SAMPLE2}_raw_variants.vcf \
    --native-pair-hmm-threads 32

# Remove large intermediate BAM files to save space
#rm ${WORK_DIR}/${SAMPLE1}_sorted.bam ${WORK_DIR}/${SAMPLE2}_sorted.bam
#rm ${WORK_DIR}/${SAMPLE1}_dedup.bam ${WORK_DIR}/${SAMPLE2}_dedup.bam



echo "Processing of sample pair ${SAMPLE1} and ${SAMPLE2} completed."


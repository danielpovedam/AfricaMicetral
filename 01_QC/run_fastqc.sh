#!/bin/bash
#SBATCH -J QC1
#SBATCH -o output_qc1.out #output file name
#SBATCH -e error_q1c.out #error file name
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=daniel.poveda_martinez@ird.fr

#!/bin/bash

# Define the raw data directory
raw_data_dir="/work/project/bactrack/Projects_EOA/micetral/data/rawdata"

# Define the output directory for FastQC reports
output_dir="/home/dpoveda/work/micetral_wgs/steps/01_quality_control/fastqc_reports"

# Create the output directory for FastQC reports
mkdir -p $output_dir


module purge
module load bioinfo/FastQC/0.12.1


# Loop through all R1 files in the raw data directory
for file in ${raw_data_dir}/*_R1_001.fastq.gz
do
    # Derive the base name for the sample (remove _R1_001.fastq.gz)
    base_name=$(basename $file _R1_001.fastq.gz)

    # Define the corresponding R2 file
    r2_file=${raw_data_dir}/${base_name}_R2_001.fastq.gz

    # Check if the R2 file exists
    if [[ -f $r2_file ]]
    then
        echo "Processing $file and $r2_file"

        # Run FastQC on both R1 and R2 files
        fastqc $file $r2_file -o $output_dir
    else
        echo "Warning: $r2_file not found, skipping $file"
    fi
done

echo "FastQC analysis complete. Reports are saved in $output_dir"

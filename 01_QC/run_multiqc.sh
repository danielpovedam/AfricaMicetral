#!/bin/bash

# directory containing the FastQC reports
reports_dir="/home/dpoveda/work/micetral_wgs/steps/01_quality_control/fastqc_reports"

# output directory for the MultiQC report
output_dir="/home/dpoveda/work/micetral_wgs/steps/01_quality_control/multiqc_reports"

# Create the output directory if it doesn't exist
mkdir -p $output_dir

# Run MultiQC to aggregate FastQC reports
multiqc $reports_dir -o $output_dir

echo "MultiQC analysis complete. Report is saved in $output_dir"

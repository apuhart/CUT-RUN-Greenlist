#!/bin/bash
# 3_alignement.sh
# Align paired-end trimmed reads using Bowtie2

set -e

# Default Bowtie2 index and output folder
BOWTIE2_INDEX=""
OUTPUT_DIR="alignment"

# Parse command-line arguments
INPUT_DIR=""
while getopts ":i:o:x:" opt; do
  case $opt in
    i) INPUT_DIR=$OPTARG ;;
    o) OUTPUT_DIR=$OPTARG ;;
    x) BOWTIE2_INDEX=$OPTARG ;;   # <- new argument
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
  esac
done

# Check required inputs
if [ -z "$INPUT_DIR" ]; then
    echo "Error: Please provide an input directory with -i"
    exit 1
fi
if [ -z "$BOWTIE2_INDEX" ]; then
    echo "Error: Please provide the Bowtie2 index prefix with -x"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Running Bowtie2 alignment for trimmed reads in $INPUT_DIR..."

# Loop over all *_trimmed_1.fq.gz files
for R1_file in "$INPUT_DIR"/*_trimmed_1.fq.gz; do
    # Generate the corresponding R2 filename
    R2_file="${R1_file/_trimmed_1.fq.gz/_trimmed_2.fq.gz}"
    sample_name=$(basename "$R1_file" _trimmed_1.fq.gz)

    # Define output SAM file
    output_sam="$OUTPUT_DIR/${sample_name}.sam"

    # Check if input files exist
    if [[ -f "$R1_file" && -f "$R2_file" ]]; then
        echo "Aligning sample: $sample_name"
        bowtie2 -x "$BOWTIE2_INDEX" -p 16 -1 "$R1_file" -2 "$R2_file" -S "$output_sam" 
    else
        echo "Files for $sample_name not found. Skipping."
    fi
done

echo "Alignment complete. SAM files saved in $OUTPUT_DIR"
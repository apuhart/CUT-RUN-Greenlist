#!/bin/bash
# 2_trimming.sh
# Adapter trimming for CUT&RUN sequencing using cutadapt

set -e

# Default output directory
OUTPUT_DIR="trimmed"

# Parse command-line arguments
INPUT_DIR=""
while getopts ":i:o:" opt; do
  case $opt in
    i) INPUT_DIR=$OPTARG ;;
    o) OUTPUT_DIR=$OPTARG ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
  esac
done

# Check input directory
if [ -z "$INPUT_DIR" ]; then
    echo "Error: Please provide an input directory with -i"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Running trimming on files in $INPUT_DIR..."
# Loop over all *_1.fq.gz files in the input directory
for R1_file in "$INPUT_DIR"/*_1.fq.gz; do
    # Generate the corresponding R2 filename
    R2_file="${R1_file/_1.fq.gz/_2.fq.gz}"
    sample_name=$(basename "$R1_file" _1.fq.gz)
    
    # Define output files
    trimmed_R1="$OUTPUT_DIR/${sample_name}_trimmed_1.fq.gz"
    trimmed_R2="$OUTPUT_DIR/${sample_name}_trimmed_2.fq.gz"
    
    # Check if input files exist
    if [[ -f "$R1_file" && -f "$R2_file" ]]; then
        echo "Trimming sample: $sample_name"
        cutadapt -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
                 -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
                 -o "$trimmed_R1" -p "$trimmed_R2" \
                 "$R1_file" "$R2_file" \
                 --cores 16 --trim-n -m 22 -O 4
    else
        echo "Files for $sample_name not found. Skipping."
    fi
done

echo "Trimming complete. Results saved in $OUTPUT_DIR"

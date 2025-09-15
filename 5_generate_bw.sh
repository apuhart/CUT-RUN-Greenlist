#!/bin/bash
# 5_generate_bw.sh
# Generate normalized BigWig files from sorted BAMs
# User-defined input/output directories

set -e

# Default variables
INPUT_DIR=""
OUTPUT_DIR=""

# Parse command-line arguments
while getopts ":i:o:" opt; do
  case $opt in
    i) INPUT_DIR=$OPTARG ;;
    o) OUTPUT_DIR=$OPTARG ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
  esac
done

# Check required inputs
if [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: $0 -i <input_bam_dir> -o <output_bw_dir>"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "Generating BigWig files from BAMs in $INPUT_DIR..."

# Loop over all *_sorted.bam files
for bam_file in "$INPUT_DIR"/*_sorted.bam; do
    if [[ -f "$bam_file" ]]; then
        sample_name=$(basename "$bam_file" _sorted.bam)
        output_bw="$OUTPUT_DIR/${sample_name}.bw"
        output_bw_noDup="$OUTPUT_DIR/${sample_name}_noDup.bw"

        echo "Processing $sample_name..."

        # BigWig with duplicates
        bamCoverage -b "$bam_file" --normalizeUsing RPKM -o "$output_bw" -p 16

        # BigWig without duplicates
        bamCoverage -b "$bam_file" --normalizeUsing RPKM --ignoreDuplicates -o "$output_bw_noDup" -p 16

        echo "BigWig files generated for $sample_name"
    fi
done

echo "All BigWig files created successfully!"

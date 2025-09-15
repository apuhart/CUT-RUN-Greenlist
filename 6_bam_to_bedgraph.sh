#!/bin/bash
# 6_bam_to_bedgraph.sh
# Convert sorted BAM files to BedGraph using bedtools genomecov
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
    echo "Usage: $0 -i <input_bam_dir> -o <output_bedgraph_dir>"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Converting sorted BAM files to BedGraph in $OUTPUT_DIR..."

# Loop over all *_sorted.bam files
for bam_file in "$INPUT_DIR"/*_sorted.bam; do
    if [[ -f "$bam_file" ]]; then
        sample_name=$(basename "$bam_file" _sorted.bam)
        output_bg="$OUTPUT_DIR/${sample_name}.bedgraph"

        echo "Processing $sample_name..."
        bedtools genomecov -bg -ibam "$bam_file" -split > "$output_bg"
        echo "BedGraph file generated: $output_bg"
    fi
done

echo "All BAM files converted to BedGraph successfully!"

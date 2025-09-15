#!/bin/bash
# 4_sam_to_bam_indexed.sh
# Convert SAM → BAM, sort, index, and optionally remove SAM files

set -e

# Default output folder
OUTPUT_DIR="bam"

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

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Processing SAM files in $INPUT_DIR..."

# Loop over all SAM files in the input folder
for sam_file in "$INPUT_DIR"/*.sam; do
    [ -e "$sam_file" ] || { echo "No SAM files found in $INPUT_DIR"; break; }
    
    sample_name=$(basename "$sam_file" .sam)
    bam_file="$OUTPUT_DIR/${sample_name}.bam"
    sorted_bam="$OUTPUT_DIR/${sample_name}_sorted.bam"
    
    echo "Processing sample: $sample_name"
    
    # Convert SAM → BAM
    echo "Converting SAM → BAM..."
    samtools view -@ 16 -S -b "$sam_file" > "$bam_file"
    
    # Sort BAM
    echo "Sorting BAM..."
    samtools sort -@ 16 "$bam_file" -o "$sorted_bam"
    
    # Index BAM
    echo "Indexing BAM..."
    samtools index -@ 16 "$sorted_bam"
    
    # Remove original SAM (optional)
    echo "Removing original SAM..."
    rm "$sam_file"
    
    echo "Finished processing $sample_name"
done

echo "All SAM → BAM conversions complete. Results in $OUTPUT_DIR"

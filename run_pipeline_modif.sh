#!/bin/bash
# run_pipeline.sh
# Run Steps 1 → 4: FastQC + MultiQC, Trimming, Bowtie2 Alignment, and SAM → BAM
# User-defined input/output directories and reference genome

set -e  # Stop on any error

# Default variables
INPUT_DIR=""
OUTPUT_DIR=""
GENOME_FASTA=""

# Parse command-line arguments
while getopts ":i:o:g:" opt; do
  case $opt in
    i) INPUT_DIR=$OPTARG ;;
    o) OUTPUT_DIR=$OPTARG ;;
    g) GENOME_FASTA=$OPTARG ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
  esac
done

# Check required inputs
if [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_DIR" ] || [ -z "$GENOME_FASTA" ]; then
    echo "Usage: $0 -i <input_dir> -o <output_dir> -g <genome_fasta>"
    exit 1
fi

# Create main output directory
mkdir -p "$OUTPUT_DIR"


# -----------------------------
# Step 7: Greenlist application
# -----------------------------
echo "=== Step 7: Greenlist Application ==="
bash "7_greenlist_application.sh" \
  -i "$OUTPUT_DIR/bam" \
  -o "$OUTPUT_DIR/greenlist" \
  -g "hg38_CUTnRUN_greenlist.v1.bed"


# -----------------------------
# Step 8: BedGraph → BigWig
# -----------------------------
echo "=== Step 8: BedGraph → BigWig Conversion ==="
bash "8_bedgraph_to_bw.sh" \
  -i "$OUTPUT_DIR/greenlist" \
  -o "$OUTPUT_DIR/bigwig" \
  -c "hg38.chrom.sizes"



echo "All steps completed successfully!"

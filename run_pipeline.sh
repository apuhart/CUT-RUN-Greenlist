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
# Step 1: FastQC + MultiQC
# -----------------------------
# echo "=== Step 1: FastQC + MultiQC ==="
# bash "1_fastqc_multiqc.sh" \
#  -i "$INPUT_DIR" \
#   -o "$OUTPUT_DIR/fastqc"

# -----------------------------
# Step 2: Trimming
# -----------------------------
 echo "=== Step 2: Trimming ==="
 bash "2_trimming.sh" \
   -i "$INPUT_DIR" \
    -o "$OUTPUT_DIR/trimmed"

# -----------------------------
# Step 3: Bowtie2 Alignment
# -----------------------------
echo "=== Step 3: Bowtie2 Alignment ==="

# Determine Bowtie2 index prefix
BOWTIE2_INDEX="${OUTPUT_DIR}/bowtie2_index"

# Build Bowtie2 index if it doesn't exist
if [ ! -f "${BOWTIE2_INDEX}.1.bt2" ]; then
    echo "Bowtie2 index not found. Building index from genome FASTA..."

    # Unzip genome if needed
    if [[ "$GENOME_FASTA" == *.gz ]]; then
        echo "Unzipping genome FASTA..."
        gunzip -c "$GENOME_FASTA" > "$OUTPUT_DIR/genome.fa"
        GENOME_FASTA="$OUTPUT_DIR/genome.fa"
    fi

    # Build index
    bowtie2-build "$GENOME_FASTA" "$BOWTIE2_INDEX"
    echo "Bowtie2 index built at: $BOWTIE2_INDEX"
else
    echo "Bowtie2 index already exists at $BOWTIE2_INDEX"
fi
#
# Run alignment using the generated Bowtie2 index
bash "3_alignement.sh" \
  -i "$OUTPUT_DIR/trimmed" \
  -o "$OUTPUT_DIR/alignment" \
  -x "$BOWTIE2_INDEX"

# -----------------------------
# Step 4: SAM → BAM, Sort, Index
# -----------------------------
echo "=== Step 4: SAM → BAM Conversion, Sorting, Indexing ==="
bash "4_sam_to_bam_indexed.sh" \
  -i "$OUTPUT_DIR/alignment" \
  -o "$OUTPUT_DIR/bam"


  # -----------------------------
# Step 5: Generate BigWig
# -----------------------------
echo "=== Step 5: Generate BigWig files ==="
bash "5_generate_bw.sh" \
  -i "$OUTPUT_DIR/bam" \
  -o "$OUTPUT_DIR/bigwig"


# -----------------------------
# Step 6: BAM → BedGraph
# -----------------------------
echo "=== Step 6: Convert BAM to BedGraph ==="
bash "6_bam_to_bedgraph.sh" \
  -i "$OUTPUT_DIR/bam" \
  -o "$OUTPUT_DIR/bedgraph"


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

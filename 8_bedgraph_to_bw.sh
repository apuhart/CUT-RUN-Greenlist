#!/bin/bash
# 8_bedgraph_to_bw.sh
# Convert spike-in normalized BedGraph files to BigWig

set -e

INPUT_DIR=""
OUTPUT_DIR=""
CHROM_SIZES="hg38.chrom.sizes"

while getopts ":i:o:c:" opt; do
  case $opt in
    i) INPUT_DIR=$OPTARG ;;    # directory with spikein bedgraphs
    o) OUTPUT_DIR=$OPTARG ;;   # output directory for bigWigs
    c) CHROM_SIZES=$OPTARG ;;  # path to hg38.chrom.sizes
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
  esac
done

if [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_DIR" ] || [ -z "$CHROM_SIZES" ]; then
    echo "Usage: $0 -i <bedgraph_directory> -o <output_directory> -c <chrom_sizes>"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "=== Step 8: Converting BedGraph to BigWig ==="

# Add "chr" prefix to chrom.sizes if missing
CHR_TMP="$OUTPUT_DIR/hg38_with_chr.chrom.sizes"
if ! grep -q "^chr" "$CHROM_SIZES"; then
    echo "Adding chr prefix to $CHROM_SIZES -> $CHR_TMP"
    sed 's/^\([0-9XYM]\)/chr\1/' "$CHROM_SIZES" > "$CHR_TMP"
    CHROM_SIZES="$CHR_TMP"
fi

# Loop over all spikein bedgraphs
for bedgraph in "$INPUT_DIR"/*_spikein.bedgraph; do
    [ -e "$bedgraph" ] || continue
    sample=$(basename "$bedgraph" .bedgraph)

    echo "Processing $sample..."

    # Ensure chr prefix
    with_chr="$OUTPUT_DIR/${sample}_with_chr.bedgraph"
    sed 's/^\([0-9XYM]\)/chr\1/' "$bedgraph" > "$with_chr"

    # Filter using chrom sizes
    filtered="$OUTPUT_DIR/${sample}_filtered.bedgraph"
    awk 'BEGIN {while(getline < "'"$CHROM_SIZES"'") sizes[$1]=1} $1 in sizes' "$with_chr" > "$filtered"

    # Sort bedGraph before BigWig conversion
    sorted="$OUTPUT_DIR/${sample}_sorted.bedgraph"
    sort -k1,1 -k2,2n "$filtered" > "$sorted"

    # Convert to BigWig
    bigwig="$OUTPUT_DIR/${sample}.bw"
    bedGraphToBigWig "$sorted" "$CHROM_SIZES" "$bigwig"

    echo "BigWig generated: $bigwig"
done

echo "All BedGraphs converted to BigWigs in $OUTPUT_DIR"

#!/bin/bash
# 7_greenlist_application.sh - Apply Greenlist scaling to paired FA/CTL BAMs

set -e

INPUT_DIR=""
OUTPUT_DIR=""
GREENLIST_BED=""

# Parse command-line arguments
while getopts ":i:o:g:" opt; do
  case $opt in
    i) INPUT_DIR=$OPTARG ;;
    o) OUTPUT_DIR=$OPTARG ;;
    g) GREENLIST_BED=$OPTARG ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
  esac
done

if [[ -z "$INPUT_DIR" || -z "$OUTPUT_DIR" || -z "$GREENLIST_BED" ]]; then
    echo "Usage: $0 -i <bam_directory> -o <output_directory> -g <greenlist_bed>"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
echo "=== Step 7: Greenlist application (paired FA/CTL) ==="

# -----------------------------
# 1. Detect groups (512, 512B, etc.)
# -----------------------------
groups=()
for bam in "$INPUT_DIR"/*_sorted.bam; do
    group=$(basename "$bam" | sed -E 's/^(FA|CTL)_([0-9A-Za-z]+).*_sorted\.bam$/\2/')
    [[ " ${groups[*]} " =~ " $group " ]] || groups+=("$group")
done

# -----------------------------
# 2. Loop over each group separately
# -----------------------------
for group in "${groups[@]}"; do
    echo "=== Processing group $group (FA + CTL) ==="
    
    # Collect BAMs for this group
    bam_files=()
    for bam in "$INPUT_DIR"/*_${group}_sorted.bam; do
        bam_files+=("$bam")
    done
    
    if [[ ${#bam_files[@]} -eq 0 ]]; then
        echo "No BAMs found for group $group, skipping..."
        continue
    fi

    # Run multiBamSummary only for this group
    multiBamSummary BED-file \
        --BED "$GREENLIST_BED" \
        --smartLabels -e --centerReads \
        -o "$OUTPUT_DIR/glist_quant_${group}.npz" \
        -b "${bam_files[@]}" \
        --outRawCounts "$OUTPUT_DIR/output_${group}"

    # Convert counts into TSV
    cat "$OUTPUT_DIR/output_${group}" | tr -d "'#" | sed $'s/\t/_/1' | cut -f 1,3- > "$OUTPUT_DIR/glist_quant_${group}.tsv"

    # Calculate size factors for this group
    Rscript --vanilla get_sizeFactors.R \
        "$OUTPUT_DIR/glist_quant_${group}.tsv" \
        "$OUTPUT_DIR/glist_sizeFactors_${group}.tsv"

    sed -i '1d' "$OUTPUT_DIR/glist_sizeFactors_${group}.tsv"
    sed -i '1i sample\tscaleFactor\tnormalizer' "$OUTPUT_DIR/glist_sizeFactors_${group}.tsv"

    # Apply scaling to all BAMs of this group
    while IFS=$'\t' read -r sample scaleFactor normalizer; do
        [[ "$sample" == "sample" ]] && continue
        bam_file="$INPUT_DIR/${sample}.bam"
        out_file="$OUTPUT_DIR/${sample}_spikein.bedgraph"
        if [[ -f "$bam_file" ]]; then
            echo "Scaling $bam_file with factor $normalizer (group $group)"
            bedtools genomecov -bg -ibam "$bam_file" -scale "$normalizer" > "$out_file"
        else
            echo "BAM file $bam_file not found, skipping..."
        fi
    done < "$OUTPUT_DIR/glist_sizeFactors_${group}.tsv"

done

echo "Greenlist spike-in normalized BedGraphs generated in $OUTPUT_DIR"

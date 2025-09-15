
#!/bin/bash
# 1_fastqc_multiqc.sh
# Run FastQC and MultiQC on all *_1.fq.gz and *_2.fq.gz files in the input directory

# Exit on error
set -e

# Parse command-line arguments
INPUT_DIR=""
OUTPUT_DIR="fastqc_results"

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

echo "Running FastQC on files in $INPUT_DIR..."
# Loop over *_1.fq.gz and *_2.fq.gz files
for read in 1 2; do
  for file in "$INPUT_DIR"/*_"$read".fq.gz; do
    if [ -f "$file" ]; then
      fastqc "$file" -o "$OUTPUT_DIR"
    fi
  done
done

echo "Running MultiQC..."
multiqc "$OUTPUT_DIR" -o "$OUTPUT_DIR"

echo "FastQC and MultiQC analysis complete. Results saved in $OUTPUT_DIR"

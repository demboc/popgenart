#!/bin/bash

# Usage: ./dummygen_script.sh <csv_file> <prefix>

# Check number of arguments
if [[ "$#" -ne 2 ]]; then
  echo "Usage: $0 <csv_file> <prefix>" >&2
  exit 1
fi

csv_file="$1"
prefix="$2"

num_loci=$(grep "Num_Loci" "$csv_file" | awk -F, '{ print $2 }')
echo "Number of loci per chromosome: ${num_loci}"
num_chrom=$(grep "Num_Chrom" "$csv_file" | awk -F, '{ print $2 }')
echo "Number of chromosome: ${num_chrom}"
GnC=$(grep "GC_Con" "$csv_file" | awk -F, '{ print $2 }')
echo "GC Ratio is ${GnC}"

GC=$(awk "BEGIN {print $GnC / 2}")
AT=$(awk "BEGIN {print 0.5 - $GC}")

counter=1
fasta_file="${prefix}_tempseq.fa"
echo "" > "$fasta_file"

while [ $counter -le "$num_chrom" ]; do
  echo ">Chromosome ${counter}" >> "$fasta_file"
  Rscript -e "cat(sample(c('A','T','C','G'), size=${num_loci}, replace=TRUE, prob=c(${AT},${AT},${GC},${GC})), sep='')" >> "$fasta_file"
  echo "" >> "$fasta_file"
  ((counter++))
done

echo "Made the dummy sequence"

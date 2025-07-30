#!/bin/bash

# Usage: ./parse_arp.sh <prefix> <arpfile>

# Check number of arguments
if [[ "$#" -ne 2 ]]; then
  echo "Usage: $0 <prefix> <arpfile>" >&2
  exit 1
fi

prefix="$1"
arpfile="$2"

echo "Input ok."

indices_array="${prefix}_indices.txt"
echo "" > "$indices_array"

mapfile -t line_nums < <(grep -n "polymorphic positions on chromosome" "$arpfile" | cut -d: -f1)

chrom_num=1
for line_num in "${line_nums[@]}"; do
  echo "Chrom ---- ${chrom_num}" >> "$indices_array"
  target_line=$((line_num + 1))
  line=$(sed -n "${target_line}p" "$arpfile")
  clean_line=$(echo "$line" | tr -d '#' | xargs)
  IFS=',' read -ra polyInd <<< "$clean_line"

  for i in "${polyInd[@]}"; do
    val=$(echo "$i" | xargs)
    echo "$val" >> "$indices_array"
  done

  ((chrom_num++))
done

echo "Indices are saved in ${indices_array}"

# Extract SNP sequences to CSV
(echo "SampleID,Col2,Sequence"; awk '
  /SampleData= *\{/ {inBlock=1; next}
  /^\}/ && inBlock {inBlock=0; next}
  inBlock && NF==3 {print $1","$2","$3}
' "$arpfile") > "${prefix}_SNPseq.csv"

echo "Saved the SNPs to a csv file"

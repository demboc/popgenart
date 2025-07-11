#!/bin/bash

# This is the parser script for the .arp file to get the loci & actual SNP sequences per sample. 

# Check if input is ok
while getopts "p:a:" opt; do
  case "$opt" in

    p) prefix="$OPTARG" ;;
    a) arpfile="$OPTARG" ;;

    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [[ -z "$prefix" || -z "$arpfile" ]]; then
  echo "Usage: $0 -p <prefix> -a <arpfile>" >&2
  exit 1
fi

echo "Input ok."


#arpfile="${prefix}.arp"

## Get where the polymorphic sites are
# 1. Find the line number with the phrase
line_num=$(grep -n "polymorphic positions on chromosome" "${arpfile}" | cut -d: -f1)

if [[ -z "$line_num" ]]; then
  echo "Phrase not found"
  exit 1
fi

# 2. Calculate the target line (line_num + 11)
target_line=$((line_num + 1))

# 3. Extract that line from the file
line=$(sed -n "${target_line}p" "${arpfile}")

# 4. Remove '#' characters
line_no_hash=${line//#/}

# 5. Split by comma and trim spaces, store in an array
IFS=',' read -ra polyInd <<< "$line_no_hash"

# 6. Trim spaces and print all as integers
indices_array="${prefix}_indices.txt"
for i in "${polyInd[@]}"; do
  # Trim leading/trailing whitespace
  val=$(echo "$i" | xargs)
  echo "$val" >> ${indices_array}
done


echo "Indices are saved in ${indices_array}"

## Get the SNP sequence per sample and save to a csv file.

awk '
  # Start flag when inside SampleData block
  /SampleData= *\{/ {inBlock=1; next}

  # End flag when closing bracket of SampleData block
  /^\}/ && inBlock {inBlock=0; next}

  # When inside SampleData, print lines with 3 fields (Sample lines)
  inBlock && NF==3 {print $1","$2","$3}
' ${arpfile} > ${prefix}_SNPseq.csv

(echo "SampleID,Col2,Sequence"; awk '
  /SampleData= *\{/ {inBlock=1; next}
  /^\}/ && inBlock {inBlock=0; next}
  inBlock && NF==3 {print $1","$2","$3}
' ${arpfile}) > ${prefix}_SNPseq.csv

echo "Saved the SNPs to a csv file"



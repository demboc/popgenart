#!/bin/bash

# Script for simulating DNA fragmentation via sonication
# Now supports multiple genome copies and fragmentation logic modeled after exponential distribution

csv_file=""
prefix=""

while getopts "c:p:n:" opt; do
  case ${opt} in
    c) csv_file="$OPTARG" ;;
    p) prefix="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
    :)  echo "Error: Option -$OPTARG requires an argument." >&2; exit 1 ;;
  esac
done

if [[ -z "${csv_file}" || -z "${prefix}" ]]; then
  echo "Usage: $0 -c <csv_file> -p <prefix> [-n <num_copies>]" >&2
  exit 1
fi

input_fasta="${prefix}.fasta"
output="${prefix}_frags.fasta"

# Extract required info from csv
frag_size=$(grep "Mean_Frag_Size" "${csv_file}" | awk -F, '{ print $2 }' | tr -d '[:space:]')
min_frag_size=$(grep "Min_Frag_Size" "${csv_file}" | awk -F, '{ print $2 }' | tr -d '[:space:]')
num_copies=$(grep "Genome_Copies" "${csv_file}" | awk -F, '{ print $2 }' | tr -d '[:space:]')


if [[ -z "${frag_size}" ]]; then
  echo "Error: Mean_Frag_Size not found in CSV file." >&2
  exit 1
fi

if [[ -z "${min_frag_size}" ]]; then
  echo "Error: Min_Frag_Size not found in CSV file." >&2
  exit 1
fi

if [[ -z "${num_copies}" ]]; then
  num_copies=1
fi

echo "Using mean fragmentation size: ${frag_size} bp"
echo "Using minimum fragment size: ${min_frag_size} bp"
echo "Simulating ${num_copies} genome copy/copies per sequence."



# Main fragmentation logic


lambda=$(awk -v fs=$frag_size 'BEGIN{print 1/fs}')

# Pre-generate enough fragment sizes for a given sequence length
generate_fragments() {
  local seq_len=$1
  local needed_frags=$((seq_len / min_frag_size + 10))
  Rscript -e "
    lambda <- ${lambda}
    min_size <- ${min_frag_size}
    needed <- ${needed_frags}
    sizes <- c()
    while(sum(sizes) < ${seq_len} + max(min_size,10)){
      new <- round(rexp(needed, rate=lambda))
      new <- new[new >= min_size]
      sizes <- c(sizes, new)
    }
    cat(sizes, sep='\n')
  "
}

# Function to fragment a sequence (for one genome copy)
fragment_sequence_copy() {
  local copy_id=$1
  local frag_count=1
  local start=0
  local seq_len=${#current_seq}

  mapfile -t frag_sizes < <(generate_fragments "$seq_len")

  local i=0
  while [[ $start -lt $seq_len && $i -lt ${#frag_sizes[@]} ]]; do
    local fsize=${frag_sizes[$i]}
    local end=$((start + fsize))
    if [[ $end -gt $seq_len ]]; then
      end=$seq_len
    fi

    local actual_size=$((end - start))

    if [[ $actual_size -ge $min_frag_size ]]; then
      local frag_seq=${current_seq:start:actual_size}
      echo ">${prefix}_${current_sample}_copy${copy_id}_frag${frag_count}" >> "$output"
      echo "$frag_seq" | fold -w 100 >> "$output"
      ((frag_count++))
    fi

    start=$end
    ((i++))
  done
}

# Function to fragment a sequence across all genome copies
fragment_sequence() {
  for ((c=1; c<=num_copies; c++)); do
    fragment_sequence_copy "$c"
  done
}

# Run fragmentation
echo "Simulating mechanical shearing..."

> "$output"
current_sample=""
current_seq=""

while IFS= read -r line; do
  if [[ $line == ">"* ]]; then
    if [[ -n "$current_seq" ]]; then
      fragment_sequence
    fi
    current_sample="${line#>}"
    current_seq=""
  else
    current_seq+="$line"
  fi
done < "$input_fasta"

if [[ -n "$current_seq" ]]; then
  fragment_sequence
fi

echo "Fragmentation complete. Output written to ${output}"

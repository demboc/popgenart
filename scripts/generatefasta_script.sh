#!/bin/bash

# Usage: ./generatefasta_script.sh <prefix> <indices_SNP> <ref_seq> <SNP_csv>

# Check if exactly 4 arguments are provided
if [[ "$#" -ne 4 ]]; then
  echo "Usage: $0 <prefix> <indices_SNP> <ref_seq> <SNP_csv>" >&2
  exit 1
fi

# Assign positional arguments to variables
prefix="$1"
indices_SNP="$2"
ref_seq="$3"
SNP_csv="$4"

echo "Input ok."

fasta_out="${prefix}.fasta"
> "$fasta_out"

# Parse indices_SNP into an associative array by chromosome
declare -A snp_indices
current_chr=""

while read -r line; do
    if [[ "$line" == Chrom* ]]; then
        current_chr=$(echo "$line" | awk '{print $3}')
        snp_indices["chr${current_chr}"]=""
    elif [[ -n "$line" ]]; then
        snp_indices["chr${current_chr}"]+="${line},"
    fi
done < "$indices_SNP"

# Read SNP data and modify sequences per sample
tail -n +2 "$SNP_csv" | while IFS=',' read -r SampleID _ Sequence; do
    seq_offset=0

    for chr_key in "${!snp_indices[@]}"; do
        echo ">${SampleID}${chr_key}" >> "$fasta_out"
        echo "$chr_key"
        chr_num=${chr_key#chr}

        ref_seq_chr=$(awk -v chr=">Chromosome ${chr_num}" '
            $0 == chr {flag=1; next}
            /^>/ {flag=0}
            flag {print}' "$ref_seq" | tr -d '\n')

        IFS=',' read -ra chr_snps <<< "${snp_indices[$chr_key]}"

        for (( i=0; i<${#chr_snps[@]}; i++ )); do
            pos=${chr_snps[i]}
            [[ -z "$pos" ]] && continue
            snp_char="${Sequence:$seq_offset:1}"
            ((seq_offset++))
            ref_seq_chr="${ref_seq_chr:0:$pos}${snp_char}${ref_seq_chr:$((pos + 1))}"
        done

        echo "$ref_seq_chr" >> "$fasta_out"
    done

    echo "ok for sample ${SampleID}"
done

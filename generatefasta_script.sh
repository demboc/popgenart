#!/bin/bash

# Generate the fasta files based on the reference sequence + SNP sequence per sample + SNP loci

# The needed stuff.
#indices_SNP="${prefix}_indices.txt"
#ref_seq="${prefix}_tempseq.fa"
#SNP_csv="${prefix}_SNPseq.csv"

# Check if input is ok
while getopts "p:i:r:s:" opt; do
  case "$opt" in

    p) prefix="$OPTARG" ;;
    i) indices_SNP="$OPTARG" ;;
    r) ref_seq="$OPTARG" ;;
    s) SNP_csv="$OPTARG" ;;

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

if [[ -z "$prefix" || -z "$indices_SNP" || -z "$ref_seq" || -z "$SNP_csv" ]]; then
  echo "Usage: $0 -p <prefix> -i <indices_SNP> -r <ref_seq> -s <SNP_csv>" >&2
  exit 1
fi

echo "Input ok."

fasta_out="${prefix}.fasta"
> ${fasta_out}


# Parse indices_SNP into an associative array by chromosome
declare -A snp_indices
current_chr=""

while read -r line; do
    if [[ "$line" == Chrom* ]]; then
	current_chr=$(echo "$line" | awk '{print $3}')  # Extract chromosome number
        snp_indices["chr${current_chr}"]="" 

    elif [[ -n "$line" ]]; then
	snp_indices["chr${current_chr}"]+="${line},"  # Append with comma for later splitting
    fi
done < "$indices_SNP"

# Read SNP data and modify sequences per sample
tail -n +2 "$SNP_csv" | while IFS=',' read -r SampleID _ Sequence; do
    seq_offset=0  # Index offset in the flat SNP string

    # Process each chromosome

    for chr_key in "${!snp_indices[@]}"; do
        echo ">${SampleID} ${chr_key}" >> "$fasta_out"
	echo $chr_key
	chr_num=${chr_key#chr}  # Remove prefix
        # Extract reference sequence for this chromosome
        ref_seq_chr=$(awk -v chr=">Chromosome ${chr_num}" '
            $0 == chr {flag=1; next} 
            /^>/ {flag=0} 
            flag {print}' "$ref_seq" | tr -d '\n')

        # Get SNP positions as array 
        IFS=',' read -ra chr_snps <<< "${snp_indices[$chr_key]}"
        
        # Modify the reference sequence with SNPs
        for (( i=0; i<${#chr_snps[@]}; i++ )); do
            pos=${chr_snps[i]}
            [[ -z "$pos" ]] && continue  # Skip empty
            snp_char="${Sequence:$seq_offset:1}"
            ((seq_offset++))
            # Modify character at position
            ref_seq_chr="${ref_seq_chr:0:$pos}${snp_char}${ref_seq_chr:$((pos + 1))}"
        done

        # Append the modified chromosome sequence
        echo "$ref_seq_chr" >> "$fasta_out"
    done

    echo "ok for sample ${SampleID}"
done


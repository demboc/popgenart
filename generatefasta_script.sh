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



echo "" > ${fasta_out}

#Making the indices.txt file back to array
mapfile -t polyInd < "${indices_SNP}"
echo "${polyInd}"

tail -n +2 "${SNP_csv}" | while IFS=',' read -r SampleID Col2 Sequence
do
        echo ">${SampleID}" >> ${fasta_out}
	temp_tomodify="temp_tomodify.txt"
	cat ${ref_seq} > ${temp_tomodify}

	for (( i=0; i<${#Sequence}; i++ )); do
		seq=$(<"${temp_tomodify}")

		new_char="${Sequence:$i:1}"

		pos=${polyInd[$i]}
		echo "${pos}"

		modified="${seq:0:$pos}${new_char}${seq:$((pos + 1))}"
		echo "${modified}" > ${temp_tomodify}

	done

	cat ${temp_tomodify} >> ${fasta_out}

	echo "ok for sample ${SampleID}" 
done

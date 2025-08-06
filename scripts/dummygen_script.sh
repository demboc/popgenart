#!/bin/bash

# This is a script for making the dummy sequence. This will use an R base (for now)


csv_file=""
prefix=""

while getopts "c:p:" opt; do
  case ${opt} in
    c) csv_file="$OPTARG" ;;
    p) prefix="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2
        exit 1
        ;;
    :)
      echo "Error: Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [[ -z "${csv_file}" ]]; then
  echo "Error: Missing required -c <csc_file> argument." >&2
  echo "Usage: $0 -c <csv_file>" >&2
  exit 1
fi

if [[ -z "${prefix}" ]]; then
  echo "Error: Missing required -p <prefix> argument." >&2
  echo "Usage: $0 -p <prefix>" >&2
  exit 1
fi

echo "Complete arguments for reference sequence generation. "


echo "Determining number of loci to be generated."
num_loci=$(grep "Num_Loci_1a" ${csv_file} | awk -F, '{ print $2 }')
echo "Number of loci per chromosome: ${num_loci}"
echo "Determining number of chromosomes."
num_chrom=$(grep "Num_Chrom" ${csv_file} | awk -F, '{ print $2 }')
echo "Number of chromosome: ${num_chrom}"
echo "Determining the GC content."
GnC=$(grep "GC_Con" ${csv_file} | awk -F, '{ print $2 }')
echo "GC Ratio is ${GnC}"
GC=$(awk "BEGIN {print $GnC / 2}")
AT=$(awk "BEGIN {print 0.5 - $GC}")


counter=1
fasta_file=${prefix}_tempseq.fa
echo "" > ${fasta_file}


echo "Generating the sequence."
while [ $counter -le ${num_chrom} ];do
	echo ">Chromosome ${counter}" >> ${fasta_file}

	declare -a bases

	count_A=$(awk -v p="$AT" 'BEGIN {printf "%.0f", p * 50}')
	count_T=$count_A
	count_G=$(awk -v p="$GC" 'BEGIN {printf "%.0f", p * 50}')
	count_C=$count_G

	#Making a weighted distribution for the bases

	for ((i=0; i<count_A; i++)); do bases+=('A'); done
	for ((i=0; i<count_T; i++)); do bases+=('T'); done
	for ((i=0; i<count_G; i++)); do bases+=('G'); done
	for ((i=0; i<count_C; i++)); do bases+=('C'); done

	while ((${#bases[@]} < num_loci)); do
  		rand_base=${bases[$((RANDOM % 100))]}
 		bases+=("$rand_base")
	done

	#Generating the sequence

	sequence=""
	for ((i = 0; i < num_loci; i++)); do
  		base=${bases[$((RANDOM % ${#bases[@]}))]}
  		sequence+="$base"
	done


	echo "${sequence}" >> ${fasta_file}
	echo "" >> ${fasta_file}
	((counter++))	
done


echo "Reference sequence generated."

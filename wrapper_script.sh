#!/bin/bash

# This is the wrapper script

# Making sure we have the inputs needed

input_file=""
prefix=""
fsc_loc=""

while getopts "i:p:f:" opt; do
  case "$opt" in
    i) input_file="$OPTARG" ;;
    p) prefix="$OPTARG" ;;
    f) fsc_loc="$OPTARG" ;;
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

# Make sure that the inputs are there!

if [[ -z "$input_file" || -z "$prefix" || -z "${fsc_loc}" ]]; then
  echo "Usage: $0 -i <input_file> -p <prefix> -f <fsc_loc>" >&2
  exit 1
fi

echo "Complete inputs for all!"

# Execute script for parsing 
chmod +x parser_script.sh
./parser_script.sh -i ${input_file} -p ${prefix}
echo "Ok input parsing"

# For fsc28 execution and moving and assigning of the .arp file
${fsc_loc} -i ${prefix}.par -n1
mv ./${prefix}/*arp ./${prefix}.arp

echo "Arp file is there somewhere:>."


# Simulation of dummy sequence 
chmod +x dummygen_script.sh
./dummygen_script.sh -c ${input_file} -p ${prefix}
echo "dummy reference/ancestral sequence has materialized."

# Parsing the arp file for the SNP sequences (per sample) and loci. 
chmod +x ./parse_arp.sh
./parse_arp.sh -p ${prefix} -a ${prefix}.arp
echo "the SNPs and their locations should be available."

# Generating the FASTA file for each sample. 
chmod +x ./generatefasta_script.sh
./generatefasta_script.sh -p ${prefix} -i ${prefix}_indices.txt -r ${prefix}_tempseq.fa -s ${prefix}_SNPseq.csv
echo "fasta file should be there. go forth!"




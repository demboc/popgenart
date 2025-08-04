#!/bin/bash

# This is the wrapper script

# Making sure we have the inputs needed

input_file=""
prefix=""
fsc_loc=""
art_loc=""

while getopts "i:p:f:a:" opt; do
  case "$opt" in
    i) input_file="$OPTARG" ;;
    p) prefix="$OPTARG" ;;
    f) fsc_loc="$OPTARG" ;;
    a) art_loc="$OPTARG" ;;
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

if [[ -z "$input_file" || -z "$prefix" || -z "${fsc_loc}" || -z "${art_loc}" ]]; then
  echo "Usage: $0 -i <input_file> -p <prefix> -f <fsc_loc> -a <art_illumina_loc>" >&2
  exit 1
fi


exec > ${prefix}_wrapper.log 2>&1


echo "
               ┌──●            popgenART           ●──┐
            ┌──●──┐     Wrapper for PopGen SR Sim  ┌──●──┐
        ┌──●───●──●──┐     Simulation Log v1.0.0   ┌──●───●──●──┐
        │  └──┬──┬┘                                   └─┬─┬──┘  │
        │     ●  ●                                      ● ●     │
        │   ┌─●  ┐                                   ┌  ●─┐     │
        └───┘ ●  └───────────────────────────────────┘  ● └─────┘
"

echo "Wrapper script that streamlines the processes of population genomic data simulation followed by the molecular processes involved in Illumina sequencing"


echo "The inputs are complete. Analysis will proceed."


echo "The input csv file will be parsed to generate the input for fastsimcoal2."
# Execute script for parsing 
chmod +x parser_script.sh
./parser_script.sh -i ${input_file} -p ${prefix}
if [[ -f "${prefix}.par" ]]; then
    	echo "File ${prefix}.par created."
else
	echo "Error: Parsing unsuccesful."
	exit 1
fi

echo "Parsing complete."

# For fsc28 execution and moving and assigning of the .arp file


echo
echo "

=========================================

        popgenART: Fastsimcoal2 

=========================================
"
echo 
echo "Fastsimcoal2 will run with the ${prefix}.par as input."
${fsc_loc} -i ${prefix}.par -n1
mv ./${prefix}/*arp ./${prefix}.arp
if [[ -f "${prefix}.arp" ]]; then
        echo "File ${prefix}.arp created."
else
        echo "Error: Fastsimcoal2 unsuccesful."
        exit 1
fi
echo "SNP sites per sample have been generated."
echo "File saved as ${prefix}.arp"

# Simulation of dummy sequence 
echo "Reference sequence will be generated."
chmod +x dummygen_script.sh
./dummygen_script.sh -c ${input_file} -p ${prefix}
if [[ -f "${prefix}_tempseq.fa" ]]; then
        echo "File ${prefix}_tempseq.fa created."
else
        echo "Error: No reference sequence generated."
        exit 1
fi
echo "Reference sequence has been generated and saved at ${prefix}_tempseq.fa"

# Parsing the arp file for the SNP sequences (per sample) and loci.
echo "The arlequin file will be parsed for the the SNP sequences and loci."
chmod +x ./parse_arp.sh
./parse_arp.sh -p ${prefix} -a ${prefix}.arp
if [[ -f "${prefix}_SNPseq.csv" && -f "${prefix}_indices.txt" ]]; then
        echo "SNPs are saved in ${prefix}_SNPseq.csv"
	echo "Locations of SNPs saved in ${prefix}_indices.txt"
else
        echo "Error: SNPs and/or locations not saved."
        exit 1
fi
echo "Parsing of arlequin file completed."

# Generating the FASTA file for each sample.
echo "Sequences per sample will be produced."
chmod +x ./generatefasta_script.sh
./generatefasta_script.sh -p ${prefix} -i ${prefix}_indices.txt -r ${prefix}_tempseq.fa -s ${prefix}_SNPseq.csv
if [[ -f "${prefix}.fasta" ]]; then
        echo "File ${prefix}.fasta created."
else
        echo "Error: Sequences per sample not generated."
        exit 1
fi
echo "Simulated genomes per sample are stored in ${prefix}.fasta"

# Parsing file for art_illumina and running art_illumina
echo "ART_illumina will be performed to simulate library preparation and sequencing processes."
./art_illum.sh -p ${prefix} -i ${input_file} -a ${art_loc}
if compgen -G "*.fq" > /dev/null; then
    echo "Output files generated."
else
    echo "Error: Output files not generated."
    exit 1
fi


# Clean up 
mkdir ${prefix}_tempfiles
mkdir ${prefix}_inputfiles
mkdir ${prefix}_resultfiles

mv ${prefix} ${prefix}_tempfiles
mv ${prefix}_tempseq.fa ${prefix}_tempfiles
mv ${prefix}.par ${prefix}_inputfiles
mv ${prefix}.arp ${prefix}_inputfiles
mv ${prefix}_SNPseq.csv ${prefix}_tempfiles
mv ${prefix}_indices.txt ${prefix}_tempfiles
mv seed.txt ${prefix}_tempfiles

mv ${prefix}.fasta ${prefix}_resultfiles
mv *fq ${prefix}_resultfiles
mv *aln ${prefix}_resultfiles
mv *sam ${prefix}_resultfiles

echo "Result files from sample genome simulation and ART_illumina simulation are stored in the folder ${prefix}_resultfiles"


#!/bin/bash

# This is a parser script for the input file. 


# A way to have this file take in an input. 

in_file=""
prefix=""

while getopts "i:p:" opt; do
  case ${opt} in
    i) in_file="$OPTARG" ;;
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

if [[ -z "${in_file}" ]]; then
  echo "Error: Missing required -i <input_file> argument." >&2
  echo "Usage: $0 -i <input_file>" >&2
  exit 1
fi

if [[ -z "${prefix}" ]]; then
  echo "Error: Missing required -p <prefix> argument." >&2
  echo "Usage: $0 -p <prefix>" >&2
  exit 1
fi

echo "You have the required input files, diva!"

#extracting the parameter file. to be outputed AND to be used for the storing of variables

parfile="${prefix}.par"
awk '/^--EndofParFile--$/ { exit } { print }' ${in_file} > ${parfile} 

# Storing of variables (preliminary, only for 1 population)

# Counter
i=0


# Storing the variables in a matrix.
while IFS= read -r line; do
	[[ "${line}" =~ ^// ]] && continue # Will disregard the comment lines
	[[ -z "${line}" ]] && continue # Just in case there is an empty line

	values[$i]="${line}"
	((i++))
done < ${parfile}
echo "reading .par file ok"

variable_file="${prefix}.csv"
echo "Parameter,Value" > ${variable_file}

if [[ $i -eq 9 ]]; then
	# Assign to named variables
	num_demes="${values[0]}"
	pop_size="${values[1]}"
	sample_size="${values[2]}"
	growth_rate="${values[3]}"
	no_migration_matrix="${values[4]}"
	hist_event="${values[5]}"
	num_chrom="${values[6]}"
	num_blocks="${values[7]}"
	locus_params="${values[8]}"

	read data_type num_loci rec_rate mut_rate trans_rate <<< ${locus_params}
	
	echo "Pop_No,${num_demes}" >> ${variable_file}
       	echo "Pop_Size,${pop_size}" >> ${variable_file}
	echo "Sample_Size,${sample_size}" >> ${variable_file}
	echo "Growth_rate,${growth_rate}" >> ${variable_file}
	echo "No_Migration,${no_migration_matrix}" >> ${variable_file}
	echo "Hist_Event,${hist_event}" >> ${variable_file}
	echo "Num_Chrom,${num_chrom}" >> ${variable_file}
	echo "Num_Blocks,${num_blocks}" >> ${variable_file}
	echo "Data_Type,${data_type}" >> ${variable_file}
	echo "No_Loci,${num_loci}" >> ${variable_file}
	echo "Rec_Rate,${rec_rate}" >> ${variable_file}
	echo "Mut_Rate,${mut_rate}" >> ${variable_file}
	echo "Trans_Rate,${trans_rate}"	>> ${variable_file}

fi

echo "Made the .par file and csv file containing the parameter values:)"


awk '/^--EndofParFile--$/ {found=1; next} found' "${in_file}" >> ${variable_file}

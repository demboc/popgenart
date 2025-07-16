#!/bin/bash

# This is a parser script for the new input format

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


# Get the values to be written for the parameter file. 
parfile="${prefix}.par"

demes=$(grep "Demes" ${in_file} | awk -F',' '{print $2}')


if [ -z "$demes" ]; then
	echo "You did not set the number of populations :<"
	exit 1
else

	# Counts will depend on the number of populations
	# We will also build the .par file. 
	par_file="${prefix}.par"

	echo "//Number of populations" > ${par_file}
	echo "${demes}" >> ${par_file}

	# Population size
	line=$(grep "Pop_Size" ${in_file})
        values=${line#Pop_Size,}
	IFS=',' read -r -a pop_size <<< "${values}"
	echo "//Population effective sizes (number of genes)" >> ${par_file}
	#echo "${pop_size[@]}" >> ${par_file}
	for val in "${pop_size[@]}"; do
    		echo "$val" >> ${par_file}
	done

	# Sample size
	line=$(grep "Sample_Size" ${in_file})
	values=${line#Sample_Size,}
	IFS=',' read -r -a sample_size <<< "$values"
	echo "//Sample sizes " >> ${par_file}
	#echo "${sample_size[@]}"
	for val in "${sample_size[@]}"; do
                echo "$val" >> ${par_file}
        done


	line=$(grep "Growth_Rate" ${in_file})
        values=${line#Growth_Rate,}
        IFS=',' read -r -a growth_rate <<< "${values}"
        #echo "${growth_rate[@]}"
	echo "//Growth rate" >> ${par_file}
	for val in "${growth_rate[@]}"; do
                echo "$val" >> ${par_file}
        done


	# Migration events; If 0 -> no migration matrix; if not 0 -> with migration matrix 

	no_migmat=$(grep "No_Migration" ${in_file} | awk -F',' '{print $2}')
	echo "//Number of migration matrices: 0 implies no migration between demes" >> ${par_file}
	echo "${no_migmat}" >> ${par_file}

	if [[ ${no_migmat} -ne 0 ]]; then 
 		grep "Migration_Matrix" ${in_file} > "temp_migration_file.txt"
		while read -r line; do 
			echo "//Migration Matrix" >> ${par_file}
			line_ed=${line#Migration_Matrix,}
			IFS=',' read -r -a arr <<< "${line_ed}"
			for ((i=0; i<${#arr[@]}; i+=2)); do
				echo "${arr[i]} ${arr[i+1]}" >> ${par_file}
			done
		done < "temp_migration_file.txt" 	
	fi 

	# Historical events; If not 0 -> would have time, source, sink, migrants, new size, new growth rate, migration matrix
	hist_event=$(grep "Hist_Event" ${in_file} | awk -F',' '{print $2}')
	
	echo "//Historical event" >> ${par_file}
	echo "${hist_event}" >> ${par_file}

	if [[ ${hist_event} -ne 0 ]]; then
		#hist_event_par=$(grep "Hist_Event_Par" ${in_file} | awk -F',' '{print $2}')
		time=$(grep "Time" ${in_file} | awk -F',' '{print $2}')
		source_h=$(grep "Source" ${in_file} | awk -F',' '{print $2}')
		sink=$(grep "Sink" ${in_file} | awk -F',' '{print $2}')
		migrants=$(grep "Migrants" ${in_file} | awk -F',' '{print $2}')
		new_size=$(grep "New_Size" ${in_file} | awk -F',' '{print $2}')
		new_gr=$(grep "New_Growth" ${in_file} | awk -F',' '{print $2}')
		migr_m=$(grep "H_Migration_M" ${in_file} | awk -F',' '{print $2}')
		echo "${time} ${source_h} ${sink} ${migrants} ${new_size} ${new_gr} ${migr_m}" >> ${par_file}
	fi 
	
	# Number of independent loci
	num_chrom=$(grep "Num_Chrom" ${in_file} | awk -F',' '{print $2}')
	chrom_structure=$(grep "Chrom_Structure" ${in_file} | awk -F',' '{print $2}') #0 or 1 ata? indicates we want to describe different chromosomal structures.
	echo "//Number of independent loci [chromosome]" >> ${par_file}
	echo "${num_chrom} ${chrom_structure}" >> ${par_file}
	
	# Number of linkage blocks per chromosome
	num_blocks=$(grep "Num_Blocks" ${in_file} | awk -F',' '{print $2}')
	echo "//Per chromosome: Number of linkage blocks" >> ${par_file}
	echo "${num_blocks}" >> ${par_file}

	# Loc params
	data_type=$(grep "Data_Type" ${in_file} | awk -F',' '{print $2}')
	num_loci=$(grep "Num_Loci" ${in_file} | awk -F',' '{print $2}')
	recomb_rate=$(grep "Recomb_Rate" ${in_file} | awk -F',' '{print $2}')
	mut_rate=$(grep "Mut_Rate" ${in_file} | awk -F',' '{print $2}')
	trans_rate=$(grep "Trans_Rate" ${in_file} | awk -F',' '{print $2}')

	echo "//per Block: data type, num loci, rec. rate and mut rate + optional parameters" >> ${par_file}
	echo "${data_type} ${num_loci} ${recomb_rate} ${mut_rate} ${trans_rate}" >> ${par_file}

fi








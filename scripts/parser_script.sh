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

echo "All arguments for input parsing are complete."


# Get the values to be written for the parameter file. 
parfile="${prefix}.par"

demes=$(grep "Demes" ${in_file} | awk -F',' '{print $2}')


if [ -z "$demes" ]; then
	echo "Error: You did not set the number of populations."
	exit 1
else
	
	echo "The parameter file will be written."

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

	# Only proceed if there are any events
	if [[ ${hist_event} -ne 0 ]]; then
    		for ((i=1; i<=hist_event; i++)); do
       			 time=$(grep "Time_${i}" "${in_file}" | awk -F',' '{print $2}')
        		source_h=$(grep "Source_${i}" "${in_file}" | awk -F',' '{print $2}')
        		sink=$(grep "Sink_${i}" "${in_file}" | awk -F',' '{print $2}')
        		migrants=$(grep "Migrants_${i}" "${in_file}" | awk -F',' '{print $2}')
        		new_size=$(grep "New_Size_${i}" "${in_file}" | awk -F',' '{print $2}')
       			new_gr=$(grep "New_Growth_${i}" "${in_file}" | awk -F',' '{print $2}')
        		migr_m=$(grep "H_Migration_M_${i}" "${in_file}" | awk -F',' '{print $2}')

        		echo "${time} ${source_h} ${sink} ${migrants} ${new_size} ${new_gr} ${migr_m}" >> "${par_file}"
    		done
	fi
	


	# Read main chromosomal info
	num_chrom=$(grep "Num_Chrom" "${in_file}" | awk -F',' '{print $2}')
	chrom_structure=$(grep "Chrom_Structure" "${in_file}" | awk -F',' '{print $2}')

	echo "//Number of independent loci [chromosome]" >> "${par_file}"
	echo "${num_chrom} ${chrom_structure}" >> "${par_file}"



	# Loop over chromosomes
	for ((c=1; c<=num_chrom; c++)); do
    		num_blocks=$(grep "Num_Blocks_${c}" "${in_file}" | awk -F',' '{print $2}')
    		echo "//Per chromosome: Number of linkage blocks" >> "${par_file}"
		echo "${num_blocks}" >> "${par_file}"

   		 # Loop over linkage blocks in chromosome c
    		echo "//per Block: data type, num loci, rec. rate and mut rate + optional parameters" >> "${par_file}"
		 for ((b=1; b<=num_blocks; b++)); do
        		# Convert b to letter (1 → a, 2 → b, etc.)
        		block_letter=$(printf \\$(printf '%03o' $((96 + b))))

        		prefix="${c}${block_letter}"  # e.g., 1a, 1b, 2a

        		data_type=$(grep "Data_Type_${prefix}" "${in_file}" | awk -F',' '{print $2}')
        		num_loci=$(grep "Num_Loci_${prefix}" "${in_file}" | awk -F',' '{print $2}')
        		recomb_rate=$(grep "Recomb_Rate_${prefix}" "${in_file}" | awk -F',' '{print $2}')
       			mut_rate=$(grep "Mut_Rate_${prefix}" "${in_file}" | awk -F',' '{print $2}')
       			trans_rate=$(grep "Trans_Rate_${prefix}" "${in_file}" | awk -F',' '{print $2}')


        		echo "${data_type} ${num_loci} ${recomb_rate} ${mut_rate} ${trans_rate}" >> "${par_file}"
    		done
	done
fi







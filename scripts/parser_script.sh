#!/bin/bash

# Usage: ./parser_script.sh <input_file> <prefix>

in_file="$1"
prefix="$2"

if [[ -z "${in_file}" || -z "${prefix}" ]]; then
  echo "Usage: $0 <input_file> <prefix>" >&2
  exit 1
fi

echo "You have the required input files, diva!"

# Build output filename
parfile="${prefix}.par"

demes=$(grep "Demes" ${in_file} | awk -F',' '{print $2}')

if [ -z "$demes" ]; then
  echo "You did not set the number of populations :<"
  exit 1
else
  echo "//Number of populations" > "${parfile}"
  echo "${demes}" >> "${parfile}"

  line=$(grep "Pop_Size" ${in_file})
  values=${line#Pop_Size,}
  IFS=',' read -r -a pop_size <<< "${values}"
  echo "//Population effective sizes (number of genes)" >> "${parfile}"
  for val in "${pop_size[@]}"; do
    echo "$val" >> "${parfile}"
  done

  line=$(grep "Sample_Size" ${in_file})
  values=${line#Sample_Size,}
  IFS=',' read -r -a sample_size <<< "$values"
  echo "//Sample sizes " >> "${parfile}"
  for val in "${sample_size[@]}"; do
    echo "$val" >> "${parfile}"
  done

  line=$(grep "Growth_Rate" ${in_file})
  values=${line#Growth_Rate,}
  IFS=',' read -r -a growth_rate <<< "${values}"
  echo "//Growth rate" >> "${parfile}"
  for val in "${growth_rate[@]}"; do
    echo "$val" >> "${parfile}"
  done

  no_migmat=$(grep "No_Migration" ${in_file} | awk -F',' '{print $2}')
  echo "//Number of migration matrices: 0 implies no migration between demes" >> "${parfile}"
  echo "${no_migmat}" >> "${parfile}"

  if [[ ${no_migmat} -ne 0 ]]; then 
    grep "Migration_Matrix" ${in_file} > "temp_migration_file.txt"
    while read -r line; do 
      echo "//Migration Matrix" >> "${parfile}"
      line_ed=${line#Migration_Matrix,}
      IFS=',' read -r -a arr <<< "${line_ed}"
      for ((i=0; i<${#arr[@]}; i+=2)); do
        echo "${arr[i]} ${arr[i+1]}" >> "${parfile}"
      done
    done < "temp_migration_file.txt" 	
  fi 

  hist_event=$(grep "Hist_Event" ${in_file} | awk -F',' '{print $2}')
  echo "//Historical event" >> "${parfile}"
  echo "${hist_event}" >> "${parfile}"

  if [[ ${hist_event} -ne 0 ]]; then
    time=$(grep "Time" ${in_file} | awk -F',' '{print $2}')
    source_h=$(grep "Source" ${in_file} | awk -F',' '{print $2}')
    sink=$(grep "Sink" ${in_file} | awk -F',' '{print $2}')
    migrants=$(grep "Migrants" ${in_file} | awk -F',' '{print $2}')
    new_size=$(grep "New_Size" ${in_file} | awk -F',' '{print $2}')
    new_gr=$(grep "New_Growth" ${in_file} | awk -F',' '{print $2}')
    migr_m=$(grep "H_Migration_M" ${in_file} | awk -F',' '{print $2}')
    echo "${time} ${source_h} ${sink} ${migrants} ${new_size} ${new_gr} ${migr_m}" >> "${parfile}"
  fi 

  num_chrom=$(grep "Num_Chrom" ${in_file} | awk -F',' '{print $2}')
  chrom_structure=$(grep "Chrom_Structure" ${in_file} | awk -F',' '{print $2}')
  echo "//Number of independent loci [chromosome]" >> "${parfile}"
  echo "${num_chrom} ${chrom_structure}" >> "${parfile}"

  num_blocks=$(grep "Num_Blocks" ${in_file} | awk -F',' '{print $2}')
  echo "//Per chromosome: Number of linkage blocks" >> "${parfile}"
  echo "${num_blocks}" >> "${parfile}"

  data_type=$(grep "Data_Type" ${in_file} | awk -F',' '{print $2}')
  num_loci=$(grep "Num_Loci" ${in_file} | awk -F',' '{print $2}')
  recomb_rate=$(grep "Recomb_Rate" ${in_file} | awk -F',' '{print $2}')
  mut_rate=$(grep "Mut_Rate" ${in_file} | awk -F',' '{print $2}')
  trans_rate=$(grep "Trans_Rate" ${in_file} | awk -F',' '{print $2}')
  echo "//per Block: data type, num loci, rec. rate and mut rate + optional parameters" >> "${parfile}"
  echo "${data_type} ${num_loci} ${recomb_rate} ${mut_rate} ${trans_rate}" >> "${parfile}"
fi

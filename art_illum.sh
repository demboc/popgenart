#!/bin/bash

# Usage: ./art_illum.sh <prefix> <input_csv> <art_location>

if [[ "$#" -ne 3 ]]; then
  echo "Usage: $0 <prefix> <input_csv> <art_location>" >&2
  exit 1
fi

prefix="$1"
inloc="$2"
artloc="$3"

echo "Input ok."

# Build command
art_illum_line="${artloc}"

# Optional output flags
sam_file=$(grep "SAM_File" "$inloc" | awk -F',' '{print $2}')
aln_file=$(grep "Alignment_File" "$inloc" | awk -F',' '{print $2}')

[[ "$sam_file" == "Yes" ]] && art_illum_line+=" -sam"
[[ "$aln_file" == "No" ]] && art_illum_line+=" -na"

# Required
filename="${prefix}.fasta"
read_length=$(grep "Read_Length" "$inloc" | awk -F',' '{print $2}')
fold_cov=$(grep "Fold_Coverage" "$inloc" | awk -F',' '{print $2}' | xargs)
total_reads=$(grep "Total_Reads" "$inloc" | awk -F',' '{print $2}' | xargs)

art_illum_line+=" -i ${filename} -l ${read_length}"

if [[ -n "$fold_cov" && -n "$total_reads" ]]; then
  echo "Both Fold_Coverage and Total_Reads have values. Only one is allowed."
  exit 1
elif [[ -n "$fold_cov" ]]; then
  art_illum_line+=" -f ${fold_cov}"
elif [[ -n "$total_reads" ]]; then
  art_illum_line+=" -c ${total_reads}"
fi

# Mode
seq_mode=$(grep "Sequencing_Mode" "$inloc" | awk -F',' '{print $2}' | xargs)
if [[ "$seq_mode" != "paired" && "$seq_mode" != "single" && "$seq_mode" != "matepair" ]]; then
  echo "Error: seq_mode must be one of: paired, single, matepair"
  exit 1
fi

# Defaults
ins_rate1=$(grep "Insertion_Rate_FR" "$inloc" | awk -F',' '{print $2}' | xargs)
del_rate1=$(grep "Deletion_Rate_FR" "$inloc" | awk -F',' '{print $2}' | xargs)
qs_shift1=$(grep "QS_Shift_FR" "$inloc" | awk -F',' '{print $2}' | xargs)
masking_cut=$(grep "Masking_Cutoff" "$inloc" | awk -F',' '{print $2}' | xargs)

ins_rate1=${ins_rate1:-0.00009}
del_rate1=${del_rate1:-0.00011}
qs_shift1=${qs_shift1:-0}
masking_cut=${masking_cut:-1}

# Mode-based
if [[ "$seq_mode" == "single" ]]; then
  art_illum_line+=" -nf ${masking_cut} -ir ${ins_rate1} -dr ${del_rate1} -qs ${qs_shift1}"

elif [[ "$seq_mode" == "paired" || "$seq_mode" == "matepair" ]]; then
  ins_rate2=$(grep "Insertion_Rate_SR" "$inloc" | awk -F',' '{print $2}' | xargs)
  del_rate2=$(grep "Deletion_Rate_SR" "$inloc" | awk -F',' '{print $2}' | xargs)
  qs_shift2=$(grep "QS_Shift_SR" "$inloc" | awk -F',' '{print $2}' | xargs)

  ins_rate2=${ins_rate2:-0.00015}
  del_rate2=${del_rate2:-0.00023}
  qs_shift2=${qs_shift2:-0}

  mean_frag=$(grep "Mean_Frag_Size" "$inloc" | awk -F',' '{print $2}' | xargs)
  stdv_frag=$(grep "Stdv_Frag_Size" "$inloc" | awk -F',' '{print $2}' | xargs)

  art_illum_line+=" -nf ${masking_cut} -p -m ${mean_frag} -s ${stdv_frag} -ir ${ins_rate1} -ir2 ${ins_rate2} -dr ${del_rate1} -dr2 ${del_rate2} -qs ${qs_shift1} -qs2 ${qs_shift2}"
fi

# Optional flags
[[ "$(grep "Error_Free" "$inloc" | awk -F',' '{print $2}')" == "Yes" ]] && art_illum_line+=" -ef"
[[ "$(grep "Separate_QS" "$inloc" | awk -F',' '{print $2}')" == "Yes" ]] && art_illum_line+=" -sp"

seq_system=$(grep "Sequencing_System" "$inloc" | awk -F',' '{print $2}')
if [[ -n "$seq_system" ]]; then
  if [[ "$seq_system" =~ ^(GA1|GA2|HS25|HS10|HS20|MS)$ ]]; then
    art_illum_line+=" -ss ${seq_system}"
  else
    echo "Error: Invalid seq_system: $seq_system"
    exit 1
  fi
fi

art_illum_line+=" -o ${prefix}"

echo "$art_illum_line"
eval "$art_illum_line"

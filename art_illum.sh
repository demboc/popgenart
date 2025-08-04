#!/bin/bash

# This is a scrit to parse input file & run art_illumina

# Check if input is ok

echo
echo "

=========================================

        popgenART: Run ART_illumina

=========================================
"
echo 

while getopts "p:i:a:" opt; do
  case "$opt" in

    p) prefix="$OPTARG" ;;
    a) artloc="$OPTARG" ;;
    i) inloc="$OPTARG" ;;

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

if [[ -z "$prefix" || -z "$artloc" || -z "$inloc" ]]; then
  echo "Usage: $0 -p <prefix> -a <artloc> -i <input csv>" >&2
  exit 1
fi

echo "Complete arguments for art_illumina script."



# Building the input line. Stored in this variable

echo "Building the command for art_illumina by parsing the input file for the arguments."

art_illum_line="${artloc}"


# Specify output files

sam_file=$(grep "SAM_File" ${inloc} | awk -F',' '{print $2}')
aln_file=$(grep "Alignment_File" ${inloc} | awk -F',' '{print $2}')

if [[ "$sam_file" == "Yes" ]]; then
    art_illum_line+=" -sam"
fi

if [[ "$aln_file" == "No" ]]; then
    art_illum_line+=" -na"
fi


# Process required options first

filename=${prefix}.fasta
read_length=$(grep "Read_Length" ${inloc} | awk -F',' '{print $2}')
fold_cov=$(grep "Fold_Coverage" ${inloc} | awk -F',' '{print $2}' | xargs)
total_reads=$(grep "Total_Reads" ${inloc} | awk -F',' '{print $2}' | xargs)


art_illum_line+=" -i ${filename} -l ${read_length}"


if [[ -n "$fold_cov" && -n "$total_reads" ]]; then
    echo "Both Fold_Coverage and Total_Reads have values. You can only have one."
    exit 1

elif [[ -n "$fold_cov" ]]; then
	art_illum_line+=" -f ${fold_cov}"

elif [[ -n "${total_reads}" ]]; then
	art_illum_line+=" -c ${total_reads}"
fi

# Indicate the sequencing mode
seq_mode=$(grep "Sequencing_Mode" ${inloc} | awk -F',' '{print $2}' | xargs)
if [[ "$seq_mode" != "paired" && "$seq_mode" != "single" && "$seq_mode" != "matepair" ]]; then
    echo "Error: seq_mode must be one of: paired, single, matepair"
    exit 1
fi

# Customizable stuff (with default values, but can be changed.
ins_rate1=$(grep "Insertion_Rate_FR" ${inloc} | awk -F',' '{print $2}' | xargs)
if [[ -z  "${ins_rate1}" ]]; then
	ins_rate1=0.00009
fi 

del_rate1=$(grep "Deletion_Rate_FR" ${inloc} | awk -F',' '{print $2}' | xargs)
if [[ -z  "${del_rate1}" ]]; then
        del_rate1=0.00011
fi

qs_shift1=$(grep "QS_Shitf_FR" ${inloc} | awk -F',' '{print $2}' | xargs)
if [[ -z  "${qs_shift1}" ]]; then
        qs_shift1=0
fi
masking_cut=$(grep "Masking_Cutoff" ${inloc} | awk -F',' '{print $2}' | xargs)
if [[ -z  "${masking_cut}" ]]; then
        masking_cut=1
fi


if [[ $seq_mode = "single" ]]; then
	art_illum_line+=" -nf ${masking_cut} -ir ${ins_rate1} -dr ${del_rate1} -qs ${qs_shift1}"
elif [[ $seq_mode = "paired" ]]; then
	ins_rate2=$(grep "Insertion_Rate_SR" ${inloc} | awk -F',' '{print $2}' | xargs)
	if [[ -z  "${ins_rate2}" ]]; then
        	ins_rate2=0.00015
	fi 

	del_rate2=$(grep "Deletion_Rate_SR" ${inloc} | awk -F',' '{print $2}' | xargs)
	if [[ -z  "${del_rate2}" ]]; then
        	del_rate2=0.00023
	fi	

	qs_shift2=$(grep "QS_Shitf_SR" ${inloc} | awk -F',' '{print $2}' | xargs)
	if [[ -z  "${qs_shift2}" ]]; then
        	qs_shift2=0
	fi

	mean_frag=$(grep "Mean_Frag_Size" ${inloc} | awk -F',' '{print $2}' | xargs)
	stdv_frag=$(grep "Stdv_Frag_Size" ${inloc} | awk -F',' '{print $2}' | xargs)

	art_illum_line+=" -nf ${masking_cut} -p -m ${mean_frag} -s ${stdv_frag}  -ir ${ins_rate1} -ir2 ${ins_rate2} -dr ${del_rate1} -dr2 ${del_rate2} -qs ${qs_shift1} -qs2 ${qs_shift2}"	
	
elif [[ $seq_mode = "matepair" ]]; then

	 ins_rate2=$(grep "Insertion_Rate_SR" ${inloc} | awk -F',' '{print $2}' | xargs)
        if [[ -z  "${ins_rate2}" ]]; then
                ins_rate2=0.00015
        fi

        del_rate2=$(grep "Deletion_Rate_SR" ${inloc} | awk -F',' '{print $2}' | xargs)
        if [[ -z  "${del_rate2}" ]]; then
                del_rate2=0.00023
        fi

        qs_shift2=$(grep "QS_Shitf_SR" ${inloc} | awk -F',' '{print $2}' | xargs)
        if [[ -z  "${qs_shift2}" ]]; then
                qs_shift2=0
        fi

	mean_frag=$(grep "Mean_Frag_Size" ${inloc} | awk -F',' '{print $2}' | xargs)
        stdv_frag=$(grep "Stdv_Frag_Size" ${inloc} | awk -F',' '{print $2}' | xargs)

        art_illum_line+=" -nf ${masking_cut} -p -m ${mean_frag} -s ${stdv_frag}  -ir ${ins_rate1} -ir2 ${ins_rate2} -dr ${del_rate1} -dr2 ${del_rate2} -qs ${qs_shift1} -qs2 ${qs_shift2}"


fi



# Additional flags

err_free=$(grep "Error_Free" ${inloc} | awk -F',' '{print $2}')
if [[ "$err_free" == "Yes" ]]; then
    art_illum_line+=" -ef"
fi

sep_qp=$(grep "Separate_QS" ${inloc} | awk -F',' '{print $2}')
if [[ "$sep_qp" == "Yes" ]]; then
    art_illum_line+=" -sp"
fi

seq_system=$(grep "Sequencing_System" ${inloc} | awk -F',' '{print $2}')
if [[ -n "$seq_system" ]]; then
    if [[ "$seq_system" != "HSXn" && "$seq_system" != "HSXt" && "$seq_system" != "MSv1" && "$seq_system" != "MSv3" && "$seq_system" != "MinS" && "$seq_system" != "NS50" && "$seq_system" != "HS20" && "$seq_system" != "HS10" && "$seq_system" != "GA1" && "$seq_system" != "GA2" && "$seq_system" != "HS25" ]]; then
        echo "Error: If seq_system is set, it must be one of: GA1, GA2, HS25, HS10, HS20, HSXn, HSXt, MinS, MSv1, MSv3, NS50"
        exit 1
    fi
    art_illum_line+=" -ss ${seq_system}"
fi

art_illum_line+=" -o ${prefix}"


#echo "$art_illum_line"

echo "Run art_illumina command."
eval "$art_illum_line"















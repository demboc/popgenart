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


num_loci=$(grep "No_Loci" ${csv_file} | awk -F, '{ print $2 }')
echo "${num_loci}"
GnC=$(grep "GC_Con" ${csv_file} | awk -F, '{ print $2 }')
echo "${GnC}"
GC=$(awk "BEGIN {print $GnC / 2}")
AT=$(awk "BEGIN {print 0.5 - $GC}")

hpc r-base:3.6.2 Rscript -e "cat(sample(c('A','T','C','G'), size=${num_loci}, replace=TRUE, prob=c(${AT},${AT},${GC},${GC})), sep='')" > ${prefix}_tempseq.fa

echo "Made the dummy sequence"



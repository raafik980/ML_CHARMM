#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 q12.inp q12.out <output_file>"
  exit 1
fi

#Output File
output_file="$3"




# Remove existing files
rm -f q12e.out q12qmf.out q12mmf.out q12mmf_mod.out  q12rev.out


#To debugg MLP predictions

mkdir -p error_coords

if grep -q 'nan' q12.out; then
    # If 'nan' exists, create a new error folder
    error_folder="error_coords/error_folder_$(ls -1 error_coords | wc -l)"

    # Create the error folder
    mkdir "$error_folder"

    # Copy q12.inp and q12.out to the error folder
    cp q12.inp "$error_folder"
    cp q12.out "$error_folder"
fi



# Task 1: Extract values from the first line of q12.inp
if [ -f "$1" ]; then
  read -r n_qmatoms n_mmatoms charge mult dummy < "$1"
else
  echo "Error: $1 not found"
  exit 1
fi

# Task 2: Split q12.out into three files
if [ -f "$2" ]; then
  head -n 1 "$2" > q12e.out
  tail -n +2 "$2" | head -n "$((n_qmatoms))" > q12qmf.out
  tail -n "+$((n_qmatoms + 2))" "$2" | head -n "$((n_mmatoms))" > q12mmf.out

  # This line is to replace 'nan' forces to zero, but have to investigate further on this
  awk '{ for (i=1; i<=NF; i++) { if ($i == "nan") $i = "0"; printf "%23s", $i } printf "\n" }' q12mmf.out > q12mmf_mod.out
else
  echo "Error: $2 not found"
  exit 1
fi



cat q12e.out q12mmf_mod.out q12qmf.out > "$output_file"


#echo "Values from q12.inp:"
#echo "n_qmatoms: $n_qmatoms"
#echo "n_mmatoms: $n_mmatoms"
#echo "charge: $charge"
#echo "mult: $mult"
#echo "dummy: $dummy"


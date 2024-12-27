#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

input_file="$1"
output_file="q12.inp"

# Remove q12.inp if it already exists
if [ -f "$output_file" ]; then
    rm "$output_file"
fi


if [ ! -f "$input_file" ]; then
    echo "Error: File '$input_file' not found."
    exit 1
fi

# Read the content of the input file and replace characters
modified_content=$(sed -e 's/H/1/g' -e 's/C/6/g' -e 's/N/7/g' -e 's/O/8/g' "$input_file")


# Step 2: Combine first and second lines into a single line
modified_content=$(awk 'NR == 1 { printf $0 } NR == 2 { printf " " $0 } NR > 2 { printf "\n" $0 } END { printf "\n" }' <<< "$modified_content")

echo "$modified_content" > "$output_file"



echo "Conversion complete. Modified content saved in '$output_file'."


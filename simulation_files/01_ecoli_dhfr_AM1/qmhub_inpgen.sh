#!/bin/bash

# Check if an argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

# Input file path
input_file="$1"

# Output file path
output_file="q11.inp"

# Remove q11.inp if it already exists
if [ -f "$output_file" ]; then
    rm "$output_file"
fi

# Calculate value_1 and value_2
value_1=$(awk '/\$molecule/,/\$end/ { count++ } END { print count - 3 }' "$input_file")
value_2=$(awk '/\$external_charges/,/\$end/ { count++ } END { print count - 2 }' "$input_file")

# Add value_1 and value_2 at the beginning of the output file
echo "$value_1 $value_2" > "$output_file"

# Perform the modifications and rearrangement
awk '/\$molecule/,/\$end/ { molecule_block = molecule_block $0 "\n" }
     /\$external_charges/,/\$end/ { external_block = external_block $0 "\n" }
     /\$box/,/\$end/ { box_block = box_block $0 "\n" }
     END {
         print molecule_block "\n" external_block "\n" box_block
     }' "$input_file" \
     | sed '/^\s*$/d; /^\$/d' | tr -s ' ' >> "$output_file"

echo "Modified input saved as $output_file"


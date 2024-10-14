#!/bin/bash

# Check if output directory is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <output_directory>"
    echo "Please provide the output directory as an argument."
    exit 1
fi

# Output directory from command line argument
output_dir="$1"

# Predefined mappings
declare -a input_files=(
    "./stb_image.h" # image
    "./stb_image_resize2.h" # resize
    "./stb_image_write.h" # write
)

declare -a split_tokens=(
    "#ifdef STB_IMAGE_IMPLEMENTATION" # image
    "#if defined(STB_IMAGE_RESIZE_IMPLEMENTATION) || defined(STB_IMAGE_RESIZE2_IMPLEMENTATION)" #resize
    "#ifdef STB_IMAGE_WRITE_IMPLEMENTATION" # write
)

# Function to split a file
split_file() {
    local input_file="$1"
    local split_token="$2"
    
    # Get the base name of the input file
    local base_name=$(basename "$input_file")
    local base_name_no_ext="${base_name%.*}"
    
    # Output file
    local output_file="$output_dir/${base_name_no_ext}.c"
    
    # Check if the input file exists
    if [ ! -f "$input_file" ]; then
        echo "Input file does not exist: $input_file"
        return 1
    fi
    
    # Find the line number of the split token
    local line_number=$(grep -n "$split_token" "$input_file" | cut -d: -f1 | head -n 1)
    
    if [ -z "$line_number" ]; then
        echo "Split token '$split_token' not found in the file: $input_file"
        return 1
    fi
    
    # Extract content from the line number to the end of the file
    tail -n +$line_number "$input_file" > "$output_file"
    
    # Remove the extracted content from the original file
    head -n $((line_number - 1)) "$input_file" > "${input_file}.tmp" && mv "${input_file}.tmp" "$input_file"
    
    echo "Splitting complete for $input_file"
    echo "Output file: $output_file"
}

# Main execution
echo "Starting file splitting process..."

# Check if output directory exists, create if it doesn't
if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
    echo "Created output directory: $output_dir"
fi

# Loop through the files and split them
for i in "${!input_files[@]}"; do
    echo "Processing ${input_files[$i]}..."
    split_file "${input_files[$i]}" "${split_tokens[$i]}"
    echo "------------------------"
done

echo "All files processed."
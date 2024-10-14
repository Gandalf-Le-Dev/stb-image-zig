#!/bin/bash

# Check if output directory is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <project_header_directory>"
    echo "Please provide the project header directory as an argument."
    exit 1
fi

project_header_dir="$1"

# Directory where the script will clone the stb repository
STB_REPO_DIR="/tmp/stb_repo"

# GitHub URL for the stb repository
STB_REPO_URL="https://github.com/nothings/stb.git"


# List of stb header files you want to update
declare -a STB_HEADERS=(
    "stb_image.h"
    "stb_image_write.h"
    "stb_image_resize2.h"
)

# Function to clone or update the stb repository
update_stb_repo() {
    if [ -d "$STB_REPO_DIR" ]; then
        echo "Updating existing stb repository..."
        cd "$STB_REPO_DIR"
        git pull
    else
        echo "Cloning stb repository..."
        git clone "$STB_REPO_URL" "$STB_REPO_DIR"
    fi
}

# Function to copy header files
copy_headers() {
    for header in "${STB_HEADERS[@]}"; do
        if [ -f "$STB_REPO_DIR/$header" ]; then
            echo "Copying $header to $project_header_dir"
            cp "$STB_REPO_DIR/$header" "$project_header_dir"
        else
            echo "Warning: $header not found in the stb repository"
        fi
    done
}

# Main execution
echo "Starting stb header update process..."

# Update or clone the stb repository
update_stb_repo

# Check if the update/clone was successful
if [ $? -ne 0 ]; then
    echo "Failed to update/clone the stb repository. Exiting."
    exit 1
fi

# Create the project header directory if it doesn't exist
if [ ! -d "$project_header_dir" ]; then
    echo "Creating project header directory: $project_header_dir"
    mkdir -p "$project_header_dir"
fi

# Copy the header files
copy_headers

echo "stb header update process completed."
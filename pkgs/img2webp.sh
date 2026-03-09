#!/usr/bin/env bash

# This script recursively converts images (jpg, png, etc.) to webp 
# and places them in [current_dir_name]_webp_converted in the parent directory.

# Get the name of the current directory to form the output directory name
ORIGIN_DIR_NAME=$(basename "$PWD")
TARGET_DIR="../${ORIGIN_DIR_NAME}_webp_converted"

echo "Creating target directory: $TARGET_DIR"
mkdir -p "$TARGET_DIR"

# Find image files (case-insensitive extensions)
find . -type f -regextype posix-extended -iregex '.*\.(jpg|jpeg|png|bmp|tiff|gif)' | while read -r img; do
    # Remove leading './'
    rel_path="${img#./}"
    # Target filename with .webp extension
    target_path="${TARGET_DIR}/${rel_path%.*}.webp"
    
    # Create the same subdirectory structure in the target folder
    mkdir -p "$(dirname "$target_path")"
    
    # Skip if target already exists and is newer than source (optional optimization)
    if [[ "$img" -nt "$target_path" ]]; then
        echo "Converting: $rel_path"
        magick "$img" "$target_path"
    else
        echo "Skipping (already up to date): $rel_path"
    fi
done

echo "Conversion complete! Files are in $TARGET_DIR"

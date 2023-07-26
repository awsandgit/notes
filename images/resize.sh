#!/bin/bash

# Check if ImageMagick (convert command) is installed
if ! command -v convert &>/dev/null; then
  echo "ImageMagick (convert command) is not installed. Please install it first."
  exit 1
fi

# Check if at least one argument (image file) is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <image1> [image2] [image3] ..."
  exit 1
fi

# Function to resize an image to 600x400
resize_image() {
  local input_file="$1"
  local output_file="${input_file%.*}_resized.png"

  convert "$input_file" -resize 600x400 "$output_file"
  echo "Resized $input_file to $output_file"
}

# Loop through all provided image files and resize each one
for image_file in "$@"; do
  resize_image "$image_file"
done


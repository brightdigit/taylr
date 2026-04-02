#!/bin/bash

# Function to print usage
usage() {
  echo "Usage: $0 -d directory -c copyright_holder -p project [-y year]"
  echo "  -d directory        Directory to read from (including subdirectories)"
  echo "  -c copyright_holder Copyright holder name"
  echo "  -p project          Project name"
  echo "  -y year             Copyright year (optional, defaults to current year)"
  exit 1
}

# Get the current year
current_year=$(date +"%Y")

# Default values
year="$current_year"

# Parse arguments
while getopts ":d:c:p:y:" opt; do
  case $opt in
    d) directory="$OPTARG" ;;
    c) copyright_holder="$OPTARG" ;;
    p) project="$OPTARG" ;;
    y) year="$OPTARG" ;;
    *) usage ;;
  esac
done

# Check for mandatory arguments
if [ -z "$directory" ] || [ -z "$copyright_holder" ] || [ -z "$project" ]; then
  usage
fi

# Define the header template (standard Swift format with two-space indentation)
header_template="//
//  %s
//  %s
//
//  Copyright (c) %s %s.
//  All rights reserved.
//"

# Loop through each Swift file in the specified directory and subdirectories
find "$directory" -type f -name "*.swift" | while read -r file; do
  # Check if the first line is the swift-format-ignore indicator
  first_line=$(head -n 1 "$file")
  swift_format_ignore=""
  if [[ "$first_line" == "// swift-format-ignore-file" ]]; then
    swift_format_ignore="$first_line"
    echo "Preserving swift-format-ignore directive in $file"
  fi

  # Check if the first line is a swift-tools-version directive
  swift_tools_version=""
  if [[ "$first_line" =~ ^//\ swift-tools-version: ]]; then
    swift_tools_version="$first_line"
    echo "Preserving swift-tools-version directive in $file"
  fi

  # Create the header with the current filename
  filename=$(basename "$file")
  header=$(printf "$header_template" "$filename" "$project" "$year" "$copyright_holder")

  # Remove all consecutive lines at the beginning which start with "// ", contain only whitespace, or only "//"
  awk '
  BEGIN { skip = 1 }
  {
    if (skip && ($0 ~ /^\/\/ / || $0 ~ /^\/\/$/ || $0 ~ /^$/)) {
      next
    }
    skip = 0
    print
  }' "$file" > temp_file

  # Add the header to the cleaned file with preserved directives
  if [ -n "$swift_tools_version" ]; then
    (echo "$swift_tools_version"; echo "$header"; echo; cat temp_file) > "$file"
  elif [ -n "$swift_format_ignore" ]; then
    (echo "$swift_format_ignore"; echo "$header"; echo; cat temp_file) > "$file"
  else
    (echo "$header"; echo; cat temp_file) > "$file"
  fi
  
  # Remove the temporary file
  rm temp_file
done

echo "Headers added or files skipped appropriately across all Swift files in the directory and subdirectories."
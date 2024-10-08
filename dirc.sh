#!/bin/bash

# Loop through all directories in the current directory
for dir in */; do
    # Use find to count files within the directory (including subdirectories)
    file_count=$(find "$dir" -type f | wc -l)
    echo "$dir has $file_count files"
done


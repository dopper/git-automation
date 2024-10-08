#!/bin/bash

# Loop through all directories (including hidden ones) in the current directory
for dir in $(find . -maxdepth 1 -type d \
    -not -path "./Library" \
    -not -path "./Library/*" \
    -not -path "./System" \
    -not -path "./Volumes" \
    -not -path "./private" \
    -not -path "./dev" \
    -not -path "./bin" \
    -not -path "./sbin" \
    -not -path "./Pictures/Photos Library.photoslibrary"); do
    
    # Use find to count files within the directory (including hidden subdirectories)
    file_count=$(find "$dir" -type f 2>/dev/null | wc -l)
    
    # Use du to calculate the size of the directory
    dir_size=$(du -sh "$dir" 2>/dev/null | cut -f1)
    
    echo "$dir has $file_count files and is $dir_size in size"
done


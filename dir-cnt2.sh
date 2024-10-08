#!/bin/bash

# Set the default threshold to 10000 if not provided as an argument
THRESHOLD=${1:-10000}

echo "Using file count threshold: $THRESHOLD"
echo ""

# Function to analyze directories recursively
analyze_directory() {
    local dir=$1
    local level=$2

    # Count the total number of files in the current directory (including subdirectories)
    file_count=$(find "$dir" -type f | wc -l)

    # Calculate the size of the directory
    dir_size=$(du -sh "$dir" | cut -f1)

    # Display the total number of files and size at this level
    if [ "$file_count" -gt "$THRESHOLD" ]; then
        echo "Level $level: $dir has $file_count files and is $dir_size in size."
    fi

    # Check if the file count exceeds the threshold
    if [ "$file_count" -gt "$THRESHOLD" ]; then
        echo "$dir exceeds the threshold of $THRESHOLD files."
        echo "Recommended commands to archive:"
        echo "  - Zip: zip -r ${dir%/}.zip $dir"
        echo "  - Tar: tar -cvf ${dir%/}.tar $dir"
        echo ""

        # Go one level deeper to analyze subdirectories if the current directory exceeds the threshold
        for subdir in "$dir"*/; do
            if [ -d "$subdir" ]; then
                analyze_directory "$subdir" $((level+1))
            fi
        done
    else
        # echo "$dir is under the file count threshold."
	:
    fi
}

# Loop through all top-level directories
for dir in */; do
    if [ -d "$dir" ]; then
        echo "Analyzing top-level directory: $dir"
        analyze_directory "$dir" 1
        echo ""
    fi
done


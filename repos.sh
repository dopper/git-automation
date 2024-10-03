#!/bin/bash

# Go through each subdirectory (one level deep)
for dir in */; do
  # Check if the directory is a git repository
  if [ -d "$dir/.git" ]; then
    echo "Directory: $dir"
    # Navigate into the directory
    cd "$dir"
    # Get the git remote origin URL
    git remote get-url origin
    # Go back to the parent directory
    cd ..
  else
    echo "Directory: $dir is not a Git repository"
  fi
done


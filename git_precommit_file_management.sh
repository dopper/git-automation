#!/bin/bash

# Function to check if Git LFS is installed
check_git_lfs() {
    if ! command -v git-lfs &> /dev/null; then
        echo "ERROR: Git LFS is not installed. Please install it and try again."
        exit 1
    fi
}

# Parse command line options
BACKUP=false
STASH=false
DRY_RUN=false
REVERT=false
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")  # Create a timestamp for unique backup folders

# Check if Git LFS is installed
check_git_lfs

# Process the options passed to the script
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --backup) BACKUP=true ;;
        --stash) STASH=true ;;
        --dry-run) DRY_RUN=true ;;
        --revert) REVERT=true ;;
        *) echo "Unknown option: $1" ;;
    esac
    shift
done

# Handle backups
if [[ "$BACKUP" == "true" ]]; then
    if [[ -d ".backup" ]]; then
        mkdir -p ".backup_precommit"
        mv .backup ".backup_precommit/$TIMESTAMP"
        echo "Previous backup archived to .backup_precommit/$TIMESTAMP/"
    fi
    mkdir -p .backup
    echo "Backup enabled. Files will be backed up in .backup/"
    # Copy all files to .backup directory
    # find . -type f -not -path "./.git/*" -not -path "./.backup/*" -exec cp -R {} .backup/ \;
    rsync -av --exclude='.git' --exclude='.backup' ./ .backup/
fi

# Stash logic
if [[ "$STASH" == "true" ]]; then
    git add .
    git stash push -m "Pre-commit backup"
    STASH_RESULT=$(git stash list | grep "Pre-commit backup")
    if [[ -n "$STASH_RESULT" ]]; then
        echo "SUCCESS: Stashed current changes."
    else
        echo "ERROR: Stash was not created."
    fi
fi

# Revert logic
if [[ "$REVERT" == "true" ]]; then
    echo "Reverting files from the latest backup in .backup/..."
    if [[ -d ".backup" ]]; then
        # Remove all files in the current directory except .backup, .git, and the script itself
        find . -mindepth 1 -maxdepth 1 -not -name '.backup' -not -name '.git' -not -name 'git_precommit_file_management.sh' -exec rm -rf {} +

        # Recreate directory structure before copying files from .backup/ to the current directory
        # find .backup -type d -exec sh -c 'mkdir -p "${0#.backup/}"' {} \;
        find .backup -type d -exec sh -c 'mkdir -p "${1#.backup/}"' _ {} \;

        # Copy files from .backup/ to the current directory, preserving directory structure
        rsync -av --exclude='.git' --exclude='.backup' .backup/ . || { echo "ERROR: Failed to copy files from backup."; exit 1; }

        # Decompress any .tar.gz files and remove the compressed versions
        find . -name "*.tar.gz" -type f -not -path "./.git/*" -not -path "./.backup/*" -print0 | xargs -0 -I {} sh -c '
            tar -xzvf "$1" -C "$(dirname "$1")" && rm "$1" || { echo "ERROR: Failed to decompress $1"; exit 1; }
        ' sh {}

        # Re-add large files to Git LFS
        find . -type f -size +50M -not -path "./.git/*" -not -path "./.backup/*" -exec git lfs track {} \;

        # Stage the changes
        git add . || { echo "ERROR: Failed to stage changes."; exit 1; }

        # Verify that all files have been restored
        # if diff -r --exclude='.git' --exclude='.backup' . .backup > /dev/null 2>&1; then
        if diff -r --exclude='.git' --exclude='.backup' --exclude='.gitattributes' . .backup > /dev/null 2>&1; then
            echo "Revert completed successfully."
            # Clean up
            rm -rf .backup
            echo "Backup directory removed."
        else
            echo "WARNING: Some files may not have been fully restored. Please review the changes manually."
            echo "Differences between current directory and backup:"
            diff -r --exclude='.git' --exclude='.backup' . .backup
            echo "The .backup directory has been kept for reference."
            exit 1
        fi
    else
        echo "ERROR: No backups found to revert."
        exit 1
    fi
    
    # Verify directory structure
    for dir in $(find . -type d -not -path "./.git*" -not -path "./.backup*"); do
        if [[ ! -d ".backup/$dir" ]]; then
            echo "ERROR: Directory $dir was not in the backup."
            exit 1
        fi
    done
    
    echo "Directory structure verified successfully."
    exit 0
fi

# Function to handle file compression and LFS tracking
process_file() {
    local file="$1"

    if [[ "$file" == *.tar.gz ]]; then
        echo "$file is already compressed. Skipping..."
        return
    fi

    if [[ "$BACKUP" == "true" ]]; then
        local backup_dir=".backup/$(dirname "$file")"
        mkdir -p "$backup_dir"
        cp -R "$file" "$backup_dir/"
        echo "Backed up $file to $backup_dir/"
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "Would compress $file"
    else
        echo "Compressing $file..."
        tar -czvf "$file.tar.gz" -C "$(dirname "$file")" "$(basename "$file")"
        # rm -rf "$file"
        rm -f "$file"

    fi

    if [[ -f "$file.tar.gz" ]]; then
        # file_size=$(stat -f%z "$file.tar.gz")
        file_size=$(wc -c < "$file.tar.gz")


        if [[ "$file_size" -gt $((50 * 1024 * 1024)) ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                echo "Would add $file.tar.gz to Git LFS"
            else
                echo "$file.tar.gz is over 50MB, adding to Git LFS tracking..."
                git lfs track "$file.tar.gz"
            fi
        fi
    fi
}

# Export the function so it's available to subshells
export -f process_file

# Find and process files larger than 50 MB
find . -type f -size +50M -not -path "./.git/*" -not -path "./.backup/*" -exec bash -c 'process_file "$0"' {} \;

if [[ "$DRY_RUN" == "false" ]]; then
    git add .
    echo "Staged all changes for commit."
else
    echo "Dry run complete. No changes made."
fi

if [[ "$STASH" == "true" ]]; then
    echo "You can restore your stashed changes with 'git stash pop'."
fi

echo "File size management complete. Ready for review or commit."


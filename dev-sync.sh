#!/bin/bash

# Function to show usage
usage() {
    echo "Usage: $0 [--sync] [--delete] <source_directory> <destination_directory>"
    echo "  --sync  	Perform actual synchronization (default is dry run)"
    echo "  --delete 	Delete files in the destination that are not in the source"
    exit 1
}

# Check if the correct number of arguments is provided
if [[ "$#" -lt 2 || "$#" -gt 4 ]]; then
    usage
fi

# Check if rsync is installed (should be by default on macOS)
if ! command -v rsync &> /dev/null; then
    echo "ERROR: rsync is not installed. Please install it and try again."
    exit 1
fi

# Initialize variables
DRY_RUN=true
DELETE_IN_DEST=false
SOURCE_DIR=""
DEST_DIR=""

# Parse command line options
while [[ "$1" == --* ]]; do
    case "$1" in
        --sync) DRY_RUN=false ;;
        --delete) DELETE_IN_DEST=true ;;
        *) usage ;;
    esac
    shift
done

# Assign source and destination directories
SOURCE_DIR="$1"
DEST_DIR="$2"

# Ensure both source and destination directories are provided and exist
if [[ -z "$SOURCE_DIR" || -z "$DEST_DIR" ]]; then
    echo "ERROR: Both source and destination directories must be provided."
    usage
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "ERROR: Source directory '$SOURCE_DIR' does not exist."
    exit 1
fi

if [[ ! -d "$DEST_DIR" ]]; then
    echo "ERROR: Destination directory '$DEST_DIR' does not exist."
    exit 1
fi

# Set rsync options
RSYNC_OPTIONS="-av --checksum"

# Add the delete flag if specified
if [[ "$DELETE_IN_DEST" == true ]]; then
    RSYNC_OPTIONS="$RSYNC_OPTIONS --delete"
    echo "Files not present in source will be deleted from destination."
fi

# Add the dry-run flag by default unless --sync is provided
if [[ "$DRY_RUN" == true ]]; then
    RSYNC_OPTIONS="$RSYNC_OPTIONS --dry-run"
    echo "Performing a dry run by default. No changes will be made."
else
    echo "Sync mode enabled. Performing actual synchronization."
fi

# Perform the sync using rsync
echo "Synchronizing $SOURCE_DIR to $DEST_DIR..."
rsync $RSYNC_OPTIONS "$SOURCE_DIR/" "$DEST_DIR/"

# Display message on completion
if [[ "$DRY_RUN" == true ]]; then
    echo "Dry run complete. No changes were made."
else
    echo "Synchronization complete."
fi


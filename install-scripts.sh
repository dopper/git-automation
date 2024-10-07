#!/bin/bash

# List of script filenames to copy to /usr/local/bin
SCRIPTS=("auto-lfs.sh" "git-status.sh" "hts.sh" "repos.sh")  # Modify this list as needed

# Loop through each script in the list
for script in "${SCRIPTS[@]}"; do
    # Check if the script exists in the current directory
    if [ -f "$script" ]; then
        echo "Copying $script to /usr/local/bin with sudo..."
        
        # Use sudo to copy the script to /usr/local/bin
        sudo cp "$script" /usr/local/bin/

        # Make the script executable in /usr/local/bin
        sudo chmod +x /usr/local/bin/"$script"
        
        echo "$script has been copied and made executable."
    else
        echo "Error: $script does not exist in the current directory."
    fi
done

echo "All specified scripts have been processed."


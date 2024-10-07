#!/bin/bash

# Function to change the remote origin URL from HTTPS to SSH
change_remote_to_ssh() {
  # Get the current remote URL
  remote_url=$(git remote get-url origin)

  # Check if the current remote URL is using HTTPS
  if [[ $remote_url == https://github.com/* ]]; then
    echo "Current remote URL: $remote_url"
    
    # Extract the username and repository name from the HTTPS URL
    ssh_url=$(echo $remote_url | sed -e 's/https:\/\/github.com\//git@github.com:/g')

    echo "Changing remote URL to SSH: $ssh_url"

    # Change the remote origin to SSH
    git remote set-url origin $ssh_url

    echo "Remote URL changed to SSH."
  else
    echo "The remote URL is already using SSH or not a GitHub repository."
  fi
}

# Check if the current directory is a Git repository
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  change_remote_to_ssh
else
  echo "This is not a Git repository."
fi


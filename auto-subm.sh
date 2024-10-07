#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 <parent_repo_directory> <child_repos_glob>"
  echo "Example: $0 /path/to/parent-repo '/path/to/child-repos/*'"
  exit 1
}

# Check if the correct number of arguments are provided
if [ $# -ne 2 ]; then
  usage
fi

# Assigning input arguments to variables
PARENT_REPO_DIR=$1
CHILD_REPOS_GLOB=$2

# Function to add child repo as a submodule
add_as_submodule() {
  local child_repo_path=$1
  local repo_name=$(basename "$child_repo_path")
  local repo_remote=$(git -C "$child_repo_path" remote get-url origin)

  if [ -z "$repo_remote" ]; then
    echo "No remote found for $repo_name. Skipping..."
    return
  fi

  echo "Moving $repo_name to parent repository and adding as submodule..."

  # Move the child repo to the parent repo
  mv "$child_repo_path" "$PARENT_REPO_DIR/$repo_name"

  # Change to the parent repository directory
  cd "$PARENT_REPO_DIR"

  # Add the child repo as a submodule
  git submodule add "$repo_remote" "$repo_name"

  # Commit the changes in the parent repository
  git add .gitmodules "$repo_name"
  git commit -m "Added $repo_name as submodule"
}

# Check if the parent repo exists and is a valid Git repository
if [ ! -d "$PARENT_REPO_DIR/.git" ]; then
  echo "The parent directory is not a Git repository. Exiting..."
  exit 1
fi

# Loop through each child repo matching the glob pattern
for child_repo in $CHILD_REPOS_GLOB; do
  if [ -d "$child_repo/.git" ]; then
    add_as_submodule "$child_repo"
  else
    echo "$child_repo is not a valid Git repository. Skipping..."
  fi
done

echo "All matching child repositories have been added as submodules."


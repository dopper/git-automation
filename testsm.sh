#!/bin/bash

# Step 1: Setup - Create parent repository
echo "Setting up the parent repository..."
PARENT_REPO_DIR="./parent-repo"
mkdir $PARENT_REPO_DIR
cd $PARENT_REPO_DIR
git init
cd ..

# Step 2: Setup - Create 3 child repositories
echo "Creating 3 child repositories..."
for i in {1..3}; do
  CHILD_REPO_DIR="./child-repo$i"
  mkdir $CHILD_REPO_DIR
  cd $CHILD_REPO_DIR
  git init
  echo "This is child repository $i" > file$i.txt
  git add file$i.txt
  git commit -m "Initial commit for child-repo$i"
  
  # Simulating remote (using the local repo as its own remote)
  git remote add origin git@github.com:username/child-repo$i.git
  
  cd ..
done

# Step 3: Test Script - Run the script to move and add submodules
echo "Running the script to move and add submodules..."
./move_and_add_submodules_glob.sh $PARENT_REPO_DIR './child-repo*'

# Step 4: Verify the results
echo "Verifying the results..."

# Verify the .gitmodules file exists
if [ -f "$PARENT_REPO_DIR/.gitmodules" ]; then
  echo ".gitmodules file exists."
else
  echo "Error: .gitmodules file is missing."
  exit 1
fi

# Verify that each child repo is added as a submodule
for i in {1..3}; do
  SUBMODULE_PATH="$PARENT_REPO_DIR/child-repo$i"
  if [ -d "$SUBMODULE_PATH" ]; then
    echo "Submodule child-repo$i was successfully added."
  else
    echo "Error: Submodule child-repo$i is missing."
    exit 1
  fi
done

echo "Test completed successfully!"


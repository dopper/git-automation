#!/bin/bash

# Step 1: Setup the test environment with a timestamped directory
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TEST_DIR="./git_precommit_test_$TIMESTAMP"
echo "Setting up the test environment in $TEST_DIR..."

# Create a temporary test directory
mkdir -p $TEST_DIR
cd $TEST_DIR || exit 1

# Initialize a new git repository
git init || { echo "ERROR: Git repository initialization failed."; exit 1; }

# Copy the git_precommit_file_management.sh script into the test directory
cp ../git_precommit_file_management.sh ./
chmod +x git_precommit_file_management.sh  # Ensure the script is executable

# Install Git LFS if not installed
if ! git lfs env > /dev/null 2>&1; then
    echo "Git LFS is not installed. Installing..."
    brew install git-lfs
    git lfs install
fi

# Create subdirectories to test with
mkdir -p large_files
mkdir -p small_files
mkdir -p nested_files

# Step 2: Setup test files

# 1. Create a file larger than 50 MB before compression and remains larger after compression (in parent dir)
dd if=/dev/urandom of=large_file_1.txt bs=1M count=60  # 60 MB random data in parent directory

# 2. Create a file that is larger than 50 MB before compression but compresses to less than 50 MB (in parent dir)
dd if=/dev/zero of=compressible_file.txt bs=1M count=60  # Compressible (zeros), but 60 MB before compression in parent directory

# 3. Create a file smaller than 50 MB, so it should not be compressed or tracked (in parent dir)
dd if=/dev/urandom of=small_file_1.txt bs=1M count=10  # 10 MB random data in parent directory

# 4. Create large and small files in the large_files directory
dd if=/dev/urandom of=large_files/large_file_2.txt bs=1M count=60  # 60 MB random data in large_files directory
dd if=/dev/urandom of=small_files/small_file_2.txt bs=1M count=10  # 10 MB random data in small_files directory

# 5. Nested files: Create a large file in a nested directory that remains large after compression
dd if=/dev/urandom of=nested_files/nested_large_file_1.txt bs=1M count=55  # 55 MB random data in a nested directory

# 6. Create a small file in a nested directory to test behavior with small files
dd if=/dev/urandom of=nested_files/nested_small_file_1.txt bs=1M count=5  # 5 MB random data in a nested directory

# Step 3: Test backup functionality
echo "Running the pre-commit script with backup..."
./git_precommit_file_management.sh --backup

# Verify the backup was created
if [[ -d ".backup" ]]; then
    echo "SUCCESS: Backup created in .backup/"
else
    echo "ERROR: Backup was not created."
fi

# Step 4: Verify original paths (Compression, Git LFS, and small file handling)

# Verify that large files in the parent directory were compressed and added to LFS
if [[ -f "large_file_1.txt.tar.gz" ]]; then
    echo "SUCCESS: large_file_1.txt was compressed."
else
    echo "ERROR: large_file_1.txt was not compressed."
fi

git lfs ls-files | grep "large_file_1.txt.tar.gz" > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "SUCCESS: large_file_1.txt.tar.gz was added to LFS."
else
    echo "ERROR: large_file_1.txt.tar.gz was not added to LFS."
fi

# Verify that compressible files in the parent directory were compressed but not added to LFS
if [[ -f "compressible_file.txt.tar.gz" ]]; then
    echo "SUCCESS: compressible_file.txt was compressed."
else
    echo "ERROR: compressible_file.txt was not compressed."
fi

git lfs ls-files | grep "compressible_file.txt.tar.gz" > /dev/null 2>&1
if [[ $? -eq 1 ]]; then
    echo "SUCCESS: compressible_file.txt.tar.gz was not added to LFS."
else
    echo "ERROR: compressible_file.txt.tar.gz was incorrectly added to LFS."
fi

# Verify that small files in the parent directory were not compressed or added to LFS
if [[ ! -f "small_file_1.txt.tar.gz" ]]; then
    echo "SUCCESS: small_file_1.txt was not compressed."
else
    echo "ERROR: small_file_1.txt was incorrectly compressed."
fi

git lfs ls-files | grep "small_file_1.txt" > /dev/null 2>&1
if [[ $? -eq 1 ]]; then
    echo "SUCCESS: small_file_1.txt was not added to LFS."
else
    echo "ERROR: small_file_1.txt was incorrectly added to LFS."
fi

# Verify that large files in the large_files directory were compressed and added to LFS
if [[ -f "large_files/large_file_2.txt.tar.gz" ]]; then
    echo "SUCCESS: large_file_2.txt was compressed."
else
    echo "ERROR: large_file_2.txt was not compressed."
fi

git lfs ls-files | grep "large_files/large_file_2.txt.tar.gz" > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "SUCCESS: large_file_2.txt.tar.gz was added to LFS."
else
    echo "ERROR: large_file_2.txt.tar.gz was not added to LFS."
fi

# Verify that small files in the small_files directory were not compressed or added to LFS
if [[ ! -f "small_files/small_file_2.txt.tar.gz" ]]; then
    echo "SUCCESS: small_file_2.txt was not compressed."
else
    echo "ERROR: small_file_2.txt was incorrectly compressed."
fi

git lfs ls-files | grep "small_files/small_file_2.txt" > /dev/null 2>&1
if [[ $? -eq 1 ]]; then
    echo "SUCCESS: small_file_2.txt was not added to LFS."
else
    echo "ERROR: small_file_2.txt was incorrectly added to LFS."
fi

# Verify that nested large files were compressed and added to LFS
if [[ -f "nested_files/nested_large_file_1.txt.tar.gz" ]]; then
    echo "SUCCESS: nested_large_file_1.txt was compressed."
else
    echo "ERROR: nested_large_file_1.txt was not compressed."
fi

git lfs ls-files | grep "nested_files/nested_large_file_1.txt.tar.gz" > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "SUCCESS: nested_large_file_1.txt.tar.gz was added to LFS."
else
    echo "ERROR: nested_large_file_1.txt.tar.gz was not added to LFS."
fi

# Verify that nested small files were not compressed or added to LFS
if [[ ! -f "nested_files/nested_small_file_1.txt.tar.gz" ]]; then
    echo "SUCCESS: nested_small_file_1.txt was not compressed."
else
    echo "ERROR: nested_small_file_1.txt was incorrectly compressed."
fi

git lfs ls-files | grep "nested_files/nested_small_file_1.txt" > /dev/null 2>&1
if [[ $? -eq 1 ]]; then
    echo "SUCCESS: nested_small_file_1.txt was not added to LFS."
else
    echo "ERROR: nested_small_file_1.txt was incorrectly added to LFS."
fi

# Step 5: Test dry-run functionality
echo "Running the pre-commit script in dry-run mode..."
./git_precommit_file_management.sh --dry-run

# Step 6: Test stash functionality
echo "Modifying files for stash testing..."
echo "Test modification" >> large_file_1.txt
echo "Test modification" >> small_file_1.txt

echo "Running the pre-commit script with stash..."
git commit --allow-empty -m "Initial commit"
./git_precommit_file_management.sh --stash

# Verify stash was created
STASH_RESULT=$(git stash list | grep "Pre-commit backup")
if [[ -n "$STASH_RESULT" ]]; then
    echo "SUCCESS: Stash created."
else
    echo "ERROR: Stash was not created."
fi

# Step 7: Test revert functionality
echo "Running the pre-commit script to revert changes..."
./git_precommit_file_management.sh --revert

# Verify the revert
verify_file() {
    if [[ -f "$1" ]]; then
        local size=$(wc -c < "$1")
        echo "SUCCESS: Reverted $1 from backup. Size: $size bytes"
        echo "MD5 hash of $1:"
        md5 "$1"
    else
        echo "ERROR: $1 was not reverted properly."
        echo "Current state of $(dirname "$1"):"
        ls -l "$(dirname "$1")" 2>/dev/null || echo "Directory does not exist"
    fi
}

verify_directory() {
    if [[ -d "$1" ]]; then
        echo "SUCCESS: Directory $1 was properly restored."
        echo "Contents of $1:"
        ls -l "$1"
    else
        echo "ERROR: Directory $1 was not restored."
    fi
}

verify_file "large_file_1.txt"
verify_file "nested_files/nested_large_file_1.txt"
verify_file "large_files/large_file_2.txt"
verify_file "compressible_file.txt"
verify_file "small_file_1.txt"
verify_file "small_files/small_file_2.txt"
verify_file "nested_files/nested_small_file_1.txt"

verify_directory "nested_files"
verify_directory "large_files"
verify_directory "small_files"

# Test LFS tracking after revert
LFS_TRACKING=$(git lfs ls-files)
if [[ -n "$LFS_TRACKING" ]]; then
    echo "SUCCESS: LFS tracking was maintained for large files."
    echo "LFS tracked files:"
    echo "$LFS_TRACKING"
else
    echo "ERROR: LFS tracking was not maintained for large files."
fi

# Check if backup directory still exists
if [[ -d ".backup" ]]; then
    echo "WARNING: Backup directory still exists. This may indicate a problem with the revert process."
    echo "Contents of .backup directory:"
    ls -R .backup
    echo "Differences between current directory and backup:"
    diff -r . .backup || echo "No differences found"
else
    echo "SUCCESS: Backup directory was removed after successful revert."
fi

# Verify directory structure
for dir in "nested_files" "large_files" "small_files"; do
    if [[ -d "$dir" ]]; then
        echo "SUCCESS: Directory $dir was properly restored."
        echo "Contents of $dir:"
        ls -l "$dir"
    else
        echo "ERROR: Directory $dir was not restored."
    fi
done

# Verify file contents
for file in "large_file_1.txt" "nested_files/nested_large_file_1.txt" "large_files/large_file_2.txt" "compressible_file.txt" "small_file_1.txt" "small_files/small_file_2.txt" "nested_files/nested_small_file_1.txt"; do
    if [[ -f "$file" ]]; then
        echo "Contents of $file (first 100 bytes):"
        head -c 100 "$file" | xxd
        echo "File size of $file:"
        wc -c < "$file"
    else
        echo "ERROR: $file does not exist"
    fi
done

# Verify Git LFS attributes
echo "Git LFS attributes:"
cat .gitattributes

# Verify Git status
echo "Git status:"
git status

# Step 8: Clean up
echo "Cleaning up..."
rm -rf $TEST_DIR

echo "Test completed."


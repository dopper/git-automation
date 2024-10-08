#!/bin/bash

# Function to clean up directories before each test
cleanup_directories() {
    rm -rf testcase*_source testcase*_destination
}

# Function to run a dry run and sync operation for each test case
run_test_case() {
    local test_case_number="$1"
    local description="$2"

    echo "==========================================="
    echo "Running Test Case $test_case_number: $description"
    echo "==========================================="

    echo "Dry Run:"
    ./dev-sync.sh "testcase${test_case_number}_source" "testcase${test_case_number}_destination"

    echo ""
    echo "Sync:"
    ./dev-sync.sh --sync "testcase${test_case_number}_source" "testcase${test_case_number}_destination"

    echo ""
    echo "Sync with Deletion (if applicable):"
    ./dev-sync.sh --sync --delete "testcase${test_case_number}_source" "testcase${test_case_number}_destination"
    echo "-------------------------------------------"
}

# Test Case 1: Identical Source and Destination
test_case_1() {
    cleanup_directories

    mkdir -p testcase1_source/subdir
    echo "file 1 content" > testcase1_source/file1.txt
    echo "file 2 content" > testcase1_source/subdir/file2.txt
    cp -r testcase1_source testcase1_destination

    run_test_case 1 "Identical Source and Destination"
}

# Test Case 2: Extra File in Destination
test_case_2() {
    cleanup_directories

    mkdir -p testcase2_source
    echo "file 1 content" > testcase2_source/file1.txt
    mkdir -p testcase2_destination
    cp testcase2_source/file1.txt testcase2_destination/
    echo "extra file content" > testcase2_destination/extra.txt

    run_test_case 2 "Extra File in Destination"
}

# Test Case 3: Missing File in Destination
test_case_3() {
    cleanup_directories

    mkdir -p testcase3_source/subdir
    echo "file 1 content" > testcase3_source/file1.txt
    echo "file 2 content" > testcase3_source/subdir/file2.txt
    mkdir -p testcase3_destination
    cp testcase3_source/file1.txt testcase3_destination/

    run_test_case 3 "Missing File in Destination"
}

# Test Case 4: Modified File in Source
test_case_4() {
    cleanup_directories

    mkdir -p testcase4_source/subdir
    echo "new content for file 1" > testcase4_source/file1.txt
    echo "file 2 content" > testcase4_source/subdir/file2.txt
    mkdir -p testcase4_destination/subdir
    echo "old content for file 1" > testcase4_destination/file1.txt
    cp testcase4_source/subdir/file2.txt testcase4_destination/subdir/

    run_test_case 4 "Modified File in Source"
}

# Test Case 5: Subdirectory Missing in Destination
test_case_5() {
    cleanup_directories

    mkdir -p testcase5_source/subdir
    echo "file 1 content" > testcase5_source/file1.txt
    echo "file 2 content" > testcase5_source/subdir/file2.txt
    mkdir -p testcase5_destination
    cp testcase5_source/file1.txt testcase5_destination/

    run_test_case 5 "Subdirectory Missing in Destination"
}

# Test Case 6: Multiple Changes (Added, Modified, Deleted Files)
test_case_6() {
    cleanup_directories

    mkdir -p testcase6_source/subdir
    echo "new content for file 1" > testcase6_source/file1.txt
    echo "file 2 content" > testcase6_source/file2.txt
    echo "file 3 content" > testcase6_source/subdir/file3.txt
    mkdir -p testcase6_destination/subdir
    echo "old content for file 1" > testcase6_destination/file1.txt
    echo "file 4 content" > testcase6_destination/file4.txt

    run_test_case 6 "Multiple Changes (Added, Modified, Deleted Files)"
}

# Main function to run all test cases
run_all_test_cases() {
    test_case_1
    test_case_2
    test_case_3
    test_case_4
    test_case_5
    test_case_6
    cleanup_directories
}

# Run all test cases
run_all_test_cases


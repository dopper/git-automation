#!/bin/bash

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq first."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "Error: npm is required but not installed. Please install npm first."
    exit 1
fi

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo "Error: package.json not found in current directory"
    exit 1
fi

# Create temporary directory for work
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Copy original package.json to temporary directory
cp package.json "$TEMP_DIR/original-package.json"

# Function to check if a version satisfies the constraint
check_version_compatibility() {
    local package=$1
    local constraint=$2
    local latest=$3
    
    # Create a temporary package.json to test compatibility
    echo "{\"dependencies\":{\"$package\":\"$constraint\"}}" > "$TEMP_DIR/test-package.json"
    
    # Try to install the latest version with the constraint
    if npm install --prefix "$TEMP_DIR" --package-lock-only "$package@$latest" &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
}

# Function to process dependencies
process_deps() {
    local dep_type=$1
    local deps=$(jq -r ".$dep_type // {} | to_entries[] | \"\(.key)|\(.value)\"" package.json)
    
    while IFS='|' read -r package version; do
        # Skip if no package (empty line)
        [ -z "$package" ] && continue
        
        # Get latest version from npm
        latest=$(npm view "$package" version 2>/dev/null)
        
        # Skip if failed to get latest version
        [ -z "$latest" ] && continue
        
        # Skip if already using latest version
        if [[ "$version" == "^$latest" || "$version" == "~$latest" || "$version" == "$latest" ]]; then
            continue
        fi
        
        # Check if latest version is compatible with current constraint
        if [ "$(check_version_compatibility "$package" "$version" "$latest")" == "true" ]; then
            # Preserve the version prefix (^ or ~)
            if [[ "$version" == ^* ]]; then
                new_version="^$latest"
            elif [[ "$version" == ~* ]]; then
                new_version="~$latest"
            else
                new_version="$latest"
            fi
            
            # Update the version in the copy of package.json
            jq --arg pkg "$package" \
               --arg ver "$new_version" \
               --arg type "$dep_type" \
               'setpath([$type, $pkg]; $ver)' "$TEMP_DIR/original-package.json" > "$TEMP_DIR/temp.json" \
                && mv "$TEMP_DIR/temp.json" "$TEMP_DIR/original-package.json"
        fi
    done <<< "$deps"
}

# Process both dependencies and devDependencies
process_deps "dependencies"
process_deps "devDependencies"

# Format and save the output file
jq '.' "$TEMP_DIR/original-package.json" > "package-updates.json"

# Get total number of dependencies
total_deps=$(jq -r '(.dependencies + .devDependencies | length)' package-updates.json)

echo "Done! Processed $total_deps packages."
echo "Results have been saved to package-updates.json"

# Display a comparison of the changes
echo -e "\nUpdated dependencies:"
echo "------------------------"
jq -r '
def compare_versions(orig; updated):
  to_entries[] as $entry |
  $entry.key as $pkg |
  if orig[$pkg] != updated[$pkg] and orig[$pkg] != null and updated[$pkg] != null then
    "• \($pkg): \(orig[$pkg]) → \(updated[$pkg])"
  else empty end;

[inputs] | 
.[0] as $original | 
.[1] as $updated |
"Dependencies:",
($original.dependencies | compare_versions($original.dependencies; $updated.dependencies)),
"\nDevDependencies:",
($original.devDependencies | compare_versions($original.devDependencies; $updated.devDependencies))
' package.json package-updates.json

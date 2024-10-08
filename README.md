# Git Repository Management Tools

This project contains a collection of Bash scripts designed to automate and simplify various Git repository management tasks. Below is an overview of each script and its primary function.

## Scripts Overview

### 1. auto-lfs.sh
- **Function**: Manages large files in Git repositories.
- **Features**:
  - Compresses large files (>50MB) automatically
  - Tracks large compressed files with Git LFS
  - Creates backups of files before modifications
  - Provides a dry-run mode for testing
  - Allows stashing of changes
  - Supports reverting to the previous state

### 2. repos.sh
- **Function**: Lists Git repositories and their remote URLs.
- **Features**:
  - Scans subdirectories for Git repositories
  - Displays the remote origin URL for each repository

### 3. git-status.sh
- **Function**: Checks the status of multiple Git repositories.
- **Features**:
  - Detects uncommitted changes in repositories
  - Optionally updates repositories (add, commit, push)
  - Checks if local repositories are up-to-date with remotes

### 4. install-scripts.sh
- **Function**: Installs the scripts to /usr/local/bin for system-wide access.
- **Features**:
  - Copies specified scripts to /usr/local/bin
  - Makes the scripts executable

### 5. dirc.sh
- **Function**: Counts files in directories.
- **Features**:
  - Loops through all directories in the current location
  - Counts and displays the number of files in each directory

### 6. dfct.sh
- **Function**: Analyzes directories for high file counts.
- **Features**:
  - Recursively analyzes directories
  - Identifies directories exceeding a file count threshold
  - Suggests archiving commands for large directories

### 7. auto-subm.sh
- **Function**: Automates the process of adding repositories as submodules.
- **Features**:
  - Moves child repositories into a parent repository
  - Adds child repositories as submodules
  - Updates .gitmodules file and commits changes

### 8. hts.sh
- **Function**: Converts Git remote URLs from HTTPS to SSH.
- **Features**:
  - Checks if the current remote URL uses HTTPS
  - Converts GitHub HTTPS URLs to SSH format
  - Updates the remote URL in the Git configuration

## Usage

Each script can be run independently. For detailed usage instructions, please refer to the comments within each script or run the script with the `--help` flag if available.

## Installation

To install these scripts system-wide, use the `install-scripts.sh`:

```bash
./install-scripts.sh
```

This will copy the scripts to /usr/local/bin, making them accessible from anywhere in the system.

## Contributing

Contributions to improve the scripts or extend their functionality are welcome. Please submit a pull request or open an issue to discuss proposed changes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

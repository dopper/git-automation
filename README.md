# Git Pre-Commit File Management Tool
This tool helps manage large files in Git repositories by automatically compressing them when necessary and tracking them with Git LFS (Large File Storage). It also includes backup and revert functionalities to ensure data safety.

<img src="assets/git-lfs-automation.png" alt="Project Logo" width="200"/>

## Features
- Compresses large files (>50MB) automatically
- Tracks large compressed files with Git LFS
- Creates backups of files before modifications
- Provides a dry-run mode for testing
- Allows stashing of changes
- Supports reverting to the previous state

## Prerequisites
- Git
- Git LFS
- Bash shell

## Installation
1. Clone this repository or copy the `git_precommit_file_management.sh` script to your project's root directory.
2. Make the script executable:
``` bash
chmod +x git_precommit_file_management.sh
```

## Usage
You can run the script manually in different modes:
- **Default mode** (process files without additional options):
```bash
./git_precommit_file_management.sh
```

- **Backup mode**:
```bash
./git_precommit_file_management.sh --backup
```

- **Stash mode**:
```bash
./git_precommit_file_management.sh --stash
```

- **Dry-run mode**:
```bash
./git_precommit_file_management.sh --dry-run
```

- **Revert mode**:
```bash
./git_precommit_file_management.sh --revert
```

When run without arguments, the script will compress large files and track them with Git LFS as needed.
## Testing
A test script `test_precommit_script.sh` is provided to verify the functionality. To run the tests:
1. Make the test script executable:
```bash
chmod +x test_precommit_script.sh
```

2. Run the test script:
```bash
./test_precommit_script.sh
```

The test script creates a temporary Git repository, adds various types of files, and runs the script with different options to ensure everything works as expected.
## Customization
You can modify the `git_precommit_file_management.sh` script to adjust the file size threshold for compression or change the behavior for specific file types or directories.

## Troubleshooting
- Check the script output for error messages.
- Ensure Git LFS is properly installed and initialized in your repository.
- Verify file sizes and locations if files are not being tracked or compressed as expected.

## Contributing
Contributions to improve the script or extend its functionality are welcome. Please submit a pull request or open an issue to discuss proposed changes.

## License
MIT License
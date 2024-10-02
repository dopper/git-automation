# Git Pre-commit File Management Tool

This tool provides a pre-commit hook for Git repositories to manage large files, compress them when necessary, and track them using Git LFS (Large File Storage). It also includes backup and revert functionalities to ensure data safety.

![Your Logo](assets/git-lfs-automation.png)

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

1. Clone this repository or copy the `git_precommit_file_management.sh` script to your project's root directory.
2. Make the script executable:
   ```
   chmod +x git_precommit_file_management.sh
   ```
3. Set up the pre-commit hook:
   ```
   ln -s ../../git_precommit_file_management.sh .git/hooks/pre-commit
   ```

## Usage

The script can be used in several ways:

### As a Pre-commit Hook

When set up as a pre-commit hook, the script will run automatically before each commit, managing large files as configured.

### Manual Execution

You can run the script manually in different modes:

- Default mode (process files without additional options):
  ```
  ./git_precommit_file_management.sh
  ```

- Backup mode:
  ```
  ./git_precommit_file_management.sh --backup
  ```

- Stash mode:
  ```
  ./git_precommit_file_management.sh --stash
  ```

- Dry-run mode:
  ```
  ./git_precommit_file_management.sh --dry-run
  ```

- Revert mode:
  ```
  ./git_precommit_file_management.sh --revert
  ```

When run without arguments, the script will process files according to its default behavior, compressing large files and tracking them with Git LFS as needed.

## Testing

A test script `test_precommit_script.sh` is provided to verify the functionality of the pre-commit hook. To run the tests:

1. Make the test script executable:
   ```
   chmod +x test_precommit_script.sh
   ```

2. Run the test script:
   ```
   ./test_precommit_script.sh
   ```

The test script will create a temporary Git repository, add various types of files, and run the pre-commit script with different options to ensure everything works as expected.

## Customization

You can modify the `git_precommit_file_management.sh` script to adjust the file size threshold for compression or change the behavior for specific file types or directories.

## Troubleshooting

- If you encounter any issues, check the script output for error messages.
- Ensure Git LFS is properly installed and initialized in your repository.
- If files are not being tracked or compressed as expected, verify their sizes and locations.

## Contributing

Contributions to improve the script or extend its functionality are welcome. Please submit a pull request or open an issue to discuss proposed changes.

## License

[MIT License](LICENSE)

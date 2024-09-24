#!/bin/bash

# Function to check executable permissions and list files/directories
check_executable() {
    local path="$1"
    local exclude="$2"

    # Find all files and directories, excluding the ones mentioned
    local files=$(find "$path" -not -path "$exclude" -type f -perm /u+x,g+x,o+x)
    local dirs=$(find "$path" -not -path "$exclude" -type d -perm /u+x,g+x,o+x)

    # If files or directories with executable permissions are found, list them
    if [[ -n "$files" || -n "$dirs" ]]; then
        echo "Executable files found:"
        echo "$files"
        echo "$dirs"
    else
        echo "No executable Files found!"
    fi
}

# Main script starts here
# Usage: ./check_executable.sh /path/to/directory "/exclude/path"

# The directory to scan
scan_dir="$1"
# The file/directory to exclude (can be optional)
exclude_path="${2:-}"

# Run the check
check_executable "$scan_dir" "$exclude_path"

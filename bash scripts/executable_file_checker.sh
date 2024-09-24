#!/bin/bash

# Define color codes
GREEN='\033[0;32m' # Green for files
BLUE='\033[0;34m'  # Blue for directories
NC='\033[0m'       # No Color (reset)

# Function to check executable permissions and list files/directories
check_executable() {
    local path="$1"
    local exclude="$2"

    # Find all files and directories, excluding the ones mentioned
    local files=$(find "$path" -not -path "$exclude" -type f)
    local dirs=$(find "$path" -not -path "$exclude" -type d)

    # Find files and directories with executable permissions
    local exec_files=$(find "$path" -not -path "$exclude" -type f -perm /u+x,g+x,o+x)
    local exec_dirs=$(find "$path" -not -path "$exclude" -type d -perm /u+x,g+x,o+x)

    # Total counts
    local total_file_count=$(echo "$files" | wc -l)
    local total_dir_count=$(echo "$dirs" | wc -l)
    local exec_file_count=$(echo "$exec_files" | wc -l)
    local exec_dir_count=$(echo "$exec_dirs" | wc -l)

    # If executable files or directories found, list them
    if [[ -n "$exec_files" || -n "$exec_dirs" ]]; then
        echo -e "Executable files and directories found:"
        # Print executable files in green
        for file in $exec_files; do
            echo -e "${GREEN}${file}${NC}"
        done
        # Print executable directories in blue
        for dir in $exec_dirs; do
            echo -e "${BLUE}${dir}${NC}"
        done
    else
        echo "No executable Files found!"
    fi

    # Display the counts
    echo ""
    echo "Total files scanned: $total_file_count"
    echo "Total directories scanned: $total_dir_count"
    echo "Total executable files: $exec_file_count"
    echo "Total executable directories: $exec_dir_count"
}

# Main script starts here
# Usage: ./check_executable.sh /path/to/directory "/exclude/path"

# The directory to scan
scan_dir="$1"
# The file/directory to exclude (can be optional)
exclude_path="${2:-}"

# Run the check
check_executable "$scan_dir" "$exclude_path"

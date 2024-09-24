#!/bin/bash

# Define color codes
RED='\033[0;31m'   # Red for executable files
GREEN='\033[0;32m' # Green for non-executable files
BLUE='\033[0;34m'  # Blue for executable directories
NC='\033[0m'       # No Color (reset)

# Function to get permission in octal format (e.g., [755])
get_permissions() {
    stat -c "%a" "$1"
}

# Function to check permissions and list files/directories
check_permissions() {
    local path="$1"
    local exclude="$2"
    local show_exec_only="$3"
    local count_only="$4"

    # Find all files and directories, excluding the ones mentioned
    local files
    local dirs

    if [[ -n "$exclude" ]]; then
        files=$(find "$path" -not -path "$exclude" -type f)
        dirs=$(find "$path" -not -path "$exclude" -type d)
    else
        files=$(find "$path" -type f)
        dirs=$(find "$path" -type d)
    fi

    local exec_files=0
    local exec_dirs=0
    local total_files=0
    local total_dirs=0

    # Loop through all directories
    for dir in $dirs; do
        total_dirs=$((total_dirs + 1))
        perm=$(get_permissions "$dir")
        if [[ -x "$dir" ]]; then
            exec_dirs=$((exec_dirs + 1))
            if [[ "$count_only" == false ]]; then
                echo -e "[$perm] ${BLUE}${dir}${NC}"
            fi
        fi
    done

    # Loop through all files
    for file in $files; do
        total_files=$((total_files + 1))
        perm=$(get_permissions "$file")
        if [[ -x "$file" ]]; then
            exec_files=$((exec_files + 1))
            if [[ "$count_only" == false ]]; then
                echo -e "[$perm] ${RED}${file}${NC}"
            fi
        fi
    done

    # Display the counts
    echo ""
    echo "Total files scanned: $total_files"
    echo "Total directories scanned: $total_dirs"
    echo "Total executable files: $exec_files"
    echo "Total executable directories: $exec_dirs"
}

# Main script starts here
# Usage: ./check_permissions.sh /path/to/directory "/exclude/path" [-e] [-co]

# The directory to scan
scan_dir="$1"
# The file/directory to exclude (can be optional)
exclude_path="${2:-}"
# Option to show only executable files (-e)
show_exec_only=false
# Option to show count only (-co)
count_only=false

# Check for additional arguments
shift 2  # Skip first two positional arguments (scan_dir and exclude_path)
for arg in "$@"; do
    if [[ "$arg" == "-e" ]]; then
        show_exec_only=true
    elif [[ "$arg" == "-co" ]]; then
        count_only=true
    fi
done

# If the -e flag is set, adjust the output logic accordingly
if [[ "$show_exec_only" == true ]]; then
    check_permissions "$scan_dir" "$exclude_path" "$show_exec_only" "$count_only"
else
    check_permissions "$scan_dir" "$exclude_path" false "$count_only"
fi

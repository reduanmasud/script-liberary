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

# Function for "Scanning..." animation with bouncing dots
show_scanning_animation() {
    while true; do
        echo -ne "Scanning.\r"
        sleep 0.5
        echo -ne "Scanning..\r"
        sleep 0.5
        echo -ne "Scanning...\r"
        sleep 0.5
        echo -ne "Scanning    \r"  # Clear the dots
        sleep 0.5
    done
}

# Function to stop the animation and clear the line
stop_scanning_animation() {
    kill "$1"  # Kill the background animation process
    echo -ne "\r\033[K"  # Clear the line after killing the animation
}

# Function to check permissions and list files/directories
check_permissions() {
    local path="$1"
    local exclude="$2"
    local show_exec_only="$3"
    local count_only="$4"

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

    # Start the "Scanning..." animation in the background
    if [[ "$count_only" == true ]]; then
        show_scanning_animation &
        anim_pid=$!
    fi

    # Loop through all directories
    while IFS= read -r dir; do
        total_dirs=$((total_dirs + 1))
        perm=$(get_permissions "$dir")
        if [[ -x "$dir" ]]; then
            exec_dirs=$((exec_dirs + 1))
            if [[ "$count_only" == false && "$show_exec_only" == false ]]; then
                echo -e "[$perm] ${BLUE}${dir}${NC}"
            elif [[ "$count_only" == false && "$show_exec_only" == true ]]; then
                echo -e "[$perm] ${BLUE}${dir}${NC}"
            fi
        else
            if [[ "$count_only" == false && "$show_exec_only" == false ]]; then
                echo -e "[$perm] ${RED}${dir}${NC}"
            fi
        fi
    done <<< "$dirs"

    # Loop through all files
    while IFS= read -r file; do
        total_files=$((total_files + 1))
        perm=$(get_permissions "$file")
        if [[ -x "$file" ]]; then
            exec_files=$((exec_files + 1))
            if [[ "$count_only" == false && "$show_exec_only" == false ]]; then
                echo -e "[$perm] ${RED}${file}${NC}"
            elif [[ "$count_only" == false && "$show_exec_only" == true ]]; then
                echo -e "[$perm] ${RED}${file}${NC}"
            fi
        else
            if [[ "$count_only" == false && "$show_exec_only" == false ]]; then
                echo -e "[$perm] ${GREEN}${file}${NC}"
            fi
        fi
    done <<< "$files"

    # Stop the "Scanning..." animation and clear the line
    if [[ "$count_only" == true ]]; then
        stop_scanning_animation "$anim_pid"
    fi

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

# Run the check
check_permissions "$scan_dir" "$exclude_path" "$show_exec_only" "$count_only"

#!/bin/bash

# Define the log file paths for Nginx and OpenLiteSpeed (OLS)
NGINX_LOG_FILE="/var/log/nginx/error.log"
OLS_LOG_FILE="/usr/local/lsws/logs/error.log"
CUSTOM_LOG_FILE="/var/log/custom.log"

# Function to generate a large log
generate_logs() {
    LOG_FILE=$1
    MESSAGE=$2
    SIZE_MB=$3
    SIZE_BYTES=$((SIZE_MB * 1024 * 1024))  # Convert MB to Bytes
    echo "Generating logs in $LOG_FILE..."

    while [[ $(stat -c%s "$LOG_FILE") -lt $SIZE_BYTES ]]; do
        echo "$MESSAGE" >> "$LOG_FILE"
    done

    echo "$LOG_FILE reached the target size of $SIZE_MB MB"
}


# Generate 20MB of OpenLiteSpeed error logs
if [ -f "$OLS_LOG_FILE" ]; then
    generate_logs $OLS_LOG_FILE "$(date) - OpenLiteSpeed: [error] Test OLS error log message" 20
else
    echo "OpenLiteSpeed error log file not found: $OLS_LOG_FILE"
fi

echo "Log generation completed."


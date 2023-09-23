##!/bin/bash

# Root directory where your TV shows and Movies folders are located
root_directory="/mnt/user0/rclone_upload/gdrive_vfs/"

# Maximum space for the root directory in megabytes
max_space_mb=30000000  # Adjust this value as needed #default is 30TB

# Dry run flag (set to true to simulate, set to false to actually delete files)
dry_run=true

################################################################
# DO NOT EDIT BELOW THIS LINE
###############################################################

# Function to calculate the total size of a directory in megabytes
calculate_directory_size_mb() {
    du -sm "$1" | awk '{print $1}'
}

# Calculate the total size of the root directory in megabytes
total_size_mb=$(calculate_directory_size_mb "$root_directory")
echo "Total size of root directory: ${total_size_mb}MB"

# Calculate the free space in the root directory in megabytes using du
free_space_mb=$(calculate_directory_size_mb "$root_directory")
echo "Free space in root directory: ${free_space_mb}MB"

# Check if the current size of the root directory exceeds the maximum allowed size
if [ "$total_size_mb" -gt "$max_space_mb" ]; then
    space_to_free_mb=$((total_size_mb - max_space_mb))

    echo "Current size: ${total_size_mb}MB"
    echo "Maximum allowed size: ${max_space_mb}MB"

    # Check if space to free is greater than 0 (meaning we need to delete files)
    if [ "$space_to_free_mb" -gt 0 ]; then
        echo "Starting file deletion..."
        if [ "$dry_run" = true ]; then
            # Dry run: Print the files that would be deleted
            find "$root_directory" -type f -exec echo "Would delete: {}" \;
        else
            # Actual run: Delete the oldest files until enough space is freed
            while [ "$space_to_free_mb" -gt 0 ]; do
                # Find and delete the oldest file
                oldest_file=$(find "$root_directory" -type f -print0 | xargs -0 ls -lt | awk -v SPACE_TO_FREE="$space_to_free_mb" '
                    {
                        space_to_free_mb -= $5 / (1024*1024);  # Convert file size to MB
                        if (space_to_free_mb >= 0) {
                            print $9;
                        }
                    }
                ' | head -n 1)
                if [ -z "$oldest_file" ]; then
                    break  # No more files to delete
                fi
                rm -f "$oldest_file"
                space_to_free_mb=$((space_to_free_mb - $(ls -l "$oldest_file" | awk '{print $5 / (1024*1024)}')))
                echo "Deleted: $oldest_file"
            done
        fi
        echo "Finished cleaning. Free space in root directory: ${free_space_mb}MB"
    else
        echo "No files to delete in the root directory. Free space in root directory: ${free_space_mb}MB"
    fi
else
    echo "No action needed for the root directory. Free space in root directory: ${free_space_mb}MB"
fi

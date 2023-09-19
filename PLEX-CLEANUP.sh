#!/bin/bash

# Default directory paths (you can change these defaults if needed)
tv_shows_directory="TV SHOW DIRECTORY" #Add tv show directory file path eg (/mnt/user/rclone_upload/gdrive_vfs/TV Shows)
movies_directory="MOVIE DIRECTORY" #Add tv show directory file path eg (/mnt/user/rclone_upload/gdrive_vfs/Movies)
#fourk_tv_shows_directory="4K TV SHOWS DIRECTORY" #Uncomment to add directory as above
#fourk_movies_directory="4K MOVIES DIRECTORY" #Uncomment to add directory as above

# Default minimum free space (2 TiB)
min_free_space=2048  # 2 TiB (1 TiB = 1024 GiB, 1 GiB = 1024 MiB)

# Default time periods in days for each directory
tv_shows_time_period=30
movies_time_period=60
#fourk_tv_shows_time_period=90 #Uncomment to add directory
#fourk_movies_time_period=120 #Uncomment to add directory

# Set this to true for a dry run (no files will be deleted)
dry_run=true

# Function to delete old files, prioritizing the oldest ones
delete_old_files() {
    local directory="$1"
    local required_min_free_space_gib="$2"

    if [ "$dry_run" = true ]; then
        echo "Dry run: Would have deleted files in $directory to free up space."
    else
        # Find and delete the oldest files until the required minimum free space is met
        while [ $(df -BG "$(dirname "$directory")" | awk 'NR==2 {print $4}' | tr -d 'G') -lt "$required_min_free_space_gib" ]; do
            # Find the oldest file in the directory
            oldest_file=$(find "$directory" -type f -printf '%T+ %p\n' | sort | head -n 1 | awk '{print $NF}')
            
            # Check if there are no more files to delete
            if [ -z "$oldest_file" ]; then
                echo "No more files to delete in $directory. Free space is still below the required limit."
                break
            fi

            # Delete the oldest file
            file_size_gib=$(du -sk --apparent-size "$oldest_file" | awk '{print $1 / 1024 / 1024}')
            required_min_free_space_gib=$((required_min_free_space_gib - file_size_gib))
            rm "$oldest_file"
            echo "Deleted file: $oldest_file"
        done
        
        echo "Deleted old files in $directory to free up space."
    fi
}

# Function to get the directory size in gibibytes as a floating-point number
get_directory_size() {
    local directory="$1"
    du -sk --apparent-size "$directory" | awk '{print $1 / 1024 / 1024}'
}

main() {
    # Use provided or default paths and options
    local tv_shows_directory="${1:-$tv_shows_directory}"
    local movies_directory="${2:-$movies_directory}"
    local fourk_tv_shows_directory="${3:-$fourk_tv_shows_directory}"
    local fourk_movies_directory="${4:-$fourk_movies_directory}"

    current_tv_shows_size=$(get_directory_size "$tv_shows_directory")
    current_movies_size=$(get_directory_size "$movies_directory")
    current_fourk_tv_shows_size=$(get_directory_size "$fourk_tv_shows_directory")
    current_fourk_movies_size=$(get_directory_size "$fourk_movies_directory")

    current_free_space=$(df -BG "$(dirname "$tv_shows_directory")" | awk 'NR==2 {print $4}' | tr -d 'G')

    # Convert the minimum free space requirement to GiB
    required_min_free_space_gib=$((min_free_space * 1024))

    if [ "$current_free_space" -lt "$required_min_free_space_gib" ]; then
        echo "Free space in $(dirname "$tv_shows_directory") is below the required limit. Checking time period..."
        
        # Display the calculated free space
        echo "Calculated free space: $current_free_space GiB"

        echo "Deleting old files..."
        delete_old_files "$tv_shows_directory" "$required_min_free_space_gib"
        delete_old_files "$movies_directory" "$required_min_free_space_gib"
        delete_old_files "$fourk_tv_shows_directory" "$required_min_free_space_gib"
        delete_old_files "$fourk_movies_directory" "$required_min_free_space_gib"
    else
        echo "Free space in $(dirname "$tv_shows_directory") is sufficient. No action needed."
        # Display the calculated free space
        echo "Calculated free space: $current_free_space GiB"
    fi

    echo "Cleanup process completed."
}

# Pass directory paths as arguments or use defaults
main "$@"

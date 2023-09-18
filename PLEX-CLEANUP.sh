#!/bin/bash

# Default directory paths (you can change these defaults if needed)
tv_shows_directory="TV SHOW DIRECTORY" #Add tv show directory file path eg (/mnt/user/rclone_upload/gdrive_vfs/TV Shows)
movies_directory="MOVIE DIRECTORY" #Add tv show directory file path eg (/mnt/user/rclone_upload/gdrive_vfs/Movies)
#fourk_tv_shows_directory="4K TV SHOWS DIRECTORY" #Uncomment to add directory as above
#fourk_movies_directory="4K MOVIES DIRECTORY" #Uncomment to add directory as above

# Default minimum free space eg.(2 TiB) #calculation is done in Tebibytes for slackware systems such as Unraid 1 TiB = 1.099511627776 TB
min_free_space=2048  # 2 TiB (1 TiB = 1024 GiB, 1 GiB = 1024 MiB)

# Default time period in days
time_period_days=30

# Set this to true for a dry run (no files will be deleted)
dry_run=true

#DO NOT EDIT BELOW THIS SPACE UNLESS YOU KNOW WHAT YOU ARE DOING
----------------------------------------------------------------------------------------------------------------------------------------
# Function to delete old files
delete_old_files() {
    local directory="$1"
    local max_age_days="$2"

    if [ "$dry_run" = true ]; then
        echo "Dry run: Would have deleted files in $directory older than $max_age_days days."
    else
        find "$directory" -type f -ctime "+$max_age_days" -exec rm {} \;
        echo "Deleted files in $directory older than $max_age_days days."
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

        # Perform floating-point comparisons for directory sizes
        if (( $(echo "$current_tv_shows_size >= $required_min_free_space_gib" | bc -l) )) || (( $(echo "$current_movies_size >= $required_min_free_space_gib" | bc -l) )) || (( $(echo "$current_fourk_tv_shows_size >= $required_min_free_space_gib" | bc -l) )) || (( $(echo "$current_fourk_movies_size >= $required_min_free_space_gib" | bc -l) )); then
            echo "Deleting old files older than $time_period_days days..."
            delete_old_files "$tv_shows_directory" "$time_period_days"
            delete_old_files "$movies_directory" "$time_period_days"
            delete_old_files "$fourk_tv_shows_directory" "$time_period_days"
            delete_old_files "$fourk_movies_directory" "$time_period_days"
        else
            echo "Free space is below the required limit, but not all directories have reached the time period. No files will be deleted."
        fi
    else
        echo "Free space in $(dirname "$tv_shows_directory") is sufficient. No action needed."
        # Display the calculated free space
        echo "Calculated free space: $current_free_space GiB"
    fi

    echo "Cleanup process completed."
}

# Pass directory paths as arguments or use defaults
main "$@"

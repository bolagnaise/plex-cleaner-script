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
#fourk_tv_shows_time_period=30 #Uncomment to add time period as above
#fourk_movies_time_period=30 #Uncomment to add time period as above

# Set this to true for a dry run (no files will be deleted)
dry_run=true

# Function to delete old files, prioritizing the oldest ones
delete_old_files() {
    local directory="$1"
    local max_age_days="$2"
    local required_min_free_space_gib="$3"

    if [ "$dry_run" = true ]; then
        echo "Dry run: Would have deleted files in $directory older than $max_age_days days."
    else
        # Find and delete the oldest files within the time period
        while IFS= read -r -d '' file; do
            file_age_days=$(( ( $(date +%s) - $(date -r "$file" +%s) ) / 86400 ))
            if [ "$file_age_days" -gt "$max_age_days" ]; then
                file_size_gib=$(du -sk --apparent-size "$file" | awk '{print $1 / 1024 / 1024}')
                required_min_free_space_gib=$((required_min_free_space_gib - file_size_gib))
                rm "$file"
                echo "Deleted file: $file"
            fi
        done < <(find "$directory" -type f -print0 | sort -z -n -t$'\0' -k1,2)
        
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

        # Determine the appropriate time period for each directory
        if [ "$tv_shows_directory" = "$1" ]; then
            time_period="$tv_shows_time_period"
        elif [ "$movies_directory" = "$1" ]; then
            time_period="$movies_time_period"
        elif [ "$fourk_tv_shows_directory" = "$1" ]; then
            time_period="$fourk_tv_shows_time_period"
        elif [ "$fourk_movies_directory" = "$1" ]; then
            time_period="$fourk_movies_time_period"
        else
            time_period=30  # Default time period if directory not recognized
        fi

        # Perform floating-point comparisons for directory sizes
        if (( $(echo "$current_tv_shows_size >= $required_min_free_space_gib" | bc -l) )) || (( $(echo "$current_movies_size >= $required_min_free_space_gib" | bc -l) )) || (( $(echo "$current_fourk_tv_shows_size >= $required_min_free_space_gib" | bc -l) )) || (( $(echo "$current_fourk_movies_size >= $required_min_free_space_gib" | bc -l) )); then
            echo "Deleting old files older than $time_period days..."
            delete_old_files "$1" "$time_period" "$required_min_free_space_gib"
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

#!/bin/bash
# Author: ABHISHEK KISHOR SINGH
# Created_Date: 28 February, 2023
# Last_Modified_Date: 24 October, 2025
#
# Description:
# A menu-driven BASH toolkit for automating common manual tasks.
#
# Usage:
# Run this script to access all 13 tools from one convenient, menu-driven
# interface, eliminating the need to execute separate commands.

# =============================================================================
# UTILITY FUNCTIONS CENTER (The Toolkit)
# =============================================================================

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Utility Functions ---
print_separator() {
    echo -e "${BLUE}--------------------------------------------------${NC}"
}

print_header() {
    print_separator
    echo -e "${CYAN}$1${NC}"
    print_separator
}

print_error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

print_info() {
    echo -e "${YELLOW}[INFO] $1${NC}"
}

# --- Utility Function: Dependency Check ---
check_dependency() {
    # 'command -v' checks if a command exists
    if ! command -v "$1" &> /dev/null; then
        print_error "Dependency missing: '$1' is not installed."
        print_info "Please install '$1' to use this feature."
        return 1
    fi
    return 0
}


# =============================================================================
# FEATURE FUNCTIONS CENTER (The Tools)
# =============================================================================

# --- Feature Function: Folder Organizer ---
run_folder_organizer() {
    print_header "Folder Organizer Utility"
    
    # 1. Get user input
    read -r -p "Enter the absolute path of the folder to organize: " src_path
    read -r -p "Enter the destination path (default: ~/MyShebangs): " dest_path

    # 2. Validate input
    # Set default destination if input was empty
    if [[ -z "$dest_path" ]]; then
        dest_path="$HOME/MyShebangs"
        print_info "Using default destination: $dest_path"
    fi

    # Check if source directory exists
    if [[ ! -d "$src_path" ]]; then
        print_error "Source path '$src_path' is not a valid directory. Aborting."
        sleep 2 # Pause so user can read the error
        return 1
    fi

    # Create destination directory (and its parents) if it doesn't exist
    mkdir -p "$dest_path"
    
    # Helper function to move files
    _move_file() {
        local file_path="$1"
        local sub_dir="$2"
        
        mkdir -p "$dest_path/$sub_dir"
        
        if mv "$file_path" "$dest_path/$sub_dir/"; then
            print_success "Moved $(basename "$file_path") -> $sub_dir"
        else
            print_error "Failed to move $(basename "$file_path")"
        fi
    }
    
    local special_files_log="$dest_path/specialFiles.list"
    echo "--- Log of Uncategorized Files ---" > "$special_files_log"
    local files_moved=0

    # 3. The Main Loop
    print_info "Scanning '$src_path'..."
    for file in "$src_path"/*; do
        if [[ -f "$file" ]]; then
            files_moved=$((files_moved + 1))
            
            case "$(basename "$file")" in
                *.jpg | *.jpeg | *.png)
                    _move_file "$file" "images"
                    ;;
                *.doc | *.docx | *.txt | *.pdf)
                    _move_file "$file" "documents"
                    ;;
                *.xls | *.xlsx | *.csv)
                    _move_file "$file" "spreadsheets"
                    ;;
                *.sh)
                    _move_file "$file" "scripts"
                    ;;
                *.zip | *.tar | *.tar.gz | *.tar.bz2)
                    _move_file "$file" "archives"
                    ;;
                *.ppt | *.pptx)
                    _move_file "$file" "presentations"
                    ;;
                *.mp3)
                    _move_file "$file" "audio"
                    ;;
                *.mp4)
                    _move_file "$file" "video"
                    ;;
                *)
                    local filename
                    filename=$(basename "$file")
                    echo "$filename" >> "$special_files_log"
                    print_info "Logged '$filename' to specialFiles.list"
                    ;;
            esac
        fi
    done

    print_separator
    if [[ $files_moved -eq 0 ]]; then
        print_info "No files were found to move in '$src_path'."
    else
        print_success "Organization complete. All files moved to '$dest_path'."
        print_info "Uncategorized files are logged in '$special_files_log'"
    fi
    
    read -r -p "Press [Enter] to return to the main menu..."
}

# --- Feature Function: Password Generator ---
run_password_generator() {
    print_header "Password Generator Utility"
    
    # 1. Get user input
    read -r -p "Enter password length (default: 16): " pass_len
    
    # 2. Validate input
    # This regex checks if the input is a positive number
    local num_regex='^[1-9][0-9]*$'
    
    # If input is empty, set default
    if [[ -z "$pass_len" ]]; then
        pass_len=16
        print_info "Using default length: 16 characters."
    # If input is NOT a number, show error and exit function
    elif ! [[ "$pass_len" =~ $num_regex ]]; then
        print_error "Invalid input. Length must be a positive number."
        sleep 2
        return 1 # Exit this function
    # If input is too large (e.g., > 1024)
    elif [[ "$pass_len" -gt 1024 ]]; then
        print_error "Length too large. Please choose a length under 1024."
        sleep 2
        return 1
    fi
    
    # 3. Generate Password
    # Define the set of allowed characters
    local char_set='A-Za-z0-9!@#$%^&*'
    
    # Use /dev/urandom for cryptographically secure random bytes,
    # 'tr' to delete any characters NOT in our set,
    # and 'head' to take the first $pass_len characters.
    print_info "Generating secure password..."
    local password 
    password=$(head /dev/urandom | tr -dc "$char_set" | head -c "$pass_len")
    
    # 4. Display Password
    print_separator
    echo -e "Your new password is:"
    # Use YELLOW to make it stand out
    echo -e "${YELLOW}$password${NC}"
    print_separator
    print_info "Copy this password to a safe place. It is not saved."
    
    read -r -p "Press [Enter] to return to the main menu..."
}

# --- Feature Function: Curf Remover (Safe File Cleaner) ---
run_curf_remover() {
    print_header "Curf Remover (Old File Cleaner)"
    
    # 1. Explain the tool and its risks
    print_info "This utility will find and delete files older than a specified number of days."
    print_error "WARNING: This is a destructive operation. Files are permanently deleted."
    print_info "We will *only* target FILES and EMPTY FOLDERS. Non-empty folders are safe."
    print_separator
    
    # 2. Get user input
    read -r -p "Enter the absolute path of the folder to clean: " clean_path
    read -r -p "Delete files OLDER than how many days? (default: 15): " days
    
    # 3. Validate input
    if [[ -z "$days" ]]; then
        days=15
    fi

    if [[ ! -d "$clean_path" ]]; then
        print_error "Path '$clean_path' is not a valid directory. Aborting."
        sleep 2
        return 1
    fi
    
    # Validate 'days' is a number
    if ! [[ "$days" =~ ^[0-9]+$ ]]; then
        print_error "Invalid input. Days must be a number. Aborting."
        sleep 2
        return 1
    fi
    
    print_info "Searching for files in '$clean_path' older than $days days..."

    # 4. Find files SAFELY and store them in an array
    # We use -print0 and read -d '' to handle all filenames (spaces, newlines, etc.)
    
    # Find files
    local files_to_delete=()
    while IFS= read -r -d '' file; do
        files_to_delete+=("$file")
    done < <(find "$clean_path" -type f -mtime +"$days" -print0)
    
    # Find *empty* directories
    local dirs_to_delete=()
    while IFS= read -r -d '' dir; do
        dirs_to_delete+=("$dir")
    done < <(find "$clean_path" -mindepth 1 -type d -empty -mtime +"$days" -print0)

    local file_count=${#files_to_delete[@]}
    local dir_count=${#dirs_to_delete[@]}
    local total_count=$((file_count + dir_count))

    if [[ $total_count -eq 0 ]]; then
        print_success "No files or empty folders found older than $days days."
        sleep 2
        return 0
    fi
    
    # 5. The "Dry Run" / Confirmation
    print_separator
    print_info "Found ${YELLOW}$file_count files${NC} and ${YELLOW}$dir_count empty folders${NC} to delete."
    echo "You can review the list below:"
    
    # Print the list for the user to see
    printf "  %s\n" "${files_to_delete[@]}"
    printf "  %s\n" "${dirs_to_delete[@]}"
    
    print_separator
    print_error "This action is permanent. Are you sure?"
    read -r -p "Type 'interactive' to confirm one-by-one, or 'ALL' to delete all: " confirm
    
    # 6. The Execution
    case "$confirm" in
        'interactive')
            print_info "Starting interactive deletion..."
            # The '-i' (interactive) and '-v' (verbose) flags are key
            if [[ $file_count -gt 0 ]]; then
                rm -iv "${files_to_delete[@]}"
            fi
            if [[ $dir_count -gt 0 ]]; then
                # 'rmdir' only deletes empty dirs, so it's safe
                rmdir -v "${dirs_to_delete[@]}"
            fi
            print_success "Interactive cleanup complete."
            ;;
            
        'ALL')
            print_info "Starting bulk deletion..."
            # The '-f' (force) and '-v' (verbose) flags are key
            if [[ $file_count -gt 0 ]]; then
                rm -fv "${files_to_delete[@]}"
            fi
            if [[ $dir_count -gt 0 ]]; then
                rmdir -v "${dirs_to_delete[@]}"
            fi
            print_success "Bulk cleanup complete."
            ;;
            
        *)
            print_info "Invalid confirmation. Aborting. No files were deleted."
            ;;
    esac
    
    read -r -p "Press [Enter] to return to the main menu..."
}

# --- Feature Function: User Creator ---
run_user_creator() {
    print_header "User Creator Utility"
    
    # 1. Permission Check
    # Check if the script is being run with root (sudo) privileges.
    # $EUID is the "Effective User ID". 0 is the ID for the root user.
    if [[ "$EUID" -ne 0 ]]; then
        print_error "This action requires root (sudo) privileges."
        print_info "Please run the script again using: sudo ./toolkit_v2.sh"
        sleep 4
        return 1
    fi
    
    print_info "Running with root privileges. Ready to create user."
    
    # 2. Get user input
    read -r -p "Enter the new username: " username

    # 3. Validate input
    # Check if username is empty
    if [[ -z "$username" ]]; then
        print_error "Username cannot be empty. Aborting."
        sleep 2
        return 1
    fi
    
    # Check if user already exists
    if id "$username" &>/dev/null; then
        print_error "User '$username' already exists. Aborting."
        sleep 2
        return 1
    fi
    
    # Basic regex for valid usernames (no spaces, starts with a-z)
    local user_regex='^[a-z_][a-z0-9_-]*$'
    if ! [[ "$username" =~ $user_regex ]]; then
        print_error "Invalid username. Must start with a lowercase letter."
        print_info "Allowed characters: a-z, 0-9, underscore, hyphen."
        sleep 4
        return 1
    fi
    
    # 4. Confirmation and Execution
    print_info "You are about to create a new user named: ${YELLOW}$username${NC}"
    read -r -p "Are you sure you want to proceed? (y/n): " confirm
    
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        print_info "Aborting. No user was created."
        sleep 2
        return 0
    fi
    
    # We use 'useradd' for a more script-friendly (non-interactive) creation.
    # -m : Create the user's home directory.
    # -s /bin/bash : Set the default shell to bash.
    if useradd -m -s /bin/bash "$username"; then
        print_success "Successfully created user '$username'."
        
        # Now, set the password
        print_info "Please set the password for '$username' now."
        print_info "You will be prompted by the 'passwd' command."
        
        # 'passwd' is interactive and will ask for the password.
        passwd "$username"
        
        print_success "Password set. User '$username' is ready."
    else
        print_error "Failed to create user. Check system logs."
        sleep 2
        return 1
    fi
    
    read -r -p "Press [Enter] to return to the main menu..."
}

# --- Feature Function: Indexer (Batch File Renamer) ---
run_indexer() {
    print_header "Indexer (Batch File Renamer)"
    
    # 1. Get user input
    read -r -p "Enter the path to the directory with files to rename: " target_dir
    read -r -p "Enter a new prefix for the files (e.g., 'report-'): " prefix

    # 2. Validate input
    if [[ ! -d "$target_dir" ]]; then
        print_error "Directory '$target_dir' does not exist. Aborting."
        sleep 2
        return 1
    fi
    
    if [[ -z "$prefix" ]]; then
        print_info "No prefix entered. Using 'file-' as default."
        prefix="file-"
    fi

    print_info "This will rename all files in '$target_dir' to '${prefix[number].[original_extension]}'."
    print_error "WARNING: This action is permanent."
    read -r -p "Are you sure you want to proceed? (y/n): " confirm
    
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        print_info "Aborting. No files were renamed."
        sleep 2
        return 0
    fi

    # 3. Execution
    local i=1
    local renamed_count=0
    
    # This loop is safe. It does not use 'cd'.
    # It processes files *in* the specified directory path.
    for old_path in "$target_dir"/*; do
        
        # Check if it's a file (not a directory)
        if [[ -f "$old_path" ]]; then
            
            # Get the filename (e.g., "my photo.jpg")
            local filename 
            filename=$(basename "$old_path")
            
            # Get the extension (e.g., "jpg")
            # ${var##*.} gets everything after the last dot.
            local extension="${filename##*.}"
            
            local new_name
            # Check if the file has no extension (e.g., 'README')
            if [[ "$filename" == "$extension" ]]; then
                # Build new name with no extension
                new_name=$(printf '%s%03d' "$prefix" $i)
            else
                # Build new name and *preserve* the original extension
                new_name=$(printf '%s%03d.%s' "$prefix" $i "$extension")
            fi

            local new_path="$target_dir/$new_name"

            # Rename the file, '-v' (verbose) prints the action
            if mv -v "$old_path" "$new_path"; then
                renamed_count=$((renamed_count + 1))
            else
                print_error "Failed to rename '$filename'."
            fi
            
            i=$((i+1))
        fi
    done
    
    print_separator
    print_success "Renaming complete. $renamed_count files were indexed."
    read -r -p "Press [Enter] to return to the main menu..."
}

# --- Feature Function: CSV Calculator ---
run_csv_calculator() {
    print_header "CSV Calculator"
    
    # 1. Dependency Check
    if ! check_dependency "bc"; then
        sleep 3
        return 1 # Exit this function
    fi
    
    # 2. Get user input
    read -r -p "Enter the path to your CSV file: " csv_file
    read -r -p "Does this file have a header row? (y/n): " has_header

    # 3. Validate input
    if [[ ! -f "$csv_file" ]]; then
        print_error "File not found: '$csv_file'. Aborting."
        sleep 2
        return 1
    fi
    
    print_info "Parsing '$csv_file'..."
    print_separator
    
    local line_count=0
    
    # 4. The Loop
    # We create a 'file_processor' variable to hold the command
    # that will correctly stream the file.
    local file_processor
    if [[ "$has_header" == "y" || "$has_header" == "Y" ]]; then
        # 'tail -n +2' skips the first line (the header)
        file_processor="tail -n +2 \"$csv_file\""
    else
        # 'cat' just streams the whole file
        file_processor="cat \"$csv_file\""
    fi

    # 'eval' runs the command string we built
    # The 'while' loop reads from the output of that command
    while IFS=',' read -r col1 col2 col3 col4; do
        # We check if col3 and col4 look like numbers
        if [[ "$col3" =~ ^[0-9.]+$ && "$col4" =~ ^[0-9.]+$ ]]; then
            # Perform calculations
            local sum
            sum=$(echo "$col3 + $col4" | bc)
            local avg
            avg=$(echo "scale=2; $sum / 2" | bc)

            # Print the results
            echo "Name: $col1"
            echo "ID: $col2"
            echo -e "Total: ${GREEN}$sum${NC}"
            echo -e "Average: ${YELLOW}$avg${NC}"
            echo ""
            
            local line_count
            line_count=$((line_count + 1))
        else
            # Skip lines where col3/col4 aren't numbers (like a blank line)
            print_info "Skipping malformed line..."
        fi
    done < <(eval "$file_processor")
    
    print_separator
    print_success "Calculation complete. Processed $line_count valid lines."
    read -r -p "Press [Enter] to return to the main menu..."
}

# --- Feature Function: Service Manager ---

run_service_manager() {
    print_header "Service Manager (systemd)"
    
    # 1. Permission Check
    if [[ "$EUID" -ne 0 ]]; then
        print_error "This action requires root (sudo) privileges."
        print_info "Please run the script again using: sudo ./toolkit_v2.sh"
        sleep 4
        return 1
    fi
    
    # 2. Dependency Check
    if ! check_dependency "systemctl"; then
        print_error "'systemctl' (systemd) is not available on this system."
        sleep 3
        return 1
    fi
    
    # 3. Get user input
    read -r -p "Enter the name of the service (e.g., 'ssh', 'apache2'): " service_name

    if [[ -z "$service_name" ]]; then
        print_error "No service name entered. Aborting."
        sleep 2
        return 1
    fi
    
    # 4. Check Status
    # We use 'systemctl is-active' for a simple status check.
    # The '|| true' part prevents the script from exiting if 'is-active' fails
    local status
    status=$(systemctl is-active "$service_name" || true)

    print_separator
    case "$status" in
        'active')
            print_success "Service '$service_name' is ACTIVE and RUNNING."
            print_separator
            read -r -p "Do you want to (s)top or (r)estart this service? (any other key to exit): " action
            case "$action" in
                s | S)
                    print_info "Attempting to STOP '$service_name'..."
                    systemctl stop "$service_name"
                    print_success "Service stopped."
                    ;;
                r | R)
                    print_info "Attempting to RESTART '$service_name'..."
                    systemctl restart "$service_name"
                    print_success "Service restarted."
                    ;;
                *)
                    print_info "No action taken."
                    ;;
            esac
            ;;
        'inactive')
            print_info "Service '$service_name' is INACTIVE (stopped)."
            print_separator
            read -r -p "Do you want to (s)tart this service? (y/n): " action
            if [[ "$action" == "y" || "$action" == "Y" ]]; then
                print_info "Attempting to START '$service_name'..."
                systemctl start "$service_name"
                print_success "Service started."
            else
                print_info "No action taken."
            fi
            ;;
        'failed')
            print_error "Service '$service_name' is in a FAILED state."
            print_separator
            print_info "Run 'systemctl status $service_name' or 'journalctl -u $service_name' for details."
            read -r -p "Do you want to attempt a (r)estart? (y/n): " action
            if [[ "$action" == "y" || "$action" == "Y" ]]; then
                print_info "Attempting to RESTART '$service_name'..."
                systemctl restart "$service_name"
                print_success "Restart attempted."
            else
                print_info "No action taken."
            fi
            ;;
        *)
            print_error "Could not determine status for '$service_name'."
            print_info "It may be 'unknown', 'activating', or the service may not exist."
            ;;
    esac
    
    read -r -p "Press [Enter] to return to the main menu..."
}

# --- Feature Function: Online Image Extractor ---
run_image_extractor() {
    print_header "Online Image Extractor"
    
    # 1. Dependency Check
    if ! check_dependency "wget"; then
        print_info "This tool uses 'wget' to download files."
        sleep 3
        return 1
    fi
    
    # 2. Get user input
    read -r -p "Enter the full website URL to scan (e.g., https://example.com): " target_url
    read -r -p "Enter directory to save images (default: ~/Downloads/ExtractedImages): " save_dir

    # 3. Validate input
    if [[ -z "$target_url" ]]; then
        print_error "No URL provided. Aborting."
        sleep 2
        return 1
    fi
    
    # Set default save directory if input was empty
    if [[ -z "$save_dir" ]]; then
        save_dir="$HOME/Downloads/ExtractedImages"
    fi
    
    # 4. Create directory and check for success
    if ! mkdir -p "$save_dir"; then
        print_error "Could not create save directory: $save_dir"
        print_info "Please check permissions. Aborting."
        sleep 3
        return 1
    fi
    
    print_info "Save directory set: $save_dir"
    print_info "Starting download from '$target_url'..."
    print_info "This may take some time..."
    
    # 5. Execution
    # -r : Recursive
    # -l 1 : Only go 1 level deep (this is a *safe* default)
    # -nd : No directories (put all files in one folder)
    # -A : Accept only these file types
    # -P : Prefix (the directory to save to)
    # -np : No parent (don't ascend to parent directories)
    # --quiet : Suppress most output to keep our UI clean
    wget -r -l 1 -nd -np -A "jpg,jpeg,png,gif" -P "$save_dir" "$target_url" --quiet
    
    # 6. Report results
    # Check how many files were *actually* downloaded by counting them
    local files_found
    files_found=$(find "$save_dir" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) | wc -l)
    
    print_separator
    if [[ $files_found -gt 0 ]]; then
        print_success "Download complete. Saved $files_found images to '$save_dir'."
    else
        print_info "Scan complete. No images matching (jpg, jpeg, png, gif) were found on that page."
        # Clean up the empty directory we made
        rmdir "$save_dir" 2>/dev/null
    fi
    
    read -r -p "Press [Enter] to return to the main menu..."
}

# --- Feature Function: TarBall Mailer ---
run_tarball_mailer() {
    print_header "TarBall Mailer (Backup & Notify)"
    
    # 1. Dependency Checks
    if ! check_dependency "tar"; then
        print_info "This tool uses 'tar' to create archives."
        sleep 3
        return 1
    fi
    if ! check_dependency "mail"; then
        print_error "Dependency 'mail' (often from 'mailutils') is not installed."
        print_info "Cannot send email notifications. Aborting."
        sleep 3
        return 1
    fi
    
    # 2. Get user input
    read -r -p "Enter the full path of the SOURCE directory to backup: " src_dir
    read -r -p "Enter the full path of the DESTINATION directory for the backup: " dest_dir
    read -r -p "Enter the email address for notification: " email_addr

    # 3. Validate input
    if [[ ! -d "$src_dir" ]]; then
        print_error "Source directory '$src_dir' does not exist. Aborting."
        sleep 2
        return 1
    fi
    
    # Basic email regex (checks for '@' and '.')
    if ! [[ "$email_addr" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
        print_error "Invalid email address format. Aborting."
        sleep 2
        return 1
    fi
    
    # Create the destination directory
    if ! mkdir -p "$dest_dir"; then
        print_error "Could not create destination directory '$dest_dir'."
        print_info "Please check permissions. Aborting."
        sleep 3
        return 1
    fi
    
    # 4. Prepare for archive
    # Get just the folder name from the source path (e.g., /home/user/docs -> docs)
    local src_folder_name
    src_folder_name=$(basename "$src_dir")
    local backup_filename
    backup_filename="${src_folder_name}_$(date +%Y-%m-%d_%H%M%S).tar.gz"
    local full_backup_path="$dest_dir/$backup_filename"
    
    print_info "Preparing to archive '$src_dir'..."
    print_info "Target file: $full_backup_path"
    
    # 5. Execution (Create Archive)
    # c = create, z = gzip, f = file
    # We use '-C' to change *into* the parent directory of $src_dir,
    # which lets us archive just the folder 'docs' instead of '/home/user/docs'.
    # This creates a cleaner archive.
    
    if tar -czf "$full_backup_path" -C "$(dirname "$src_dir")" "$src_folder_name"; then
        # The 'tar' command was successful
        print_success "Backup archive created successfully!"
        print_separator
        print_info "Sending email notification to $email_addr..."
        
        # 6. Send Email
        local subject="[Backup SUCCESS] $src_folder_name"
        local body
        body="Backup of '$src_dir' was successfully created.
        
File: $full_backup_path
Host: $(hostname)
Date: $(date)"

        # Send the email
        echo "$body" | mail -s "$subject" "$email_addr"
        
        print_success "Email notification sent."
        
    else
        # The 'tar' command failed
        print_error "Archive creation FAILED."
        print_info "No email notification will be sent."
        # Clean up the failed (likely 0-byte) archive file
        rm "$full_backup_path" 2>/dev/null
        sleep 2
        return 1
    fi
    
    read -r -p "Press [Enter] to return to the main menu..."
}

# --- Feature Function: Term/Phase Fetcher (grep wrapper) ---
run_term_fetcher() {
    print_header "Term/Phase Fetcher (grep)"
    
    # 1. Dependency Check
    if ! check_dependency "grep"; then
        sleep 3
        return 1
    fi
    
    # 2. Get user input
    read -r -p "Enter the word or phrase to search for: " search_term
    read -r -p "Enter directory to search in (default: current directory): " search_dir
    read -r -p "Make search case-insensitive? (y/n): " case_insensitive

    # 3. Validate input
    if [[ -z "$search_term" ]]; then
        print_error "No search term provided. Aborting."
        sleep 2
        return 1
    fi
    
    # Set default search directory if input was empty
    if [[ -z "$search_dir" ]]; then
        search_dir="."
        print_info "Using current directory for search."
    fi
    
    if [[ ! -d "$search_dir" ]]; then
        print_error "Directory '$search_dir' does not exist. Aborting."
        sleep 2
        return 1
    fi
    
    # 4. Build 'grep' command options
    # -r : Recursive
    # -n : Show line numbers
    # -I : Ignore binary files
    # --color=auto : Highlight matches
    local grep_opts="-r -n -I --color=auto"
    
    if [[ "$case_insensitive" == "y" || "$case_insensitive" == "Y" ]]; then
        grep_opts+=" -i"
        print_info "Running case-insensitive search..."
    else
        print_info "Running case-sensitive search..."
    fi

    print_info "Searching for '${YELLOW}$search_term${NC}' in '$search_dir'..."
    print_separator
    
    # 5. Execution
    # We run 'grep' and let it print directly to the terminal.
    # '2>/dev/null' suppresses permission denied errors.
    grep "$grep_opts" "$search_term" "$search_dir" 2>/dev/null
    
    # Capture the exit code of the 'grep' command
    local exit_code=$?
    
    print_separator
    
    # 6. Report results based on 'grep' exit code
    # 0 = Matches found
    # 1 = No matches found
    # 2 = Error (e.g., directory not found, though we checked)
    case $exit_code in
        0)
            print_success "Search complete. Matches found."
            ;;
        1)
            print_info "Search complete. No matches found for '$search_term'."
            ;;
        *)
            print_error "An error occurred during the search."
            ;;
    esac

    read -r -p "Press [Enter] to return to the main menu..."
}

# --- Feature Function: Network Diagnostic Tool ---
run_network_diagnostics() {
    print_header "Network Diagnostic Tool"
    
    # 1. Dependency Checks
    if ! check_dependency "ping"; then sleep 3; return 1; fi
    if ! check_dependency "ip"; then 
        print_error "'ip' command not found. Cannot determine gateway."
        sleep 3
        return 1
    fi
    if ! check_dependency "nslookup"; then sleep 3; return 1; fi
    
    # 2. Get user input
    read -r -p "Enter a domain to test (default: google.com): " domain
    if [[ -z "$domain" ]]; then
        domain="google.com"
    fi
    
    print_info "Running 3-step network diagnostic..."
    print_separator
    
    local all_passed=true
    
    # --- Step 1: Test Gateway (Local Network) ---
    local gateway_ip
    gateway_ip=$(ip route | grep default | awk '{print $3}')
    
    if [[ -z "$gateway_ip" ]]; then
        print_error "Could not determine gateway IP. Skipping Step 1."
        all_passed=false
    else
        print_info "Step 1/3: Pinging gateway ($gateway_ip)..."
        # -c 3 = send 3 packets, -W 2 = 2-second timeout
        if ping -c 3 -W 2 "$gateway_ip" &>/dev/null; then
            print_success "  [PASS] Gateway is reachable."
        else
            print_error "  [FAIL] Gateway is NOT reachable."
            all_passed=false
        fi
    fi
    
    # --- Step 2: Test Internet (External IP) ---
    print_info "Step 2/3: Pinging public DNS (8.8.8.8)..."
    if ping -c 3 -W 2 "8.8.8.8" &>/dev/null; then
        print_success "  [PASS] Public internet is reachable."
    else
        print_error "  [FAIL] Public internet is NOT reachable."
        all_passed=false
    fi

    # --- Step 3: Test DNS (Name Resolution) ---
    print_info "Step 3/3: Resolving domain ($domain)..."
    if nslookup "$domain" &>/dev/null; then
        print_success "  [PASS] DNS resolution is working."
        # Run it again so the user sees the output
        nslookup "$domain"
    else
        print_error "  [FAIL] DNS resolution FAILED."
        all_passed=false
    fi
    
    # --- Final Report ---
    print_separator
    if [[ "$all_passed" == "true" ]]; then
        print_success "All network checks passed. Connectivity is good!"
    else
        print_error "One or more network checks failed. Please review."
    fi
    
    read -r -p "Press [Enter] to return to the main menu..."
}

# --- Feature Function: System Health Dashboard ---
run_system_health() {
    print_header "System Health Dashboard"
    
    # 1. Dependency Checks
    # We check for all the commands we will use.
    if ! check_dependency "free"; then sleep 3; return 1; fi
    if ! check_dependency "df"; then sleep 3; return 1; fi
    if ! check_dependency "uptime"; then sleep 3; return 1; fi
    if ! check_dependency "hostname"; then sleep 3; return 1; fi

    local host
    host=$(hostname)
    
    # 2. Clear screen to create a "dashboard" effect
    clear
    print_header "System Health Report for: ${YELLOW}$host${NC}"

    # 3. Show Uptime & Load Average
    echo -e "${CYAN}--- Uptime & Load ---${NC}"
    uptime
    echo ""

    # 4. Show Memory Usage
    # 'free -h' = human-readable format
    echo -e "${CYAN}--- Memory Usage ---${NC}"
    free -h
    echo ""
    
    # 5. Show Disk Usage
    # 'df -h' = human-readable format
    # '-T' = show filesystem type (e.g., ext4, ntfs)
    # '--exclude-type=squashfs' = hide snap/flatpak loop devices
    echo -e "${CYAN}--- Filesystem Disk Usage ---${NC}"
    df -h -T --exclude-type=squashfs
    echo ""
    
    print_separator
    read -r -p "Press [Enter] to return to the main menu..."
}

# --- Feature Function: Log File Analyzer ---
run_log_analyzer() {
    print_header "Log File Analyzer"
    
    # 1. Dependency Checks
    if ! check_dependency "grep"; then sleep 3; return 1; fi
    if ! check_dependency "tail"; then sleep 3; return 1; fi
    
    # 2. Get user input
    read -r -p "Enter the full path to the log file (e.g., /var/log/syslog): " log_file
    read -r -p "Enter search term (e.g., ERROR, Failed, WARNING): " keyword
    read -r -p "How many recent lines to show? (default: 10): " line_count

    # 3. Validate input
    if [[ ! -f "$log_file" ]]; then
        print_error "Log file not found: '$log_file'. Aborting."
        sleep 2
        return 1
    fi
    
    if [[ -z "$keyword" ]]; then
        print_error "No search term provided. Aborting."
        sleep 2
        return 1
    fi
    
    if [[ -z "$line_count" ]]; then
        line_count=10
    elif ! [[ "$line_count" =~ ^[0-9]+$ ]]; then
        print_error "Invalid input. Lines must be a number."
        sleep 2
        return 1
    fi
    
    print_info "Searching '$log_file' for the $line_count most recent lines containing '${YELLOW}$keyword${NC}'..."
    print_separator
    
    # 4. Execution
    # 'grep' finds all matching lines (case-insensitive)
    # 'tail' takes just the last $line_count lines
    # '--color=always' forces grep to color, even in a pipe
    local results
    results=$(grep -i -n --color=always "$keyword" "$log_file" 2>/dev/null | tail -n "$line_count")
    
    # 5. Report Results
    if [[ -z "$results" ]]; then
        print_info "Search complete. No matches found."
    else
        echo -e "$results"
        print_separator
        print_success "Search complete. Showing most recent matches."
    fi
    
    read -r -p "Press [Enter] to return to the main menu..."
}
# --- (This is where you will add your NEXT function, e.g. run_password_generator) ---


# =============================================================================
# MAIN MENU & SCRIPT LOGIC CENTER (The Engine)
# =============================================================================

# Function to display the main menu
show_main_menu() {
    clear

# Comment off the lines 1050 to 1060 to disable the banner.    
echo -e "${GREEN}  
++======================================================================++
| ╔═╗╔═╗╔═══╗╔═╗ ╔╗╔═══╗╔╗╔═══╗     ╔════╗╔═══╗╔═══╗╔╗   ╔╗╔═╗╔══╗╔════╗ |
| ╚╗╚╝╔╝║╔══╝║║╚╗║║║╔═╗║║║║╔═╗║     ║╔╗╔╗║║╔═╗║║╔═╗║║║   ║║║╔╝╚╣╠╝║╔╗╔╗║ |
|  ╚╗╔╝ ║╚══╗║╔╗╚╝║║║ ║║╚╝║╚══╗     ╚╝║║╚╝║║ ║║║║ ║║║║   ║╚╝╝  ║║ ╚╝║║╚╝ |
|  ╔╝╚╗ ║╔══╝║║╚╗║║║║ ║║  ╚══╗║       ║║  ║║ ║║║║ ║║║║ ╔╗║╔╗║  ║║   ║║   |
| ╔╝╔╗╚╗║╚══╗║║ ║║║║╚═╝║  ║╚═╝║      ╔╝╚╗ ║╚═╝║║╚═╝║║╚═╝║║║║╚╗╔╣╠╗ ╔╝╚╗  |
| ╚═╝╚═╝╚═══╝╚╝ ╚═╝╚═══╝  ╚═══╝      ╚══╝ ╚═══╝╚═══╝╚═══╝╚╝╚═╝╚══╝ ╚══╝  |
|                             BASH EDITION                               |
++======================================================================++
${NC}"
    echo -e "${CYAN}Select an option to proceed:${NC}"
    echo
    echo "1. Folder Organizer"
    echo "2. Password Generator"
    echo "3. Curf Remover (Safe File Cleaner)"
    echo "4. User Creation"
    echo "5. Indexer (Batch File Renamer)"
    echo "6. CSV Calculator"
    echo "7. Service Manager"
    echo "8. Online Image Extractor"
    echo "9. TarBall Mailer"
    echo "10. Term/Phase Fetcher"
    echo "11. Network Diagnostic Tool"
    echo "12. System Health Dashboard"
    echo "13. Log File Analyzer"
    echo
    echo -e "${RED}q. Quit${NC}"
    print_separator
}

# --- Main Loop ---
# This loop runs forever until the user presses 'q'
while true; do
    show_main_menu
    read -r -p "Enter your choice: " choice
    
    case $choice in
        1) run_folder_organizer ;;
        2) run_password_generator ;;
        3) run_curf_remover ;;
        4) run_user_creator ;;
        5) run_indexer ;;
        6) run_csv_calculator ;;
        7) run_service_manager ;;
        8) run_image_extractor ;;
        9) run_tarball_mailer ;;
        10) run_term_fetcher ;;
        11) run_network_diagnostics ;;
        12) run_system_health ;;
        13) run_log_analyzer ;;                                     
        q | Q)
            echo "Ending Process!"
            break # This command exits the 'while true' loop
            ;;
        *)
            print_error "Invalid option '$choice'. Please try again."
            sleep 2
            ;;
    esac
done

#!/usr/bin/env python3
# Author: ABHISHEK KISHOR SINGH 
# Created_Date: 24 October, 2025
# Last_Modified_Date: 
#
# Description:
# A menu-driven Python toolkit for automating common manual tasks.
#
# Usage:
# Run this script to access all 13 tools from one convenient, menu-driven
# interface, eliminating the need to execute separate commands.

import os
import sys
import shutil
import subprocess
import csv
import secrets
import string
import socket
import re
import time
from pathlib import Path
from datetime import datetime

# =============================================================================
# UTILITY FUNCTIONS CENTER (The Toolkit)
# =============================================================================

# --- Color Definitions ---
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[0;33m'
BLUE = '\033[0;34m'
CYAN = '\033[0;36m'
NC = '\033[0m'  # No Color

# --- Utility Functions ---
def print_separator():
    """Prints a blue horizontal line."""
    print(f"{BLUE}--------------------------------------------------{NC}")

def print_header(message: str):
    """Prints a message as a cyan header."""
    print_separator()
    print(f"{CYAN}{message}{NC}")
    print_separator()

def print_error(message: str):
    """Prints an error message in red to stderr."""
    print(f"{RED}[ERROR] {message}{NC}", file=sys.stderr)

def print_success(message: str):
    """Prints a success message in green."""
    print(f"{GREEN}[SUCCESS] {message}{NC}")

def print_info(message: str):
    """Prints an info message in yellow."""
    print(f"{YELLOW}[INFO] {message}{NC}")

def pause():
    """Waits for the user to press Enter."""
    input("\nPress [Enter] to return to the main menu...")

def check_dependency(command: str) -> bool:
    """Checks if a command-line utility is installed."""
    if not shutil.which(command):
        print_error(f"Dependency missing: '{command}' is not installed.")
        print_info(f"Please install '{command}' to use this feature.")
        return False
    return True

def check_root(prompt=True) -> bool:
    """Checks if the script is run as root."""
    if os.geteuid() != 0:
        if prompt:
            print_error("This action requires root (sudo) privileges.")
            print_info("Please run the script again using: sudo ./toolkit.py")
            pause()
        return False
    return True

# =============================================================================
# FEATURE FUNCTIONS CENTER (The Tools)
# =============================================================================

# --- 1. Folder Organizer ---
def run_folder_organizer():
    print_header("Folder Organizer Utility")
    
    src_path_str = input("Enter the absolute path of the folder to organize: ")
    dest_path_str = input("Enter the destination path (default: ~/MyShebangs): ")

    src_path = Path(src_path_str).expanduser()
    
    if not dest_path_str:
        dest_path = Path.home() / "MyShebangs"
        print_info(f"Using default destination: {dest_path}")
    else:
        dest_path = Path(dest_path_str).expanduser()

    if not src_path.is_dir():
        print_error(f"Source path '{src_path}' is not a valid directory. Aborting.")
        return

    # Define file categories
    CATEGORIES = {
        "images": [".jpg", ".jpeg", ".png"],
        "documents": [".doc", ".docx", ".txt", ".pdf"],
        "spreadsheets": [".xls", ".xlsx", ".csv"],
        "scripts": [".sh", ".py"],
        "archives": [".zip", ".tar", ".tar.gz", ".tar.bz2"],
        "presentations": [".ppt", ".pptx"],
        "audio": [".mp3"],
        "video": [".mp4"]
    }

    # Invert the mapping for faster lookups
    EXT_MAP = {ext: category for category, exts in CATEGORIES.items() for ext in exts}

    dest_path.mkdir(parents=True, exist_ok=True)
    special_files_log = dest_path / "specialFiles.list"
    files_moved = 0

    print_info(f"Scanning '{src_path}'...")
    with open(special_files_log, "w") as log_file:
        log_file.write("--- Log of Uncategorized Files ---\n")
        
        for file in src_path.glob("*"):
            if file.is_file():
                category = EXT_MAP.get(file.suffix.lower())
                
                if category:
                    sub_dir = dest_path / category
                    sub_dir.mkdir(exist_ok=True)
                    try:
                        shutil.move(str(file), str(sub_dir))
                        print_success(f"Moved {file.name} -> {category}")
                        files_moved += 1
                    except Exception as e:
                        print_error(f"Failed to move {file.name}: {e}")
                else:
                    log_file.write(f"{file.name}\n")
                    print_info(f"Logged '{file.name}' to specialFiles.list")

    print_separator()
    if files_moved == 0:
        print_info(f"No files were found to move in '{src_path}'.")
    else:
        print_success(f"Organization complete. {files_moved} files moved to '{dest_path}'.")
        print_info(f"Uncategorized files are logged in '{special_files_log}'")
    
    pause()

# --- 2. Password Generator ---
def run_password_generator():
    print_header("Password Generator Utility")
    
    pass_len_str = input("Enter password length (default: 16): ") or "16"
    
    try:
        pass_len = int(pass_len_str)
        if pass_len <= 0:
            raise ValueError("Length must be positive")
        if pass_len > 1024:
            print_error("Length too large. Please choose a length under 1024.")
            return
    except ValueError:
        print_error("Invalid input. Length must be a positive number.")
        return

    char_set = string.ascii_letters + string.digits + '!@#$%^&*'
    
    print_info("Generating secure password...")
    password = "".join(secrets.choice(char_set) for _ in range(pass_len))
    
    print_separator()
    print("Your new password is:")
    print(f"{YELLOW}{password}{NC}")
    print_separator()
    print_info("Copy this password to a safe place. It is not saved.")
    
    pause()

# --- 3. Curf Remover (Safe File Cleaner) ---
def run_curf_remover():
    print_header("Curf Remover (Old File Cleaner)")
    
    print_info("This utility will find and delete files older than a specified number of days.")
    print_error("WARNING: This is a destructive operation. Files are permanently deleted.")
    print_info("We will *only* target FILES and EMPTY FOLDERS. Non-empty folders are safe.")
    print_separator()
    
    clean_path_str = input("Enter the absolute path of the folder to clean: ")
    days_str = input("Delete files OLDER than how many days? (default: 15): ") or "15"

    clean_path = Path(clean_path_str).expanduser()

    if not clean_path.is_dir():
        print_error(f"Path '{clean_path}' is not a valid directory. Aborting.")
        return

    if not days_str.isdigit() or int(days_str) < 0:
        print_error("Invalid input. Days must be a non-negative number. Aborting.")
        return

    print_info(f"Searching for files in '{clean_path}' older than {days_str} days...")

    # Use 'find' as it's more direct for -mtime and -empty
    def find_items(cmd_args):
        try:
            result = subprocess.run(cmd_args, capture_output=True, text=True, check=True, encoding='utf-8')
            # Split lines and filter out empty strings
            return [Path(line) for line in result.stdout.strip().split('\n') if line]
        except subprocess.CalledProcessError as e:
            print_error(f"Find command failed: {e.stderr}")
            return []
        except FileNotFoundError:
            print_error("`find` command not found. This tool is not compatible with your system.")
            return []

    files_cmd = ["find", str(clean_path), "-type", "f", "-mtime", f"+{days_str}"]
    dirs_cmd = ["find", str(clean_path), "-mindepth", "1", "-type", "d", "-empty", "-mtime", f"+{days_str}"]

    files_to_delete = find_items(files_cmd)
    dirs_to_delete = find_items(dirs_cmd) # Find empty dirs first

    file_count = len(files_to_delete)
    dir_count = len(dirs_to_delete)
    total_count = file_count + dir_count

    if total_count == 0:
        print_success(f"No files or empty folders found older than {days_str} days.")
        return

    print_separator()
    print_info(f"Found {YELLOW}{file_count} files{NC} and {YELLOW}{dir_count} empty folders{NC} to delete.")
    print("You can review the list below:")
    
    for f in files_to_delete: print(f"  [FILE] {f}")
    for d in dirs_to_delete: print(f"  [DIR]  {d}")
    
    print_separator()
    print_error("This action is permanent. Are you sure?")
    confirm = input("Type 'interactive' to confirm one-by-one, or 'ALL' to delete all: ")

    if confirm == 'interactive':
        print_info("Starting interactive deletion...")
        for item in files_to_delete + dirs_to_delete:
            item_type = "file" if item.is_file() else "directory"
            choice = input(f"  Delete {item_type} '{item}'? (y/n): ").lower()
            if choice == 'y':
                try:
                    if item.is_file(): item.unlink()
                    elif item.is_dir(): item.rmdir()
                    print_success(f"    Deleted {item.name}")
                except Exception as e:
                    print_error(f"    Failed to delete {item.name}: {e}")
        print_success("Interactive cleanup complete.")
            
    elif confirm == 'ALL':
        print_info("Starting bulk deletion...")
        for item in files_to_delete + dirs_to_delete:
            try:
                if item.is_file(): item.unlink()
                elif item.is_dir(): item.rmdir()
                print_success(f"  Deleted {item}")
            except Exception as e:
                print_error(f"  Failed to delete {item}: {e}")
        print_success("Bulk cleanup complete.")
            
    else:
        print_info("Invalid confirmation. Aborting. No files were deleted.")
    
    pause()

# --- 4. User Creator ---
def run_user_creator():
    print_header("User Creator Utility")
    
    if not check_root():
        return
    
    print_info("Running with root privileges. Ready to create user.")
    
    username = input("Enter the new username: ")

    if not username:
        print_error("Username cannot be empty. Aborting.")
        return
    
    # Check if user already exists
    try:
        import pwd
        pwd.getpwnam(username)
        print_error(f"User '{username}' already exists. Aborting.")
        return
    except (ImportError, KeyError):
        # pwd module not on windows, or user not found (which is good)
        pass 
    except Exception as e:
        print_info(f"Could not check user (this may be ok): {e}")

    # Basic regex for valid usernames
    user_regex = re.compile(r'^[a-z_][a-z0-9_-]*$')
    if not user_regex.match(username):
        print_error("Invalid username. Must start with a lowercase letter.")
        print_info("Allowed characters: a-z, 0-9, underscore, hyphen.")
        return
    
    print_info(f"You are about to create a new user named: {YELLOW}{username}{NC}")
    confirm = input("Are you sure you want to proceed? (y/n): ").lower()
    
    if confirm != "y":
        print_info("Aborting. No user was created.")
        return
    
    try:
        # Use 'useradd' for script-friendly creation
        subprocess.run(["useradd", "-m", "-s", "/bin/bash", username], check=True)
        print_success(f"Successfully created user '{username}'.")
        
        print_info(f"Please set the password for '{username}' now.")
        print_info("You will be prompted by the 'passwd' command.")
        
        # 'passwd' is interactive
        subprocess.run(["passwd", username])
        
        print_success(f"Password set. User '{username}' is ready.")
    except FileNotFoundError:
        print_error("`useradd` or `passwd` command not found. This tool requires a Linux system.")
    except subprocess.CalledProcessError as e:
        print_error(f"Failed to create user. Return code: {e.returncode}")
    
    pause()

# --- 5. Indexer (Batch File Renamer) ---
def run_indexer():
    print_header("Indexer (Batch File Renamer)")
    
    target_dir_str = input("Enter the path to the directory with files to rename: ")
    prefix = input("Enter a new prefix for the files (e.g., 'report-'): ") or "file-"

    target_dir = Path(target_dir_str).expanduser()

    if not target_dir.is_dir():
        print_error(f"Directory '{target_dir}' does not exist. Aborting.")
        return

    print_info(f"This will rename all files in '{target_dir}' to '{prefix}[number].[original_extension]'.")
    print_error("WARNING: This action is permanent.")
    confirm = input("Are you sure you want to proceed? (y/n): ").lower()
    
    if confirm != "y":
        print_info("Aborting. No files were renamed.")
        return

    i = 1
    renamed_count = 0
    
    # Use sorted() for a predictable order
    for old_path in sorted(target_dir.glob("*")):
        if old_path.is_file():
            # new_name preserves the original extension
            new_name = f"{prefix}{i:03d}{old_path.suffix}"
            new_path = target_dir / new_name
            
            try:
                # Use rename for speed
                old_path.rename(new_path)
                print_success(f"Renamed '{old_path.name}' -> '{new_name}'")
                renamed_count += 1
                i += 1
            except Exception as e:
                print_error(f"Failed to rename '{old_path.name}': {e}")
    
    print_separator()
    print_success(f"Renaming complete. {renamed_count} files were indexed.")
    pause()

# --- 6. CSV Calculator ---
def run_csv_calculator():
    print_header("CSV Calculator")
    
    # No 'bc' dependency in Python!
    
    csv_file_str = input("Enter the path to your CSV file: ")
    has_header_str = input("Does this file have a header row? (y/n): ").lower()

    csv_file = Path(csv_file_str).expanduser()

    if not csv_file.is_file():
        print_error(f"File not found: '{csv_file}'. Aborting.")
        return
    
    print_info(f"Parsing '{csv_file}'...")
    print_separator()
    
    line_count = 0
    try:
        with open(csv_file, mode='r', encoding='utf-8') as f:
            reader = csv.reader(f)
            
            if has_header_str == 'y':
                try:
                    next(reader)  # Skip the header row
                except StopIteration:
                    print_info("File is empty.")
                    return

            for row in reader:
                try:
                    # Expect at least 4 columns
                    col1, col2, col3_str, col4_str = row[0:4]
                    
                    # Convert to numbers
                    col3 = float(col3_str)
                    col4 = float(col4_str)
                    
                    sum_val = col3 + col4
                    avg_val = sum_val / 2
                    
                    print(f"Name: {col1}")
                    print(f"ID: {col2}")
                    print(f"Total: {GREEN}{sum_val}{NC}")
                    print(f"Average: {YELLOW}{avg_val:.2f}{NC}") # Format to 2 decimal places
                    print("")
                    
                    line_count += 1
                    
                except (ValueError, IndexError):
                    print_info(f"Skipping malformed line: {row}")
    
    except FileNotFoundError:
        print_error(f"File not found: '{csv_file}'.")
    except Exception as e:
        print_error(f"An error occurred: {e}")

    print_separator()
    print_success(f"Calculation complete. Processed {line_count} valid lines.")
    pause()

# --- 7. Service Manager ---
def run_service_manager():
    print_header("Service Manager (systemd)")
    
    if not check_root():
        return
    
    if not check_dependency("systemctl"):
        return
    
    service_name = input("Enter the name of the service (e.g., 'ssh', 'apache2'): ")

    if not service_name:
        print_error("No service name entered. Aborting.")
        return
    
    # Check Status
    try:
        result = subprocess.run(
            ["systemctl", "is-active", service_name], 
            capture_output=True, text=True
        )
        status = result.stdout.strip()
    except FileNotFoundError:
        print_error("`systemctl` command not found.")
        return

    print_separator()
    
    def run_systemctl_action(action):
        print_info(f"Attempting to {action.upper()} '{service_name}'...")
        try:
            subprocess.run(["systemctl", action, service_name], check=True)
            print_success(f"Service {action}ed.")
        except subprocess.CalledProcessError:
            print_error(f"Failed to {action} service.")

    if status == 'active':
        print_success(f"Service '{service_name}' is ACTIVE and RUNNING.")
        print_separator()
        action = input("Do you want to (s)top or (r)estart this service? (any other key to exit): ").lower()
        if action == 's':
            run_systemctl_action("stop")
        elif action == 'r':
            run_systemctl_action("restart")
        else:
            print_info("No action taken.")
            
    elif status == 'inactive':
        print_info(f"Service '{service_name}' is INACTIVE (stopped).")
        print_separator()
        action = input("Do you want to (s)tart this service? (y/n): ").lower()
        if action == 'y':
            run_systemctl_action("start")
        else:
            print_info("No action taken.")
            
    elif status == 'failed':
        print_error(f"Service '{service_name}' is in a FAILED state.")
        print_separator()
        print_info(f"Run 'systemctl status {service_name}' or 'journalctl -u {service_name}' for details.")
        action = input("Do you want to attempt a (r)estart? (y/n): ").lower()
        if action == 'y':
            run_systemctl_action("restart")
        else:
            print_info("No action taken.")
            
    else:
        print_error(f"Could not determine status for '{service_name}'.")
        print_info(f"Status reported: '{status}' (may be 'unknown', 'activating', or non-existent).")
    
    pause()

# --- 8. Online Image Extractor ---
def run_image_extractor():
    print_header("Online Image Extractor")
    
    if not check_dependency("wget"):
        return
    
    target_url = input("Enter the full website URL to scan (e.g., https://example.com): ")
    save_dir_str = input("Enter directory to save images (default: ~/Downloads/ExtractedImages): ")
    
    if not target_url:
        print_error("No URL provided. Aborting.")
        return
    
    if not save_dir_str:
        save_dir = Path.home() / "Downloads" / "ExtractedImages"
    else:
        save_dir = Path(save_dir_str).expanduser()
    
    try:
        save_dir.mkdir(parents=True, exist_ok=True)
    except Exception as e:
        print_error(f"Could not create save directory: {save_dir}")
        print_info(f"Please check permissions. Aborting. Error: {e}")
        return
    
    print_info(f"Save directory set: {save_dir}")
    print_info(f"Starting download from '{target_url}'...")
    print_info("This may take some time...")
    
    # 5. Execution
    wget_cmd = [
        "wget", "-r", "-l", "1", "-nd", "-np",
        "-A", "jpg,jpeg,png,gif",
        "-P", str(save_dir),
        target_url,
        "--quiet"
    ]
    
    try:
        subprocess.run(wget_cmd, check=True)
    except FileNotFoundError:
        print_error("`wget` command not found.") # Should be caught by check_dependency, but good to have
        return
    except subprocess.CalledProcessError as e:
        print_error(f"wget failed with return code {e.returncode}")
    
    # 6. Report results
    img_extensions = ["*.jpg", "*.jpeg", "*.png", "*.gif"]
    files_found = []
    for ext in img_extensions:
        files_found.extend(list(save_dir.glob(ext)))
    
    print_separator()
    if files_found:
        print_success(f"Download complete. Saved {len(files_found)} images to '{save_dir}'.")
    else:
        print_info("Scan complete. No images matching (jpg, jpeg, png, gif) were found on that page.")
        # Clean up the empty directory
        try:
            save_dir.rmdir()
        except OSError:
            pass  # Not empty, which is fine
    
    pause()

# --- 9. TarBall Mailer (Backup & Notify) ---
def run_tarball_mailer():
    print_header("TarBall Mailer (Backup & Notify)")
    
    # Python's shutil.make_archive replaces 'tar' dependency
    if not check_dependency("mail"):
        print_info("This tool uses 'mail' (from mailutils) to send email.")
        return
    
    src_dir_str = input("Enter the full path of the SOURCE directory to backup: ")
    dest_dir_str = input("Enter the full path of the DESTINATION directory for the backup: ")
    email_addr = input("Enter the email address for notification: ")

    src_dir = Path(src_dir_str).expanduser()
    dest_dir = Path(dest_dir_str).expanduser()

    if not src_dir.is_dir():
        print_error(f"Source directory '{src_dir}' does not exist. Aborting.")
        return
    
    email_regex = re.compile(r'^[^@]+@[^@]+\.[^@]+$')
    if not email_regex.match(email_addr):
        print_error("Invalid email address format. Aborting.")
        return
    
    try:
        dest_dir.mkdir(parents=True, exist_ok=True)
    except Exception as e:
        print_error(f"Could not create destination directory '{dest_dir}': {e}")
        return
    
    # 4. Prepare for archive
    src_folder_name = src_dir.name
    datestamp = datetime.now().strftime("%Y-%m-%d_%H%M%S")
    backup_basename = f"{src_folder_name}_{datestamp}"
    # Path without extension, shutil.make_archive adds it
    full_backup_path_base = dest_dir / backup_basename 
    
    print_info(f"Preparing to archive '{src_dir}'...")
    print_info(f"Target file: {full_backup_path_base}.tar.gz")
    
    try:
        # 5. Execution (Create Archive)
        archive_path = shutil.make_archive(
            base_name=str(full_backup_path_base),
            format="gztar",       # This creates a .tar.gz
            root_dir=src_dir.parent, # The directory to 'cd' into
            base_dir=src_folder_name # The folder to archive
        )
        
        print_success("Backup archive created successfully!")
        print_separator()
        print_info(f"Sending email notification to {email_addr}...")
        
        # 6. Send Email
        subject = f"[Backup SUCCESS] {src_folder_name}"
        body = f"""Backup of '{src_dir}' was successfully created.
        
File: {archive_path}
Host: {socket.gethostname()}
Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"""

        # Send the email
        subprocess.run(
            ["mail", "-s", subject, email_addr],
            input=body,
            text=True,
            check=True
        )
        print_success("Email notification sent.")
        
    except Exception as e:
        print_error(f"Archive creation or mail sending FAILED: {e}")
        # Clean up the failed archive if it exists
        failed_archive = Path(f"{full_backup_path_base}.tar.gz")
        if failed_archive.exists():
            failed_archive.unlink()
        
    pause()

# --- 10. Term/Phase Fetcher (grep wrapper) ---
def run_term_fetcher():
    print_header("Term/Phase Fetcher (grep)")
    
    if not check_dependency("grep"):
        return
    
    search_term = input("Enter the word or phrase to search for: ")
    search_dir_str = input("Enter directory to search in (default: current directory): ") or "."
    case_insensitive = input("Make search case-insensitive? (y/n): ").lower()

    if not search_term:
        print_error("No search term provided. Aborting.")
        return
    
    search_dir = Path(search_dir_str).expanduser()

    if not search_dir.is_dir():
        print_error(f"Directory '{search_dir}' does not exist. Aborting.")
        return
    
    # 4. Build 'grep' command options
    grep_cmd = ["grep", "-r", "-n", "-I", "--color=auto"]
    
    if case_insensitive == 'y':
        grep_cmd.append("-i")
        print_info("Running case-insensitive search...")
    else:
        print_info("Running case-sensitive search...")

    grep_cmd.extend([search_term, str(search_dir)])
    
    print_info(f"Searching for '{YELLOW}{search_term}{NC}' in '{search_dir}'...")
    print_separator()
    
    # 5. Execution
    # We run 'grep' and let it print directly to the terminal.
    # stderr=subprocess.DEVNULL suppresses permission denied errors.
    result = subprocess.run(grep_cmd, stderr=subprocess.DEVNULL)
    
    exit_code = result.returncode
    
    print_separator()
    
    if exit_code == 0:
        print_success("Search complete. Matches found.")
    elif exit_code == 1:
        print_info(f"Search complete. No matches found for '{search_term}'.")
    else:
        print_error("An error occurred during the search (e.g., permissions).")

    pause()

# --- 11. Network Diagnostic Tool ---
def run_network_diagnostics():
    print_header("Network Diagnostic Tool")
    
    if not all([check_dependency("ping"), check_dependency("ip"), check_dependency("nslookup")]):
        return
    
    domain = input("Enter a domain to test (default: google.com): ") or "google.com"
    
    print_info("Running 3-step network diagnostic...")
    print_separator()
    
    all_passed = True
    
    # Helper to run a silent ping
    def run_ping(target):
        try:
            result = subprocess.run(
                ["ping", "-c", "3", "-W", "2", target],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
            return result.returncode == 0
        except FileNotFoundError:
            return False # ping not found

    # --- Step 1: Test Gateway (Local Network) ---
    gateway_ip = ""
    try:
        ip_cmd = "ip route | grep default | awk '{print $3}'"
        result = subprocess.run(ip_cmd, shell=True, capture_output=True, text=True, check=True)
        gateway_ip = result.stdout.strip()
    except Exception as e:
        print_error(f"Could not determine gateway IP. Skipping Step 1. Error: {e}")
        all_passed = False
    
    if gateway_ip:
        print_info(f"Step 1/3: Pinging gateway ({gateway_ip})...")
        if run_ping(gateway_ip):
            print_success("  [PASS] Gateway is reachable.")
        else:
            print_error("  [FAIL] Gateway is NOT reachable.")
            all_passed = False
    
    # --- Step 2: Test Internet (External IP) ---
    print_info("Step 2/3: Pinging public DNS (8.8.8.8)...")
    if run_ping("8.8.8.8"):
        print_success("  [PASS] Public internet is reachable.")
    else:
        print_error("  [FAIL] Public internet is NOT reachable.")
        all_passed = False

    # --- Step 3: Test DNS (Name Resolution) ---
    print_info(f"Step 3/3: Resolving domain ({domain})...")
    try:
        # Run it silently first to check
        subprocess.run(["nslookup", domain], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        print_success("  [PASS] DNS resolution is working.")
        # Run it again so the user sees the output
        subprocess.run(["nslookup", domain])
    except (subprocess.CalledProcessError, FileNotFoundError):
        print_error("  [FAIL] DNS resolution FAILED.")
        all_passed = False
    
    print_separator()
    if all_passed:
        print_success("All network checks passed. Connectivity is good!")
    else:
        print_error("One or more network checks failed. Please review.")
    
    pause()

# --- 12. System Health Dashboard ---
def run_system_health():
    print_header("System Health Dashboard")
    
    if not all([check_dependency("free"), check_dependency("df"), check_dependency("uptime")]):
        return

    try:
        host = socket.gethostname()
    except Exception:
        host = "Unknown"
    
    # 2. Clear screen to create a "dashboard" effect
    os.system('clear')
    print_header(f"System Health Report for: {YELLOW}{host}{NC}")

    def run_tool(name, cmd_args):
        print(f"{CYAN}--- {name} ---{NC}")
        try:
            subprocess.run(cmd_args)
        except Exception as e:
            print_error(f"Failed to run '{' '.join(cmd_args)}': {e}")
        print("")

    # 3. Show Uptime & Load Average
    run_tool("Uptime & Load", ["uptime"])

    # 4. Show Memory Usage
    run_tool("Memory Usage", ["free", "-h"])
    
    # 5. Show Disk Usage
    run_tool("Filesystem Disk Usage", ["df", "-h", "-T", "--exclude-type=squashfs"])
    
    print_separator()
    pause()

# --- 13. Log File Analyzer ---
def run_log_analyzer():
    print_header("Log File Analyzer")
    
    if not all([check_dependency("grep"), check_dependency("tail")]):
        return
    
    log_file_str = input("Enter the full path to the log file (e.g., /var/log/syslog): ")
    keyword = input("Enter search term (e.g., ERROR, Failed, WARNING): ")
    line_count = input("How many recent lines to show? (default: 10): ") or "10"

    log_file = Path(log_file_str).expanduser()

    if not log_file.is_file():
        print_error(f"Log file not found: '{log_file}'. Aborting.")
        return
    
    if not keyword:
        print_error("No search term provided. Aborting.")
        return
    
    if not line_count.isdigit() or int(line_count) <= 0:
        print_error("Invalid input. Lines must be a positive number.")
        return
    
    print_info(f"Searching '{log_file}' for the {line_count} most recent lines containing '{YELLOW}{keyword}{NC}'...")
    print_separator()
    
    try:
        # 4. Execution
        # We build a pipe: grep ... | tail ...
        grep_cmd = ["grep", "-i", "-n", "--color=always", keyword, str(log_file)]
        tail_cmd = ["tail", "-n", line_count]
        
        # Start the first process (grep)
        ps1 = subprocess.Popen(grep_cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        
        # Start the second process (tail), taking input from the first
        # We must read the output as text (text=True)
        ps2 = subprocess.Popen(tail_cmd, stdin=ps1.stdout, stdout=subprocess.PIPE, text=True)
        
        # Allow ps1 to receive a SIGPIPE if ps2 exits
        ps1.stdout.close()
        
        # Get the final output from ps2
        output, _ = ps2.communicate()
        
        # 5. Report Results
        if not output.strip():
            print_info("Search complete. No matches found.")
        else:
            print(output)
            print_separator()
            print_success("Search complete. Showing most recent matches.")
            
    except Exception as e:
        print_error(f"An error occurred during log analysis: {e}")
    
    pause()

# =============================================================================
# MAIN MENU & SCRIPT LOGIC CENTER (The Engine)
# =============================================================================

def show_main_menu():
    """Displays the main menu."""
    os.system('clear')  # Clear the screen

    # Python raw string (r"""...""") preserves the ASCII art
    print(fr"""{GREEN}
++======================================================================++
| ╔═╗╔═╗╔═══╗╔═╗ ╔╗╔═══╗╔╗╔═══╗     ╔════╗╔═══╗╔═══╗╔╗   ╔╗╔═╗╔══╗╔════╗ |
| ╚╗╚╝╔╝║╔══╝║║╚╗║║║╔═╗║║║║╔═╗║     ║╔╗╔╗║║╔═╗║║╔═╗║║║   ║║║╔╝╚╣╠╝║╔╗╔╗║ |
|  ╚╗╔╝ ║╚══╗║╔╗╚╝║║║ ║║╚╝║╚══╗     ╚╝║║╚╝║║ ║║║║ ║║║║   ║╚╝╝  ║║ ╚╝║║╚╝ |
|  ╔╝╚╗ ║╔══╝║║╚╗║║║║ ║║  ╚══╗║       ║║  ║║ ║║║║ ║║║║ ╔╗║╔╗║  ║║   ║║   |
| ╔╝╔╗╚╗║╚══╗║║ ║║║║╚═╝║  ║╚═╝║      ╔╝╚╗ ║╚═╝║║╚═╝║║╚═╝║║║║╚╗╔╣╠╗ ╔╝╚╗  |
| ╚═╝╚═╝╚═══╝╚╝ ╚═╝╚═══╝  ╚═══╝      ╚══╝ ╚═══╝╚═══╝╚═══╝╚╝╚═╝╚══╝ ╚══╝  |
|                           PYTHON EDITION                               |
++======================================================================++
""")

    print(f"{CYAN}Select an option to proceed:{NC}")
    print("")
    print("1. Folder Organizer")
    print("2. Password Generator")
    print("3. Curf Remover (Safe File Cleaner)")
    print("4. User Creation")
    print("5. Indexer (Batch File Renamer)")
    print("6. CSV Calculator")
    print("7. Service Manager")
    print("8. Online Image Extractor")
    print("9. TarBall Mailer")
    print("10. Term/Phase Fetcher")
    print("11. Network Diagnostic Tool")
    print("12. System Health Dashboard")
    print("13. Log File Analyzer")
    print("")
    print(f"{RED}q. Quit{NC}")
    print_separator()

def main():
    """Main loop for the toolkit."""
    
    # Map choices to their respective functions
    menu_options = {
        "1": run_folder_organizer,
        "2": run_password_generator,
        "3": run_curf_remover,
        "4": run_user_creator,
        "5": run_indexer,
        "6": run_csv_calculator,
        "7": run_service_manager,
        "8": run_image_extractor,
        "9": run_tarball_mailer,
        "10": run_term_fetcher,
        "11": run_network_diagnostics,
        "12": run_system_health,
        "13": run_log_analyzer,
    }

    while True:
        show_main_menu()
        choice = input("Enter your choice: ").strip()
        
        if choice.lower() == 'q':
            print("Ending Process!")
            break
        
        # Get the function from the dictionary
        action = menu_options.get(choice)
        
        if action:
            try:
                # Call the chosen function
                action()
            except KeyboardInterrupt:
                print_error("\nOperation cancelled by user.")
                pause()
            except Exception as e:
                print_error(f"An unexpected error occurred in {action.__name__}: {e}")
                pause()
        else:
            print_error(f"Invalid option '{choice}'. Please try again.")
            time.sleep(2)

# --- Script Entry Point ---
if __name__ == "__main__":
    main()

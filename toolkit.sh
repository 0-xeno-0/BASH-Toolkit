#!/bin/bash
#
#Author: ABHISHEK KISHOR SINGH
#Created Date:28/02/2023
#Last Modified Date:28/01/2024
#
#Description: It is a interactive tool-kit hold some manual tasks automated via BASH scripts.
#
#Usage Information: After adding the absolute path for your executables, you will be able to call all your functionalities from within the toolkit itself without having to switch to multiple executables multiple times. This will save you time and effort, as you can perform all your desired tasks seamlessly within the same interface.

PS3="  
++======================================================================++
| ╔═╗╔═╗╔═══╗╔═╗ ╔╗╔═══╗╔╗╔═══╗     ╔════╗╔═══╗╔═══╗╔╗   ╔╗╔═╗╔══╗╔════╗ |
| ╚╗╚╝╔╝║╔══╝║║╚╗║║║╔═╗║║║║╔═╗║     ║╔╗╔╗║║╔═╗║║╔═╗║║║   ║║║╔╝╚╣╠╝║╔╗╔╗║ |
|  ╚╗╔╝ ║╚══╗║╔╗╚╝║║║ ║║╚╝║╚══╗     ╚╝║║╚╝║║ ║║║║ ║║║║   ║╚╝╝  ║║ ╚╝║║╚╝ |
|  ╔╝╚╗ ║╔══╝║║╚╗║║║║ ║║  ╚══╗║       ║║  ║║ ║║║║ ║║║║ ╔╗║╔╗║  ║║   ║║   |
| ╔╝╔╗╚╗║╚══╗║║ ║║║║╚═╝║  ║╚═╝║      ╔╝╚╗ ║╚═╝║║╚═╝║║╚═╝║║║║╚╗╔╣╠╗ ╔╝╚╗  |
| ╚═╝╚═╝╚═══╝╚╝ ╚═╝╚═══╝  ╚═══╝      ╚══╝ ╚═══╝╚═══╝╚═══╝╚╝╚═╝╚══╝ ╚══╝  |
++======================================================================++

[+]
[+] Select the appropiate option to execute action:"

select var1 in "Folder Organizer" "Curf Remover" "Password Generator" "User Creator" "Indexer" "CSV Calculator" "Service Validator" "Online Image Extractor" "TarBall Mailer" "Term/Phase Fetcher";
#--------------------------------------------------------------------------------------------
do
case "$var1" in 
	"Folder Organizer")
	read -p "Enter the folders absolute path to organize:" organizerPath

while read var2; do
  case "$var2" in
    *.jpg | *.jpeg | *.png) 
      if [ -d ~/MyShebangs/images ]; then
        mv "$var2" ~/MyShebangs/images
      else
        mkdir ~/MyShebangs/images
        mv "$var2" ~/MyShebangs/images
      fi
      ;;
    *.doc | *.docx | *.txt | *.pdf)
      if [ -d ~/MyShebangs/documents ]; then
        mv "$var2" ~/MyShebangs/documents
      else
        mkdir ~/MyShebangs/documents
        mv "$var2" ~/MyShebangs/documents
      fi
      ;;
    *.xls | *.xlsx | *.csv)
      if [ -d ~/MyShebangs/spreadsheets ]; then
        mv "$var2" ~/MyShebangs/spreadsheets
      else
        mkdir ~/MyShebangs/spreadsheets
        mv "$var2" ~/MyShebangs/spreadsheets
      fi
      ;;
    *.sh)
      if [ -d ~/MyShebangs/scripts ]; then
        mv "$var2" ~/MyShebangs/scripts
      else
        mkdir ~/MyShebangs/scripts
        mv "$var2" ~/MyShebangs/scripts
      fi
      ;;
    *.zip | *.tar | *.tar.gz | *.tar.bz2)
      if [ -d ~/MyShebangs/archives ]; then
        mv "$var2" ~/MyShebangs/archives
      else
        mkdir ~/MyShebangs/archives
        mv "$var2" ~/MyShebangs/archives
      fi
      ;;
    *.ppt | *.pptx)
      if [ -d ~/MyShebangs/presentations ]; then
        mv "$var2" ~/MyShebangs/presentations
      else
        mkdir ~/MyShebangs/presentations
        mv "$var2" ~/MyShebangs/presentations
      fi
      ;;
    *.mp3)
      if [ -d ~/MyShebangs/audio ]; then
        mv "$var2" ~/MyShebangs/audio
      else
        mkdir ~/MyShebangs/audio
        mv "$var2" ~/MyShebangs/audio
      fi
      ;;
    *.mp4)
      if [ -d ~/MyShebangs/video ]; then
        mv "$var2" ~/MyShebangs/video
      else
        mkdir ~/MyShebangs/video
        mv "$var2" ~/MyShebangs/video
      fi
      ;;
    *)
      echo "$var2" >> ~/MyShebangs/specialFiles.list
      ;;
  esac
done < <(ls "$organizerPath")

echo "Please visit your home directory for MyShebangs folder for organized folders and list of special files";;
#--------------------------------------------------------------------------------------------
	"Curf Remover")
	read -p "This script will help you free up space in a given folder by removing any files that haven't been modified in the past 15 days. You can use the built-in functionality to retain files that you consider important. Please provide the absolute path to the folder you want to clean up, e.g. /home/user/Dump, where "Dump" is the name of the folder you want to clean up, located in your home directory. 

	Note: This script will permanently delete files. Make sure you have backed up any important files before running this script. 

	Are you sure you want to proceed?

	If yes please enter the absolute path of the folder or terminate the script by pressing ctrl+c: " curfPath
	if [ -n "$curfPath" ];then
    	find "$curfPath" -type f,d -mtime 15 > curf
    	readarray -t Curf < "curf"
    	echo "The curf has been gathered"
    	read -p "To remove the files interactively press Y else N to remove all the curfs silently" input1
    	case "$input1" in 
        Y|y) rm -ir "${Curf[@]}" ;;
        N|n) rm -r "${Curf[@]}" ;;
        *) echo "Invalid Option" ;;
    	esac
	else
    	echo "Not a valid path"
	fi;;
#--------------------------------------------------------------------------------------------
	"Password Generator")
	# Set the length of the password
	read -n 5 -p "Set the length of the password: " length
	if [ -z "$length" ]
	then
    	echo "Length not specified setting it to default size 12 characters"
    	length=12
	else
    	echo "Password length will be $length"
	fi

	# Generate a random password
	password=$(head /dev/urandom | tr -dc 'A-Za-z0-9!@#$%^&*' | head -c $length)

	# Set the name of the file to save the password to
	filename="password.txt"

	# Save the password to a file
	echo "$password" > "$filename"

	# Display the password to the user
	echo "Your new password is: $password";;
#--------------------------------------------------------------------------------------------
	"User Creator")
	# Prompt the user for the username to create
	echo "Enter the username to create: "
	read username

	# Create the new user account
	adduser "$username"

	# Set the password for the new user account
	passwd "$username"

	# Print a message indicating the account creation is complete
	echo "User account created: $username";;
#--------------------------------------------------------------------------------------------
	"Indexer")
	# Set the name of the directory containing the files to rename
	directory="myfiles"

	# Change to the directory containing the files
	cd "$directory"

	# Set the starting number for the sequential numbering scheme
	i=1

	# Rename each file in the directory to a sequential numbering scheme
	for file in *; do
    	# Rename the file using the sequential numbering scheme
    	mv -- "$file" "$(printf 'file%03d.txt' $i)"
    	i=$((i+1))
	done;;
#--------------------------------------------------------------------------------------------
	"CSV Calculator")
	# Set the name of the CSV file to parse
	csv_file="data.csv"

	# Parse the CSV file and perform calculations
	while IFS=',' read -r col1 col2 col3 col4; do
    	# Perform calculations on the data
    	sum=$(echo "$col3 + $col4" | bc)
    	avg=$(echo "scale=2; $sum / 2" | bc)

    	# Print the results to the console
    	echo "Name: $col1"
    	echo "ID: $col2"
    	echo "Total: $sum"
    	echo "Average: $avg"
    	echo ""
	done < "$csv_file";;
#--------------------------------------------------------------------------------------------
	"Service Validator")
	# Set the name of the service to check and restart
	service_name="myservice"

	# Check the status of the service
	if systemctl is-active "$service_name" >/dev/null 2>&1; then
    	# Service is running, print a message indicating the status
    	echo "$service_name is running."
	else
    	# Service is not running, print a message indicating the status and restart the service
    	echo "$service_name is not running, restarting..."
    	systemctl start "$service_name"
	fi;;
#--------------------------------------------------------------------------------------------
	"Online Image Extractor")
# Set the website URL to download images from
website_url="https://example.com"

# Set the directory to save downloaded images
image_directory="/path/to/image/directory"

# Create the image directory if it doesn't exist
mkdir -p "$image_directory"

# Download all images from the website and save them to the image directory
wget -nd -r -P "$image_directory" -A jpg,jpeg,png,gif "$website_url"

# Print a message indicating the download is complete
echo "Image download complete: $image_directory";;
#--------------------------------------------------------------------------------------------
	"TarBall Mailer" )
# Set the source directory to backup
source_directory="/path/to/source/directory"

# Set the target directory for the backup
backup_directory="/path/to/backup/directory"

# Set the name of the backup archive
backup_filename="backup_$(date +%Y%m%d_%H%M%S).tar.gz"

# Create the backup directory if it doesn't exist
mkdir -p "$backup_directory"

# Create the backup archive
tar -czf "$backup_directory/$backup_filename" "$source_directory"

# Print a message indicating the backup is complete
echo "Backup complete: $backup_directory/$backup_filename"

if [-z $email_address_cache]; then
echo "Please enter the mail address to be mailed."
read email_address
fi

# Set the email address to send the notification to
email_address_cache=$email_address

echo "Tar archive created successfully. Sending email notification."
        echo "Subject: Backup/Tar archive." | mail -s "Log file error notification" "$email_address_cache";;
#--------------------------------------------------------------------------------------------
	"Term/Phase Fetcher")
# Prompt the user for the word or phrase to search for
echo "Enter the word or phrase to search for: "
read search_term

# Prompt the user for the directory to search in
echo "Enter the directory to search in: "
read directory

# Search for the word or phrase in the specified directory and its subdirectories
grep -r "$search_term" "$directory";;
#--------------------------------------------------------------------------------------------
break
done

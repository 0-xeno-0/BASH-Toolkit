# BASH-Toolkit: A Multi-Tool Utility Script

This is an interactive, menu-driven BASH script that consolidates 13+ common IT support and system administration tasks into a single, user-friendly utility.
It is also available in form of a python script.
This project was built with a focus on professional development practices, including robust error handling, input validation, dependency checking, and a clean, color-coded user interface.

---

### 🛠️ Features

This toolkit includes:
1.  **Folder Organizer:** Safely sorts files in a directory into subfolders by type (images, docs, etc.).
2.  **Password Generator:** Creates a secure, randomized password of a specified length.
3.  **Curf Remover (Safe File Cleaner):** Finds and safely deletes files/empty folders older than a specified number of days, with a "dry run" and interactive confirmation.
4.  **User Creator:** A `sudo`-aware utility to safely add new users to the system.
5.  **Indexer (Batch File Renamer):** Safely renames all files in a directory with a specified prefix, *while preserving file extensions*.
6.  **CSV Calculator:** Parses a simple CSV file to perform calculations.
7.  **Service Manager (systemd):** A `sudo`-aware utility to check the status of a `systemd` service and offer to start/stop/restart it.
8.  **Online Image Extractor:** Downloads all images (jpg, png, etc.) from a given URL.
9.  **TarBall Mailer:** Backs up a directory into a `.tar.gz` archive and sends an email notification.
10. **Term/Phase Fetcher:** A user-friendly wrapper for `grep` to find text in files recursively.
11. **Network Diagnostic Tool:** A 3-step troubleshooter that checks the gateway, internet, and DNS.
12. **System Health Dashboard:** A read-only screen showing system load, memory, and disk space.
13. **Log File Analyzer:** Finds the *most recent* error/warning lines from a specified log file.

---

### 🚀 How to Use in BASH Shell

1.  **Clone the repository (or download the script):**
    ```bash
    git clone [https://github.com/0-xeno-0/BASH-Toolkit.git](https://github.com/0-xeno-0/BASH-Toolkit.git)
    cd BASH-Toolkit
    ```
2.  **Make the script executable (one time only):**
    ```bash
    chmod +x toolkit.sh
    ```
3.  **Run the script:**
    ```bash
    ./toolkit.sh
    ```

### 🚀 How to Use in Python Shell

1.  **Clone the repository (or download the script):**
    ```bash
    git clone [https://github.com/0-xeno-0/BASH-Toolkit.git](https://github.com/0-xeno-0/BASH-Toolkit.git)
    cd BASH-Toolkit
    ```
2.  **Make the script executable (one time only):**
    ```bash
    chmod +x toolkit.py
    ```
3.  **Run the script:**
    ```bash
    python3 toolkit.py
    ```
    *Note: Some features (like "User Creator" and "Service Manager") require `sudo` privileges to run. Launch the script with `sudo ./toolkit.sh` to use them.*

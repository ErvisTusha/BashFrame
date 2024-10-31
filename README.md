# BashFrame

[![Version](https://img.shields.io/badge/version-1.5.1-blue.svg)](https://github.com/ErvisTusha/BashFrame)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/bash-5.0%2B-orange.svg)](https://www.gnu.org/software/bash/)

A comprehensive framework for Bash script development, offering robust utility functions and standardized scripting patterns.

## Overview

BashFrame is a powerful Bash scripting framework that provides a structured approach to script development. It includes a comprehensive suite of utility functions for common operations, robust error handling, and detailed logging capabilities.

## Key Features

- **Privilege Management**: Secure user privilege verification and management
- **System Operations**: Efficient tool verification and installation handling
- **File Operations**: Comprehensive file and directory management utilities
- **Input Validation**: Robust validation for emails, URLs, IPs, and MAC addresses
- **Network Operations**: Functions for network-related tasks and IP management
- **Logging System**: Detailed logging with multiple severity levels
- **String Operations**: Advanced string manipulation and generation utilities

## Installation

### Author Information
**Ervis Tusha**  
[GitHub](https://github.com/ErvisTusha)  
[Twitter](https://X.com/ET)  
[LinkedIn](https://linkedin.com/in/ErvisTusha)  
[E-mail](mailto:ervistusha@gmail.com)

### Features

1. **User Privilege Checks**: Verify if the user has root or sudo privileges.
2. **Tool Verification**: Determine if specific tools are installed on the system.
3. **File Downloading**: Download files using `wget`, `curl`, or `python`.
4. **Input Validation**: Validate inputs such as emails, URLs, IP addresses, and MAC addresses.
5. **Logging**: Record actions for debugging and monitoring purposes.
6. **Extensive Utility Functions**: A collection of additional functions to enhance script functionality.

### List of Functions
| Function | Description |
| --- | --- |
| **IS_SUDO** | Check if the user has root or sudo privileges. |
| **HAS_SUDO** | Check if the user has sudo privileges without prompting. |
| **IS_INSTALLED** | Check if a specific tool is installed. |
| **INSTALL_SCRIPT** | Install the script to a specified directory. |
| **UNINSTALL_SCRIPT** | Uninstall the script. |
| **UPDATE** | Update the script to its latest version. |
| **DOWNLOAD** | Download files using wget, curl, or python. |
| **ASK_USER** | Interactively ask the user a question with a Yes/No response. |
| **IS_EMPTY** | Check if a given variable is empty. |
| **IS_NUMBER** | Check if a given variable is numeric. |
| **VAL_EMAIL** | Validate if a value is a proper email address. |
| **VAL_URL** | Validate if a value is a proper URL. |
| **VAL_IP** | Validate if a value is a proper IPv4 address. |
| **VAL_IPV6** | Validate if a value is a proper IPv6 address. |
| **VAL_MACADDR** | Validate if a value is a proper MAC address. |
| **FILE_EXISTS** | Check if a specified file exists. |
| **DIR_EXISTS** | Check if a specified directory exists. |
| **FILE_EMPTY** | Check if a specified file is empty. |
| **DIR_EMPTY** | Check if a specified directory is empty. |
| **IS_WRITABLE** | Check if a file or directory is writable. |
| **IS_READABLE** | Check if a file or directory is readable. |
| **IS_EXECUTABLE** | Check if a file is executable. |
| **IS_OWNED_BY_USER** | Check if a file or directory is owned by a specific user. |
| **IS_OWNED_BY_GROUP** | Check if a file or directory is owned by a specific group. |
| **IS_OLDER_THAN** | Check if a file is older than a specified number of days. |
| **CHECK_PERMISSIONS** | Check if file permissions match expected permissions. |
| **LOG** | Log messages to a specified log file. |
| **GENERATE_RANDOM** | Generate a random string based on criteria. |
| **STRING_LENGTH** | Determine the length of a given string. |
| **GET_PUBLIC_IP** | Retrieve the public IP address of the machine. |
| **GET_LOCAL_IP** | Retrieve the local IP address of the machine. |
| **GET_MACADDR** | Retrieve the MAC address of the machine. |

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/ErvisTusha/BashFrame.git
   cd BashFrame
   ```

2. Source the `bashframe.sh` script in your script:
   ```bash
   source /path/to/bashframe.sh
   ```

## Core Functions

BashFrame provides a multitude of functions, each designed for specific purposes. Below are examples of some primary functions and their usage:

1. **IS_SUDO**: Check if the user has root or sudo privileges.
   ```bash
   if IS_SUDO; then
       echo "User has root privileges."
   else
       echo "User does not have root privileges."
   fi
   ```
2. **IS_INSTALLED**: Check if a specific tool is installed.
   ```bash
   if IS_INSTALLED "wget"; then
       echo "wget is installed."
   else
       echo "wget is not installed."
   fi
   ```
3. **DOWNLOAD**: Download a file using available download methods.
   ```bash
   DOWNLOAD "https://example.com/file.txt" "/tmp/file.txt"
   ```
4. **LOG**: Log a message with a specified status to a file.
   ```bash
   LOG "INFO" "This is a log message." "/path/to/logfile.log"
   ```

### Logging

Logs are stored in `/tmp/log/[SCRIPT_NAME].log` by default. You can specify a different log file by setting the `LOG_FILE` variable in your script.

### License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Contributing
For those interested in contributing, feel free to raise issues or make pull requests.

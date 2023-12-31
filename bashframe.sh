#!/bin/bash
######################################################################
# Author: Ervis Tusha                                                #
# Email: ERVISTUSHA[at]GMAIL.COM                                     #
# Github: Github: https://github.com/ErvisTusha                      #
# Twitter: https://X.com/ET                                          #
# LinkedIn: https://linkedin.com/in/ErvisTusha                       #
# License: MIT LICENSE                                               #
######################################################################
#                           BashFrame 1.0.1                          #
######################################################################
# BashFrame is a bash script that provides a framework for creating and managing bash scripts.
# It includes functions for checking if the user has root or sudo privileges, checking if a tool is installed,
# downloading files, installing, uninstalling, and updating scripts, and asking the user questions.
# The script is designed to be used as a template for creating new bash scripts.
######################################################################

# Function to check if the user has root or sudo privileges
IS_SUDO() {
    if [[ $EUID -eq 0 ]]; then
        LOG "User has root privileges"
        return 0 # User has root privileges
    fi
    LOG "User does not have root privileges"
    return 1 # User does not have root privileges
}
# Example usage of IS_SUDO:
# IS_SUDO && echo "User has root privileges"
# if IS_SUDO; then
#     echo "User has root privileges"
# else
#     echo "User does not have root privileges"
# fi

# Function to check if a tool is installed
IS_INSTALLED() {
    local TOOL=$1
    if command -v $TOOL >/dev/null 2>&1; then
        LOG "$TOOL is installed"
        return 0 # Tool is installed
    fi
    LOG "$TOOL is not installed"
    return 1 # Tool is not installed
}
# Example usage of IS_INSTALLED:
# IS_INSTALLED "wget" && echo "wget is installed"
# if IS_INSTALLED "wget"; then
#     echo "wget is installed"
# else
#     echo "wget is not installed"
# fi

# Function to download files
DOWNLOAD() {
    local URL=$1
    local OUTPUT=$2

    # Check if URL is valid
    if ! VAL_URL "$URL"; then
        echo "Error: Invalid URL"
        exit 1
    fi

    # if wget is installed then use wget else use curl or python
    if IS_INSTALLED "wget"; then
        wget -q --show-progress "$URL" -O "$OUTPUT"
    elif IS_INSTALLED "curl"; then
        curl -s -L "$URL" -o "$OUTPUT"
    elif IS_INSTALLED "python"; then
        # Fixme: Check python version and use appropriate method
        if python -c 'import sys; exit(0 if sys.version_info.major == 2 else 1)'; then
            python -c "import urllib; urllib.urlretrieve('$URL', '$OUTPUT')"
        else
            python -c "import urllib.request; urllib.request.urlretrieve('$URL', '$OUTPUT')"
        fi
    else
        echo "Error: wget, curl, or python is required to download files"
        LOG "wget, curl, or python is required to download files"
        exit 1
    fi
}
# Example usage of DOWNLOAD:
# DOWNLOAD "https://example.com/file.txt" "output.txt"

# Function to install the script
INSTALL() {
    # Check if the user has root or sudo privileges
    IS_SUDO
    # If script is already installed, ask the user if they want to update it, else exit
    if IS_INSTALLED "$SCRIPT"; then
        echo "$SCRIPT_NAME is already installed"
        # Ask the user if they want to update the script else exit
        if ASK_USER "Do you want to update the $SCRIPT_NAME?"; then
            LOG "User chose to update the $SCRIPT_NAME"
            UPDATE
        else
            LOG "User chose not to update the $SCRIPT_NAME"
            echo "Exiting..."
            exit 0
        fi
    fi
    # Copy the script to /usr/local/bin
    cp "$0" /usr/local/bin/$SCRIPT
    # Make the script executable
    chmod +x /usr/local/bin/$SCRIPT
    echo "$SCRIPT_NAME installed successfully"
    # Print the version
    echo "$SCRIPT_NAME version $VERSION"
    exit 0
}
# Example usage of INSTALL:
# INSTALL

# Function to uninstall the script
UNINSTALL() {
    # Check if the user has root or sudo privileges
    IS_SUDO

    # If script is not installed, exit
    if ! IS_INSTALLED "$SCRIPT"; then
        echo "$SCRIPT_NAME is not installed"
        LOG "Uninstall:  $SCRIPT_NAME is not installed"
        exit 1
    fi

    # Ask the user if they want to uninstall the script, else exit
    if ! ASK_USER "Do you want to uninstall the $SCRIPT_NAME?"; then
        LOG "Uninstall: User chose not to uninstall the $SCRIPT_NAME"
        echo "Exiting..."
        exit 0
    fi
    # Remove /usr/local/bin/$SCRIPT
    rm /usr/local/bin/$SCRIPT
    echo "$SCRIPT_NAME uninstalled successfully"
    exit 0
}
# Example usage of UNINSTALL:
# UNINSTALL

# Function to update the script
UPDATE() {
    # Download VERSION from GitHub
    # Check if the user has root or sudo privileges
    IS_SUDO
    # If script is not installed, ask the user if they want to install it, else exit
    if ! IS_INSTALLED "$SCRIPT"; then
        echo "$SCRIPT_NAME is not installed"
        LOG "Update: $SCRIPT_NAME is NOT installed"
        # Ask the user if they want to install the script else exit
        if ASK_USER "Do you want to install the $SCRIPT_NAME?"; then
            LOG "Update: User chose to install the $SCRIPT_NAME"
            INSTALL
        else
            LOG "Update: User chose NOT to install the $SCRIPT_NAME"
            echo "Exiting..."
            exit 0
        fi
    fi

    # Download the latest version from GitHub to /tmp
    echo "Downloading the latest version..."
    DOWNLOAD "$SCRIPT_URL" /tmp/$SCRIPT
    # Check if the download was successful
    if ! [ $? -eq 0 ]; then
        echo "Error: Failed to download the latest version"
        LOG "Update: Failed to download the latest version"
        exit 1
    fi
    # Check if the downloaded file is empty
    if FILE_EMPTY "/tmp/$SCRIPT"; then
        echo "Error: Failed to download the latest version"
        LOG "Update: Failed to download the latest version"
        exit 1
    fi
    # Grep the version from the downloaded file
    NEW_VERSION=$(grep "VERSION=\"[0-9.]*\"" /tmp/$SCRIPT -m 1 | cut -d "=" -f 2 | tr -d '"')
    LOG "Update: New version is $NEW_VERSION"
    # Compare the two versions
    if [[ "$NEW_VERSION" == "$VERSION" ]]; then
        echo "You already have the latest version"
        # Ask the user if they want to reinstall the script else exit
        if ASK_USER "Do you want to reinstall the $SCRIPT_NAME?"; then
            LOG "Update: User chose to reinstall the $SCRIPT_NAME"
            #FIXME: INSTALL
        else
            LOG "Update: User chose NOT to reinstall the $SCRIPT_NAME"
            echo "Exiting..."
            exit 0
        fi
    fi
    # Copy the downloaded file to /usr/local/bin/$SCRIPT
    cp /tmp/$SCRIPT /usr/local/bin/$SCRIPT
    # Make the script executable
    chmod +x /usr/local/bin/$SCRIPT
    echo "$SCRIPT_NAME updated successfully"
    # Print the new version
    echo "$SCRIPT_NAME new version is $NEW_VERSION"
    LOG "Update: $SCRIPT_NAME new version is $NEW_VERSION"
    exit 0
}
# Example usage of UPDATE:
# UPDATE

# Function to ask the user questions answer yes or no
ASK_USER() {
    local QUESTION=$1
    local ANSWER
    while true; do
        read -p "$QUESTION [Y/n]: " -n 1 -r ANSWER
        echo ""
        case $ANSWER in
        [Yy] | "")
            return 0
            ;;
        [Nn])
            return 1
            ;;
        *)
            echo "Invalid input"
            ;;
        esac
    done
    LOG "User answered $ANSWER to $QUESTION"
}
# Example usage of ASK_USER:
# ASK_USER "Do you want to continue?" && echo "User answered yes"
# ! ASK_USER "Do you want to continue?" && echo "User answered no"
# if ASK_USER "Do you want to continue?"; then
#     echo "User answered yes"
# else
#     echo "User answered no"
# fi

# Function to check if a variable is empty
IS_EMPTY() {
    [[ -z $1 ]]
}
# Example usage of IS_EMPTY:
# IS_EMPTY "$VARIABLE" && echo "Variable is empty"
# ! IS_EMPTY "$VARIABLE" && echo "Variable is not empty"
# if IS_EMPTY "$VARIABLE"; then
#     echo "Variable is empty"
# else
#     echo "Variable is not empty"
# fi

# Function to check if a variable is a number
IS_NUMBER() {
    [[ $1 =~ ^[0-9]+$ ]]
}
# Example usage of IS_NUMBER:
# IS_NUMBER "$VARIABLE" && echo "Variable is a number"
# ! IS_NUMBER "$VARIABLE" && echo "Variable is not a number"
# if IS_NUMBER "$VARIABLE"; then
#     echo "Variable is a number"
# else
#    echo "Variable is not a number"
# fi

# Function to check if a variable is a string
IS_STRING() {
    [[ $1 =~ ^[a-zA-Z]+$ ]]
}
# Example usage of IS_STRING:
# IS_STRING "$VARIABLE" && echo "Variable is a string"
# ! IS_STRING "$VARIABLE" && echo "Variable is not a string"
# if IS_STRING "$VARIABLE"; then
#     echo "Variable is a string"
# else
#    echo "Variable is not a string"
# fi

# Function to check if a variable is a valid email address
VAL_EMAIL() {
    [[ $1 =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}
# Example usage of VAL_EMAIL:
# VAL_EMAIL "$VARIABLE" && echo "Variable is a valid email address"
# ! VAL_EMAIL "$VARIABLE" && echo "Variable is not a valid email address"
# if VAL_EMAIL "$VARIABLE"; then
#     echo "Variable is a valid email address"
# else
#    echo "Variable is not a valid email address"
# fi

# Function to check if a variable is a valid URL
VAL_URL() {
    [[ $1 =~ ^https?:// ]]
}
# Example usage of VAL_URL:
# VAL_URL "$VARIABLE" && echo "Variable is a valid URL"
# ! VAL_URL "$VARIABLE" && echo "Variable is not a valid URL"
# if VAL_URL "$VARIABLE"; then
#     echo "Variable is a valid URL"
# else
#   echo "Variable is not a valid URL"
# fi

# Function to check if a variable is a valid IPv4 address
VAL_IP() {
    [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
}
# Example usage of VAL_IP:
# VAL_IP "$VARIABLE" && echo "Variable is a valid IPv4 address"
# ! VAL_IP "$VARIABLE" && echo "Variable is not a valid IPv4 address"
# if VAL_IP "$VARIABLE"; then
#     echo "Variable is a valid IPv4 address"
# else
#   echo "Variable is not a valid IPv4 address"
# fi

# Function to check if a variable is a valid IPv6 address
VAL_IPV6() {
    [[ $1 =~ ^([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}$ ]]
}
# Example usage of VAL_IPV6:
# VAL_IPV6 "$VARIABLE" && echo "Variable is a valid IPv6 address"
# ! VAL_IPV6 "$VARIABLE" && echo "Variable is not a valid IPv6 address"
# if VAL_IPV6 "$VARIABLE"; then
#     echo "Variable is a valid IPv6 address"
# else
#   echo "Variable is not a valid IPv6 address"
# fi

# Function to check if a variable is a valid MAC address
VAL_MACADDR() {
    [[ $1 =~ ^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$ ]]
}
# Example usage of VAL_MACADDR:
# VAL_MACADDR "$VARIABLE" && echo "Variable is a valid MAC address"
# ! VAL_MACADDR "$VARIABLE" && echo "Variable is not a valid MAC address"
# if VAL_MACADDR "$VARIABLE"; then
#     echo "Variable is a valid MAC address"
# else
#   echo "Variable is not a valid MAC address"
# fi

# Function to log messages to /tmp/$SCRIPT.log
LOG() {
    local MESSAGE=$1
    local TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    mkdir -p /tmp/log
    echo "[$TIMESTAMP] $MESSAGE" >>/tmp/log/$SCRIPT.log
}
# Example usage of LOG:
# LOG "This is a log message"

# Function to check if file permissions match the expected permissions
CHECK_PERMISSIONS() {
    local FILEPATH=$1
    local EXPECTED_PERMISSIONS=$2

    if ! FILE_EXISTS "$FILEPATH"; then
        LOG "File $FILEPATH does NOT exist"
        return 1
    fi

    local CURRENT_PERMISSIONS=$(stat -c "%a" $FILEPATH)
    if [[ $CURRENT_PERMISSIONS == $EXPECTED_PERMISSIONS ]]; then
        LOG "Permissions for $FILEPATH are as expected"
        return 0
    fi
    LOG "Permissions for $FILEPATH are $CURRENT_PERMISSIONS, expected $EXPECTED_PERMISSIONS"
    return 1

}
# Example usage of CHECK_PERMISSIONS:
# CHECK_PERMISSIONS "/etc/passwd" "644" && echo "Permissions match"
# ! CHECK_PERMISSIONS "/etc/passwd" "644" && echo "Permissions do not match"
# if CHECK_PERMISSIONS "/etc/passwd" "644"; then
#     echo "Permissions match"
# else
#     echo "Permissions do not match"
# fi

# Function to generate a random string
GENERATE_RANDOM() {
    local LENGTH=$1
    local TYPE=$2
    local RESULT=""

    case "$TYPE" in
    1 | "numbers")
        CHARS='0123456789'
        ;;
    2 | "characters")
        CHARS='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
        ;;
    3 | "mixed")
        CHARS='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
        ;;
    *)
        LOG "GENERATE_RANDOM: Invalid type $TYPE"
        return 1
        ;;
    esac

    for i in $(seq 1 $LENGTH); do
        RESULT="${RESULT}${CHARS:RANDOM%${#CHARS}:1}"
    done

    LOG "GENERATE_RANDOM: Generated $LENGTH random $TYPE: $RESULT"
    echo $RESULT
}

# Example usage of GENERATE_RANDOM:
# random_number=$(GENERATE_RANDOM 10 "numbers")
# random_characters=$(GENERATE_RANDOM 10 "characters")
# random_mixed=$(GENERATE_RANDOM 10 "mixed")

# Function to check if a file or directory exists
FILE_EXISTS() {
    local FILE=$1
    if [ -e "$FILE" ]; then
        LOG "FILE_EXISTS: File $FILE exists"
        return 0 # File exists
    else
        LOG "FILE_EXISTS: File $FILE does NOT exist"
        return 1 # File does not exist
    fi
}
# Example usage of FILE_EXISTS:
# FILE_EXISTS "/etc/passwd" && echo "File exists"
# ! FILE_EXISTS "/etc/passwd" && echo "File does not exist"
# if FILE_EXISTS "/etc/passwd"; then
#     echo "File exists"
# else
#     echo "File does not exist"
# fi

# Function to check if a directory exists
DIR_EXISTS() {
    local DIR=$1
    if [ -d "$DIR" ]; then
        LOG "DIR_EXISTS: Directory $DIR exists"
        return 0 # Directory exists
    else
        LOG "DIR_EXISTS: Directory $DIR does NOT exist"
        return 1 # Directory does not exist
    fi
}
# Example usage of DIR_EXISTS:
# DIR_EXISTS "/etc" && echo "Directory exists"
# ! DIR_EXISTS "/etc" && echo "Directory does not exist"
# if DIR_EXISTS "/etc"; then
#     echo "Directory exists"
# else
#     echo "Directory does not exist"
# fi

# Function to check if a file is empty hide errors
FILE_EMPTY() {
    local FILE=$1
    if [ -s "$FILE" ]; then
        LOG "FILE_EMPTY: File $FILE is NOT empty"
        return 1 # File is not empty
    else
        LOG "FILE_EMPTY: File $FILE is empty"
        return 0 # File is empty
    fi
}
# Example usage of FILE_EMPTY:
# FILE_EMPTY "/etc/passwd" && echo "File is empty"
# ! FILE_EMPTY "/etc/passwd" && echo "File is not empty"
# if FILE_EMPTY "/etc/passwd"; then
#     echo "File is empty"
# else
#     echo "File is not empty"
# fi

# Function to check if a directory is empty
DIR_EMPTY() {
    local DIR=$1
    if [ "$(ls -A $DIR)" ]; then
        LOG "DIR_EMPTY: Directory $DIR is NOT empty"
        return 1 # Directory is not empty
    else
        LOG "DIR_EMPTY: Directory $DIR is empty"
        return 0 # Directory is empty
    fi
}
# Example usage of DIR_EMPTY:
# DIR_EMPTY "/etc" && echo "Directory is empty"
# if DIR_EMPTY "/etc"; then
#     echo "Directory is empty"
# else
#     echo "Directory is not empty"
# fi

# Function to check if a file or directory is writable
IS_WRITABLE() {
    local FILE=$1
    if [ -w "$FILE" ]; then
        LOG "IS_WRITABLE: File or directory $FILE is writable"
        return 0 # File or directory is writable
    else
        LOG "IS_WRITABLE: File or directory $FILE is NOT writable"
        return 1 # File or directory is not writable
    fi
}
# Example usage of IS_WRITABLE:
# IS_WRITABLE "/etc/passwd" && echo "File or directory is writable"
# ! IS_WRITABLE "/etc/passwd" && echo "File or directory is not writable"
# if IS_WRITABLE "/etc/passwd"; then
#     echo "File or directory is writable"
# else
#     echo "File or directory is not writable"
# fi

# Function to check if a file or directory is readable
IS_READABLE() {
    local FILE=$1
    if [ -r "$FILE" ]; then
        LOG "IS_READABLE: File or directory $FILE is readable"
        return 0 # File or directory is readable
    else
        LOG "IS_READABLE: File or directory $FILE is NOT readable"
        return 1 # File or directory is not readable
    fi
}
# Example usage of IS_READABLE:
# IS_READABLE "/etc/passwd" && echo "File or directory is readable"
# ! IS_READABLE "/etc/passwd" && echo "File or directory is not readable"
# if IS_READABLE "/etc/passwd"; then
#     echo "File or directory is readable"
# else
#     echo "File or directory is not readable"
# fi

# Function to check if a file or directory is executable
IS_EXECUTABLE() {
    local FILE=$1
    if [ -x "$FILE" ]; then
        LOG "IS_EXECUTABLE: File or directory $FILE is executable"
        return 0 # File or directory is executable
    else
        LOG "IS_EXECUTABLE: File or directory $FILE is NOT executable"
        return 1 # File or directory is not executable
    fi
}
# Example usage of IS_EXECUTABLE:
# IS_EXECUTABLE "/etc/passwd" && echo "File or directory is executable"
# ! IS_EXECUTABLE "/etc/passwd" && echo "File or directory is not executable"
# if IS_EXECUTABLE "/etc/passwd"; then
#     echo "File or directory is executable"
# else
#     echo "File or directory is not executable"
# fi

# Function to check if a file or directory is owned by the user
IS_OWNED_BY_USER() {
    local FILE=$1
    local USER=$2
    if [ "$(stat -c "%U" $FILE)" == "$USER" ]; then
        LOG "IS_OWNED_BY_USER: File or directory $FILE is owned by the user"
        return 0 # File or directory is owned by the user
    else
        LOG "IS_OWNED_BY_USER: File or directory $FILE is NOT owned by the user"
        return 1 # File or directory is not owned by the user
    fi
}
# Example usage of IS_OWNED_BY_USER:
# IS_OWNED_BY_USER "/etc/passwd" "root" && echo "File or directory is owned by the user"
# ! IS_OWNED_BY_USER "/etc/passwdNO" "root" && echo "File or directory is not owned by the user"
# if IS_OWNED_BY_USER "/etc/passwd" "root"; then
#     echo "File or directory is owned by the user"
# else
#     echo "File or directory is not owned by the user"
# fi

# Function to check if a file or directory is owned by the group
IS_OWNED_BY_GROUP() {
    local FILE=$1
    local GROUP=$2
    if [ "$(stat -c "%G" $FILE)" == "$GROUP" ]; then
        LOG "IS_OWNED_BY_GROUP: File or directory $FILE is owned by the group"
        return 0 # File or directory is owned by the group
    else
        LOG "IS_OWNED_BY_GROUP: File or directory $FILE is NOT owned by the group"
        return 1 # File or directory is not owned by the group
    fi
}
# Example usage of IS_OWNED_BY_GROUP:
# IS_OWNED_BY_GROUP "/etc/passwd" "root" && echo "File or directory is owned by the group"
# ! IS_OWNED_BY_GROUP "/etc/passwdNO" "root" && echo "File or directory is NOT owned by the group"
# if IS_OWNED_BY_GROUP "/etc/passwd" "root"; then
#     echo "File or directory is owned by the group"
# else
#     echo "File or directory is NOT owned by the group"

# Function : Check if is older than X days return 0 if true else 1
IS_OLDER_THAN(){
    if [ $(find $1 -mtime +$2) ]; then
        LOG "IS_OLDER_THAN: $1 is older than $2 days"
        return 0 # File is older than X days
    else
        LOG "IS_OLDER_THAN: $1 is NOT older than $2 days"
        return 1 # File is NOT older than X days
    fi
}
# Example usage of IS_OLDER_THAN:
# IS_OLDER_THAN "/etc/passwd" "7" && echo "File is older than 7 days"
# ! IS_OLDER_THAN "/etc/passwd" "7" && echo "File is NOT older than 7 days"
# if IS_OLDER_THAN "/etc/passwd" "7"; then
#     echo "File is older than 7 days"
# else
#     echo "File is NOT older than 7 days"
# fi

# Function : Get public IP address
GET_PUBLIC_IP(){
    # Check if curl is installed
    if ! IS_INSTALLED "curl"; then
        echo "Error: curl is required to get the public IP address"
        LOG "GET_PUBLIC_IP: curl is required to get the public IP address"
        exit 1
    fi
    # Get public IP address
    local PUBLIC_IP=$(curl -s https://api.ipify.org)
    LOG "GET_PUBLIC_IP: Public IP address is $PUBLIC_IP"
    echo $PUBLIC_IP
}

# Example usage of GET_PUBLIC_IP:
# MY_PUBLIC_IP=$(GET_PUBLIC_IP)

# Function : Get local IP address of the interface (default eth0) , use ifconfig to get the IP address
GET_LOCAL_IP(){
    local INTERFACE=$1
    if IS_EMPTY "$INTERFACE"; then
        INTERFACE="eth0"
    fi
    # Check if ifconfig is installed
    if ! IS_INSTALLED "ifconfig"; then
        echo "Error: ifconfig is required to get the local IP address"
        LOG "GET_LOCAL_IP: ifconfig is required to get the local IP address"
        exit 1
    fi
    # Get local IP address
    local LOCAL_IP=$(ifconfig $INTERFACE | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')
    LOG "GET_LOCAL_IP: Local IP address for $INTERFACE is $LOCAL_IP"
    echo $LOCAL_IP
}

# Function: Count string length
STRING_LENGTH(){
    local STRING=$1
    local LENGTH=${#STRING}
    LOG "STRING_LENGTH: Length of $STRING is $LENGTH"
    echo $LENGTH
}

# Example usage of STRING_LENGTH:
# STRING_LENGTH "Hello World"

######################################################################
#                          Change Variables                          #
######################################################################
#SCRIPT="bashframe"
#SCRIPT_NAME="BashFrame"
#VERSION="1.0.0"
#SCRIPT_URL="https://raw.githubusercontent.com/ErvisTusha/BashFrame/bashframe.sh"
######################################################################
#                           Main Function                            #
######################################################################
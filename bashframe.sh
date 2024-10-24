#!/bin/bash
######################################################################
# Author: Ervis Tusha                                                #
# Email: ERVISTUSHA[at]GMAIL.COM                                     #
# Github: Github: https://github.com/ErvisTusha                      #
# Twitter: https://X.com/ET                                          #
# LinkedIn: https://linkedin.com/in/ErvisTusha                       #
# License: MIT LICENSE                                               #
######################################################################
#                           BashFrame 1.0.2                          #
######################################################################
# BashFrame is a bash script that provides a framework for creating and managing bash scripts.
# It includes functions for checking if the user has root or sudo privileges, checking if a tool is installed,
# downloading files, installing, uninstalling, and updating scripts, and asking the user questions.
# The script is designed to be used as a template for creating new bash scripts.
######################################################################



######################################################################
#                  1. User and Privilege Checks                    #
######################################################################

# Function to check if the user has root or sudo privileges
IS_SUDO() {
    if [[ $EUID -eq 0 ]]; then
        echo "INFO: User has root privileges"
        return 0 # User has root privileges
    fi
    echo "INFO: User does not have root privileges"
    return 1 # User does not have root privileges
}

######################################################################
#                 2. Tool and Installation Management               #
######################################################################

# Function to check if a tool is installed
IS_INSTALLED() {
    local TOOL=$1
    if command -v $TOOL >/dev/null 2>&1; then
        echo "INFO: $TOOL is installed"
        return 0 # Tool is installed
    fi
    echo "INFO: $TOOL is not installed"
    return 1 # Tool is not installed
}

# Function to download files
DOWNLOAD() {
    if [ $# -eq 0 ]; then
        echo "ERROR: No arguments provided"
        return 1
    fi

    if [ $# -eq 1 ]; then
        local OUTPUT="./"
    else
        local OUTPUT=$2
    fi

    if ! [[ $1 =~ ^https?:// ]]; then
        echo "ERROR: Invalid URL"
        return 1
    fi

    if [ ! -w "$(dirname "$OUTPUT")" ]; then
        echo "ERROR: Output directory is not writable"
        return 1
    fi

    if command -v wget >/dev/null 2>&1; then
        wget -q --show-progress "$1" -O "$OUTPUT"
    elif command -v curl >/dev/null 2>&1; then
        curl -s -L "$1" -o "$OUTPUT"
    elif command -v python >/dev/null 2>&1; then
        python -c "import urllib.request; urllib.request.urlretrieve('$1', '$OUTPUT')"
    else
        echo "ERROR: Neither wget, curl, nor python is installed"
        return 1
    fi
    return 0
}

# Function to install the script
INSTALL() {
    IS_SUDO || { echo "ERROR: Root privileges required"; exit 1; }

    if command -v "$SCRIPT" >/dev/null 2>&1; then
        echo "INFO: $SCRIPT is already installed"
        exit 0
    fi

    cp "$0" /usr/local/bin/$SCRIPT
    chmod +x /usr/local/bin/$SCRIPT
    echo "$SCRIPT_NAME installed successfully"
    echo "$SCRIPT_NAME version $VERSION"
    exit 0
}

# Function to uninstall the script
UNINSTALL() {
    IS_SUDO || { echo "ERROR: Root privileges required"; exit 1; }

    if ! command -v "$SCRIPT" >/dev/null 2>&1; then
        echo "INFO: $SCRIPT is not installed"
        exit 1
    fi

    read -p "Do you want to uninstall the $SCRIPT_NAME? (y/n): " ANSWER
    if [[ $ANSWER != "y" ]]; then
        echo "INFO: Uninstallation aborted"
        exit 0
    fi

    rm /usr/local/bin/$SCRIPT
    echo "$SCRIPT_NAME uninstalled successfully"
    exit 0
}

# Function to update the script
UPDATE() {
    IS_SUDO || { echo "ERROR: Root privileges required"; exit 1; }

    if ! command -v "$SCRIPT" >/dev/null 2>&1; then
        echo "INFO: $SCRIPT is not installed"
        exit 1
    fi

    echo "Downloading the latest version..."
    DOWNLOAD "$SCRIPT_URL" /tmp/$SCRIPT || { echo "ERROR: Download failed"; exit 1; }

    if [ ! -s /tmp/$SCRIPT ]; then
        echo "ERROR: Downloaded file is empty"
        exit 1
    fi

    NEW_VERSION=$(grep "VERSION=\"[0-9.]*\"" /tmp/$SCRIPT -m 1 | cut -d "=" -f 2 | tr -d '"')
    echo "INFO: Update: New version is $NEW_VERSION"

    if [[ "$NEW_VERSION" == "$VERSION" ]]; then
        echo "INFO: Already up-to-date"
        exit 0
    fi

    cp /tmp/$SCRIPT /usr/local/bin/$SCRIPT
    chmod +x /usr/local/bin/$SCRIPT
    echo "$SCRIPT_NAME updated successfully"
    echo "$SCRIPT_NAME new version is $NEW_VERSION"
    exit 0
}

######################################################################
#                        3. User Interaction                       #
######################################################################

# Function to ask the user questions answer yes or no
ASK_USER() {
    local QUESTION="$1"
    local MAX_ATTEMPTS="${2:-3}"
    local ANSWER
    local attempts=0
    while true; do
        if [[ $attempts -ge $MAX_ATTEMPTS ]]; then
            echo "Maximum attempts reached."
            return 1
        fi
        read -p "$QUESTION (y/n): " ANSWER
        case $ANSWER in
            [Yy]* ) return 0 ;;
            [Nn]* ) return 1 ;;
            * ) echo "Please answer yes (y) or no (n).";;
        esac
        ((attempts++))
    done
}

######################################################################
#                         4. Variable Checks                        #
######################################################################

# Function to check if a variable is empty
IS_EMPTY() {
    [[ -z $1 ]]
}

# Function to check if a variable is a number
IS_NUMBER() {
    [[ $1 =~ ^[0-9]+$ ]]
}

# Function to check if a variable is a string
IS_STRING() {
    [[ $1 =~ ^[a-zA-Z]+$ ]]
}

# Function to check if a variable is a valid email address
VAL_EMAIL() {
    [[ $1 =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

# Function to check if a variable is a valid URL
VAL_URL() {
    [[ $1 =~ ^https?:// ]]
}

# Function to validate IPv4 addresses
VAL_IP() {
    local ip="$1"
    local IFS=.
    local -a octets=($ip)

    if [ "${#octets[@]}" -ne 4 ]; then
        return 1
    fi

    for octet in "${octets[@]}"; do
        if ! [[ $octet =~ ^[0-9]+$ ]] || [ "$octet" -lt 0 ] || [ "$octet" -gt 255 ]; then
            return 1
        fi
    done

    return 0
}

# Function to check if a variable is a valid IPv6 address
VAL_IPV6() {
    [[ $1 =~ ^([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}$ ]]
}

# Function to check if a variable is a valid MAC address
VAL_MACADDR() {
    [[ $1 =~ ^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$ ]]
}

######################################################################
#                    5. File and Directory Management                #
######################################################################

# Function to check if a file or directory exists
FILE_EXISTS() {
    local FILE=$1
    if [ -e "$FILE" ]; then
        return 0 # File exists
    else
        return 1 # File does not exist
    fi
}

# Function to check if a directory exists
DIR_EXISTS() {
    local DIR=$1
    if [ -d "$DIR" ]; then
        return 0 # Directory exists
    else
        return 1 # Directory does not exist
    fi
}

# Function to check if a file is empty
FILE_EMPTY() {
    local FILE=$1
    if [ -s "$FILE" ]; then
        return 1 # File is not empty
    else
        return 0 # File is empty
    fi
}

# Function to check if a directory is empty
DIR_EMPTY() {
    local DIR=$1
    if [ "$(ls -A $DIR)" ]; then
        return 1 # Directory is not empty
    else
        return 0 # Directory is empty
    fi
}

# Function to check if a file or directory is writable
IS_WRITABLE() {
    local FILE=$1
    if [ -w "$FILE" ]; then
        return 0 # File or directory is writable
    else
        return 1 # File or directory is not writable
    fi
}

# Function to check if a file or directory is readable
IS_READABLE() {
    local FILE=$1
    if [ -r "$FILE" ]; then
        return 0 # File or directory is readable
    else
        return 1 # File or directory is not readable
    fi
}

# Function to check if a file or directory is executable
IS_EXECUTABLE() {
    local FILE=$1
    if [ -x "$FILE" ]; then
        return 0 # File or directory is executable
    else
        return 1 # File or directory is not executable
    fi
}

# Function to check if a file or directory is owned by the user
IS_OWNED_BY_USER() {
    local FILE=$1
    local USER=$2
    if [ "$(stat -c "%U" $FILE)" == "$USER" ]; then
        return 0 # File or directory is owned by the user
    else
        return 1 # File or directory is not owned by the user
    fi
}

# Function to check if a file or directory is owned by the group
IS_OWNED_BY_GROUP() {
    local FILE=$1
    local GROUP=$2
    if [ "$(stat -c "%G" $FILE)" == "$GROUP" ]; then
        return 0 # File or directory is owned by the group
    else
        return 1 # File or directory is not owned by the group
    fi
}

# Function to check if a file is older than X days
IS_OLDER_THAN() {
    if [ $(find $1 -mtime +$2) ]; then
        return 0 # File is older than X days
    else
        return 1 # File is NOT older than X days
    fi
}

######################################################################
#                         6. Logging and Debugging                   #
######################################################################

# Set the logging level (INFO, WARNING, ERROR, DEBUG)
LOG_LEVEL="INFO"

# Function to log messages to /tmp/log/$SCRIPT.log
LOG() {
    local level="$1"
    local message="$2"
    local log_file="/tmp/log/$SCRIPT.log"
    local timestamp

    mkdir -p "$(dirname "$log_file")"
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    declare -A levels=( ["ERROR"]=0 ["WARNING"]=1 ["INFO"]=2 ["DEBUG"]=3 )
    local message_level=${levels[$level]:-2}
    local current_level=${levels[$LOG_LEVEL]:-2}

    if [[ -z "${levels[$level]}" ]]; then
        message_level=2
    fi

    if [ "$message_level" -le "$current_level" ]; then
        echo -e "$timestamp [$level] $message" >> "$log_file"
    fi
}

######################################################################
#                         Error Handling                             #
######################################################################

# Function to handle errors
handle_error() {
    local MESSAGE=$1
    local EXIT_CODE=$2

    LOG "ERROR" "Error: $MESSAGE"
    if [[ ! -z "$EXIT_CODE" ]]; then
        exit "$EXIT_CODE"
    fi
}

######################################################################
#                         7. String Operations                      #
######################################################################

# Function to generate a random string
GENERATE_RANDOM() {
    local LENGTH=$1
    local TYPE=$2
    local RESULT=""
    local CHARS

    case "$TYPE" in
        1 | "numbers")
            CHARS="0123456789"
            ;;
        2 | "characters")
            CHARS="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
            ;;
        3 | "mixed")
            CHARS="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            ;;
        *)
            echo "ERROR: Invalid type"
            return 1
            ;;
    esac

    for i in $(seq 1 $LENGTH); do
        RESULT="${RESULT}${CHARS:RANDOM%${#CHARS}:1}"
    done

    echo $RESULT
}

# Function: Count string length
STRING_LENGTH() {
    local STRING=$1
    local LENGTH=${#STRING}
    echo $LENGTH
}

######################################################################
#                         8. Network Operations                     #
######################################################################

# Function : Get public IP address
GET_PUBLIC_IP() {
    if ! command -v curl >/dev/null 2>&1; then
        echo "ERROR: curl is not installed"
        exit 1
    fi
    local PUBLIC_IP=$(curl -s https://api.ipify.org)
    echo $PUBLIC_IP
}

# Function : Get local IP address of the interface (default eth0)
GET_LOCAL_IP() {
    local INTERFACE=$1
    if [ -z "$INTERFACE" ]; then
        INTERFACE="eth0"
    fi

    if ! command -v ifconfig >/dev/null 2>&1; then
        echo "ERROR: ifconfig is not installed"
        exit 1
    fi

    local LOCAL_IP=$(ifconfig $INTERFACE | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')
    echo $LOCAL_IP
}

# Function to check if file permissions match the expected permissions
CHECK_PERMISSIONS() {
    local FILEPATH=$1
    local EXPECTED_PERMISSIONS=$2

    if [ ! -e "$FILEPATH" ]; then
        echo "ERROR: File does not exist"
        return 1
    fi

    local CURRENT_PERMISSIONS=$(stat -c "%a" $FILEPATH)
    if [[ $CURRENT_PERMISSIONS == $EXPECTED_PERMISSIONS ]]; then
        return 0
    fi
    echo "WARNING: Permissions for $FILEPATH are $CURRENT_PERMISSIONS, expected $EXPECTED_PERMISSIONS"
    return 1
}

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

## BashFrame 1.0.1

### Description
BashFrame is a bash script framework designed for creating and managing bash scripts. It offers a range of utility functions, from checking user privileges and verifying tool installations to downloading files and validating inputs. This script serves as a comprehensive template for your bash scripting needs.

### Author Information
**Ervis Tusha**  
[GitHub](https://github.com/ErvisTusha)  
[Twitter](https://X.com/ET)  
[LinkedIn](https://linkedin.com/in/ErvisTusha)  
[E-mail](mailto:ervistusha@gmail.com)

### Features
1. Check user's sudo or root privileges.
2. Determine if a specific tool is installed.
3. Download files using wget, curl, or python.
4. Validate inputs like emails, URLs, IPs, and MAC addresses.
5. Log actions for easier debugging and monitoring.
6. ... and several more utility functions!


### List of Functions
| Function | Description |
| --- | --- |
| **IS_SUDO** | Determine if the user has root or sudo privileges. |
| **IS_INSTALLED** | Determine if a specific tool is installed. |
| **DOWNLOAD** | Download files using wget, curl, or python. |
| **INSTALL** | (Removed based on your previous request) |
| **UNINSTALL** | Uninstall the script. |
| **UPDATE** | Update the script to its latest version. |
| **ASK_USER** | Interactively ask the user a question with a Yes/No response. |
| **IS_EMPTY** | Check if a given variable is empty. |
| **IS_NUMBER** | Check if a given variable is a numeric value. |
| **IS_STRING** | Check if a given variable is a string. |
| **VAL_EMAIL** | Check if a given value is a valid email address. |
| **VAL_URL** | Check if a given value is a valid URL. |
| **VAL_IP** | Check if a given value is a valid IPv4 address. |
| **VAL_IPV6** | Check if a given value is a valid IPv6 address. |
| **VAL_MACADDR** | Check if a given value is a valid MAC address. |
| **LOG** | Log messages to a specified log file. |
| **CHECK_PERMISSIONS** | Check if file permissions match the expected permissions. |
| **GENERATE_RANDOM** | Generate a random string based on specified criteria. |
| **FILE_EXISTS** | Check if a specified file or directory exists. |
| **DIR_EXISTS** | Check if a specified directory exists. |
| **FILE_EMPTY** | Check if a specified file is empty. |
| **DIR_EMPTY** | Check if a specified directory is empty. |
| **IS_WRITABLE** | Check if a given file or directory is writable. |
| **IS_READABLE** | Check if a given file or directory is readable. |
| **IS_EXECUTABLE** | Check if a given file or directory is executable. |
| **IS_OWNED_BY_USER** | Check if a given file or directory is owned by a specific user. |
| **IS_OWNED_BY_GROUP** | Check if a given file or directory is owned by a specific group. |
| **IS_OLDER_THAN** | Check if a file or directory is older than a specified number of days. |
| **GET_PUBLIC_IP** | Retrieve the public IP address of the machine. |
| **GET_LOCAL_IP** | Retrieve the local IP address of a specified interface. |
| **STRING_LENGTH** | Determine the length of a given string. |

### How to Use
BashFrame offers a multitude of functions, each designed for a specific purpose. Here are some primary functions along with their usage examples:

1. **IS_SUDO**: Determine if the user has root or sudo privileges.
   ```bash
   IS_SUDO && echo "User has root privileges"
   ```
2. **IS_INSTALLED**: Determine if a specific tool is installed.
   ```bash
   IS_INSTALLED "wget" && echo "wget is installed"
   ```
3. **DOWNLOAD**: Download a file using wget, curl, or python.
   ```bash
   DOWNLOAD "https://example.com/file.txt" "/tmp/file.txt"
   ```
4. **LOG**: Log a message to a file.
   ```bash
   LOG "This is a log message"
   ```

### LOGGING
Logs can be found in /tmp/log/[SCRIPT].log.


### License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Contributing
For those interested in contributing, feel free to raise issues or make pull requests.

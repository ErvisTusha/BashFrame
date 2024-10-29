#!/bin/bash

# Source the main script
source ./bashframe.sh


VERBOSE=false
DEBUG=false
LOG_FILE="/workspaces/BashFrame/bashframe.log"
rm -f "$LOG_FILE"
#IS_SUDO
#exit
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m'


# Setup and cleanup
setup() {
    TEST_DIR=$(mktemp -d)
    TEST_FILE="$TEST_DIR/test_file"
    TEST_DIR_EMPTY="$TEST_DIR/empty_dir"
    mkdir -p "$TEST_DIR_EMPTY"
    echo "test content" > "$TEST_FILE"
    chmod 644 "$TEST_FILE"
}

cleanup() {
    rm -rf "$TEST_DIR"
}

# 1. User and Privilege Checks Tests
test_user_privilege_checks() {
    echo -e "\n${YELLOW}${BOLD}1. Testing User and Privilege Checks...${NC}"
    
    if [[ $EUID -eq 0 ]]; then
        ASSERT_TRUE "IS_SUDO" "IS_SUDO for root user" "root"
    else
        ASSERT_FALSE "IS_SUDO" "IS_SUDO for non-root user" "non-root"
    fi

    # Test HAS_SUDO function
    if HAS_SUDO; then
        ASSERT_TRUE "HAS_SUDO" "User has sudo privileges" "Testing HAS_SUDO function"
    else
        ASSERT_FALSE "HAS_SUDO" "User does not have sudo privileges" "Testing HAS_SUDO function"
    fi
}

# 2. Tool and Installation Management Tests
test_tool_installation_checks() {
    echo -e "\n${YELLOW}${BOLD}2. Testing Tool Installation Checks...${NC}"
    ASSERT_TRUE "IS_INSTALLED 'ls'" "IS_INSTALLED for command" "ls"
    ASSERT_FALSE "IS_INSTALLED 'nonexistentcommand123'" "IS_INSTALLED for non-existent command" "nonexistentcommand123"
    ASSERT_FALSE "IS_INSTALLED ''" "IS_INSTALLED for empty string" ""
}

# 3. User Interaction Tests
test_user_interaction() {
    echo -e "\n${YELLOW}${BOLD}3. Testing User Interaction...${NC}"
    
    # Test ASK_USER with 'yes'

    echo "y" | ASSERT_TRUE "ASK_USER 'Test question?'" "ASK_USER for 'y'" "y"
    echo "Y" | ASSERT_TRUE "ASK_USER 'Test question?'" "ASK_USER for 'Y'" "Y"

    # Test ASK_USER with empty input
    echo "" | ASSERT_FALSE "ASK_USER 'Test question?'" "ASK_USER for empty input" ""
    
    # Test ASK_USER with invalid input
    echo "invalid" | ASSERT_FALSE "ASK_USER 'Test question?' 3" "ASK_USER for invalid input with limited attempts" "invalid"
    
    # Test ASK_USER with 'no'
    echo "n" | ASSERT_FALSE "ASK_USER 'Test question?'" "ASK_USER for 'n'" "n"
    echo "N" | ASSERT_FALSE "ASK_USER 'Test question?'" "ASK_USER for 'N'" "N"
}

# 4. Variable Checks Tests
test_variable_checks() {
    echo -e "\n${YELLOW}${BOLD}4. Testing Variable Checks...${NC}"
    
    # Test IS_EMPTY
    echo -e "\n${YELLOW}${BOLD}4.1 Testing IS_EMPTY...${NC}"
    ASSERT_TRUE "IS_EMPTY ''" "IS_EMPTY for empty string" ""
    ASSERT_FALSE "IS_EMPTY 'test'" "IS_EMPTY for non-empty string" "test"
    
    # Test IS_NUMBER
    echo -e "\n${YELLOW}${BOLD}4.2 Testing IS_NUMBER...${NC}"
    ASSERT_TRUE "IS_NUMBER '123'" "IS_NUMBER for valid number" "123"
    ASSERT_FALSE "IS_NUMBER 'abc'" "IS_NUMBER for non-number" "abc"
    ASSERT_FALSE "IS_NUMBER ''" "IS_NUMBER for empty string" ""
    
    # Test VAL_EMAIL
    echo -e "\n${YELLOW}${BOLD}4.3 Testing VAL_EMAIL...${NC}"
    ASSERT_FALSE "VAL_EMAIL ''" "VAL_EMAIL for empty string" ""
    ASSERT_TRUE "VAL_EMAIL 'test@example.com'" "VAL_EMAIL for valid email" "test@example.com"
    ASSERT_FALSE "VAL_EMAIL 'invalid-email'" "VAL_EMAIL for invalid email" "invalid-email"
    ASSERT_FALSE "VAL_EMAIL ''" "VAL_EMAIL for empty string" ""
    
    # Test VAL_URL
    echo -e "\n${YELLOW}${BOLD}4.4 Testing VAL_URL...${NC}"
    ASSERT_TRUE "VAL_URL 'https://example.com'" "VAL_URL for valid URL" "https://example.com"
    ASSERT_TRUE "VAL_URL 'http://example.com'" "VAL_URL for invalid URL" "http://example.com"
    ASSERT_TRUE "VAL_URL 'www.example.com'" "VAL_URL for valid URL" "www.example.com"
    ASSERT_TRUE "VAL_URL 'example.com'" "VAL_URL for valid URL" "example.com"
    ASSERT_FALSE "VAL_URL '.example.com'" "VAL_URL for invalid URL" ".example.com"
    ASSERT_FALSE "VAL_URL 'invalid-url'" "VAL_URL for invalid URL" "invalid-url"
    ASSERT_FALSE "VAL_URL ''" "VAL_URL for empty string" ""

    
    # Test VAL_IP
    echo -e "\n${YELLOW}${BOLD}4.5 Testing VAL_IP...${NC}"
    ASSERT_TRUE "VAL_IP '192.168.1.1'" "VAL_IP for valid IPv4" "192.168.1.1"
    ASSERT_FALSE "VAL_IP '256.256.256.256'" "VAL_IP for invalid IPv4" "256.256.256.256"
    ASSERT_FALSE "VAL_IP ''" "VAL_IP for empty string" ""
    ASSERT_FALSE "VAL_IP 'invalid-ip'" "VAL_IP for invalid IPv4" "invalid-ip"
    
    # Test VAL_IPV6
    ASSERT_TRUE "VAL_IPV6 '2001:0db8:85a3:0000:0000:8a2e:0370:7334'" "VAL_IPV6 for valid IPv6" "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
    ASSERT_FALSE "VAL_IPV6 'invalid-ipv6'" "VAL_IPV6 for invalid IPv6" "invalid-ipv6"
    
    # Test VAL_MACADDR
    ASSERT_TRUE "VAL_MACADDR '00:11:22:33:44:55'" "VAL_MACADDR for valid MAC" "00:11:22:33:44:55"
    ASSERT_FALSE "VAL_MACADDR 'invalid-mac'" "VAL_MACADDR for invalid MAC" "invalid-mac"
}

# 5. File and Directory Management Tests
test_file_directory_management() {
    echo -e "\n${YELLOW}${BOLD}5. Testing File and Directory Management...${NC}"
    
    # Test FILE_EXISTS
    echo -e "\n${YELLOW}${BOLD}5.1 Testing FILE_EXISTS...${NC}"
    ASSERT_TRUE "FILE_EXISTS '$TEST_FILE'" "FILE_EXISTS for existing file" "$TEST_FILE"
    ASSERT_FALSE "FILE_EXISTS '$TEST_DIR/nonexistent'" "FILE_EXISTS for non-existent file" "$TEST_DIR/nonexistent"
    ASSERT_FALSE "0" "$?" "FILE_EXISTS should return 0 for existing file"

    # Test DIR_EXISTS
    echo -e "\n${YELLOW}${BOLD}5.2 Testing DIR_EXISTS...${NC}"
    ASSERT_TRUE "DIR_EXISTS '$TEST_DIR'" "DIR_EXISTS for existing directory" "$TEST_DIR"
    ASSERT_FALSE "DIR_EXISTS '$TEST_DIR/nonexistent'" "DIR_EXISTS for non-existent directory" "$TEST_DIR/nonexistent"
    ASSERT_FALSE "DIR_EXISTS ''" "DIR_EXISTS no argument" ""

    # Test FILE_EMPTY
    echo -e "\n${YELLOW}${BOLD}5.3 Testing FILE_EMPTY...${NC}"
    touch "$TEST_DIR/empty_file"
    ASSERT_TRUE "FILE_EMPTY '$TEST_DIR/empty_file'" "FILE_EMPTY for empty file" "$TEST_DIR/empty_file"
    ASSERT_FALSE "FILE_EMPTY '$TEST_FILE'" "FILE_EMPTY for non-empty file" "$TEST_FILE"
    ASSERT_FALSE "FILE_EMPTY ''" "FILE_EMPTY no argument" ""
    # Test DIR_EMPTY
    echo -e "\n${YELLOW}${BOLD}5.4 Testing DIR_EMPTY...${NC}"
    ASSERT_TRUE "DIR_EMPTY '$TEST_DIR_EMPTY'" "DIR_EMPTY for empty directory" "$TEST_DIR_EMPTY"
    touch "$TEST_DIR_EMPTY/file"
    ASSERT_FALSE "DIR_EMPTY '$TEST_DIR_EMPTY'" "DIR_EMPTY for non-empty directory" "$TEST_DIR_EMPTY"
    ASSERT_FALSE "DIR_EMPTY '$TEST_DIR_EMPTY'" "DIR_EMPTY no argument" ""

    # Test IS_WRITABLE
    echo -e "\n${YELLOW}${BOLD}5.5 Testing IS_WRITABLE...${NC}"
    ASSERT_TRUE "IS_WRITABLE '$TEST_FILE'" "IS_WRITABLE for writable file" "$TEST_FILE"
    chmod 444 "$TEST_FILE"
    ASSERT_FALSE "IS_WRITABLE '$TEST_FILE'" "IS_WRITABLE for non-writable file" "$TEST_FILE"
    ASSERT_FALSE "IS_WRITABLE ''" "IS_WRITABLE no argument" ""

    # Test IS_READABLE
    echo -e "\n${YELLOW}${BOLD}5.6 Testing IS_READABLE...${NC}"
    ASSERT_TRUE "IS_READABLE '$TEST_FILE'" "IS_READABLE for readable file" "$TEST_FILE"
    chmod 000 "$TEST_FILE"
    ASSERT_FALSE "IS_READABLE '$TEST_FILE'" "IS_READABLE for non-readable file" "$TEST_FILE"
    ASSERT_FALSE "IS_READABLE ''" "IS_READABLE no argument" ""

    # Test IS_EXECUTABLE
    echo -e "\n${YELLOW}${BOLD}5.7 Testing IS_EXECUTABLE...${NC}"
    chmod 755 "$TEST_FILE"
    ASSERT_TRUE "IS_EXECUTABLE '$TEST_FILE'" "IS_EXECUTABLE for executable file" "$TEST_FILE"
    chmod 644 "$TEST_FILE"
    ASSERT_FALSE "IS_EXECUTABLE '$TEST_FILE'" "IS_EXECUTABLE for non-executable file" "$TEST_FILE"
    ASSERT_FALSE "IS_EXECUTABLE ''" "IS_EXECUTABLE for empty string" ""

    # Test IS_OWNED_BY_USER
    echo -e "\n${YELLOW}${BOLD}5.8 Testing IS_OWNED_BY_USER...${NC}"
    current_user=$(whoami)
    ASSERT_TRUE "IS_OWNED_BY_USER '$TEST_FILE' '$current_user'" "IS_OWNED_BY_USER for current user" "$current_user"
    ASSERT_FALSE "IS_OWNED_BY_USER '$TEST_FILE' 'nonexistentuser'" "IS_OWNED_BY_USER for non-existent user" "nonexistentuser"
    
    # Test IS_OWNED_BY_GROUP
    echo -e "\n${YELLOW}${BOLD}5.9 Testing IS_OWNED_BY_GROUP...${NC}"
    current_group=$(id -gn)
    ASSERT_TRUE "IS_OWNED_BY_GROUP '$TEST_FILE' '$current_group'" "IS_OWNED_BY_GROUP for current group" "$current_group"
    ASSERT_FALSE "IS_OWNED_BY_GROUP '$TEST_FILE' 'nonexistentgroup'" "IS_OWNED_BY_GROUP for non-existent group" "nonexistentgroup"
    ASSERT_FALSE "IS_OWNED_BY_GROUP ''" "IS_OWNED_BY_GROUP no argument" ""  

    # Test IS_OLDER_THAN (might need adjustment based on file creation time)
    echo -e "\n${YELLOW}${BOLD}5.10 Testing IS_OLDER_THAN...${NC}"
    ASSERT_FALSE "IS_OLDER_THAN '$TEST_FILE' 1" "IS_OLDER_THAN for new file" "1 day"
    
    # Test CHECK_PERMISSIONS
    echo -e "\n${YELLOW}${BOLD}5.11 Testing CHECK_PERMISSIONS...${NC}"
    ASSERT_TRUE "CHECK_PERMISSIONS '$TEST_FILE' '644'" "CHECK_PERMISSIONS for correct permissions" "644"
    ASSERT_FALSE "CHECK_PERMISSIONS '$TEST_FILE' '777'" "CHECK_PERMISSIONS for incorrect permissions" "777"
    ASSERT_FALSE "CHECK_PERMISSIONS '' '777'" "CHECK_PERMISSIONS for empty string" "777"
    ASSERT_FALSE "CHECK_PERMISSIONS '$TEST_FILE' 'invalid'" "CHECK_PERMISSIONS for invalid permissions" "invalid"
    ASSERT_FALSE "CHECK_PERMISSIONS 'nonexistentfile' '644'" "CHECK_PERMISSIONS for non-existent file" "nonexistentfile"
    #exit
}

# 6. String Operations Tests
test_string_operations() {
    echo -e "\n${YELLOW}${BOLD}6. Testing String Operations...${NC}"
    
    # Test GENERATE_RANDOM
    local random_num=$(GENERATE_RANDOM 10 "numbers")
    ASSERT_TRUE "[[ ${#random_num} -eq 10 ]]" "GENERATE_RANDOM should generate correct length for numbers" "10"
    ASSERT_TRUE "[[ $random_num =~ ^[0-9]+$ ]]" "GENERATE_RANDOM should generate only numbers" "$random_num"
    
    local random_str=$(GENERATE_RANDOM 10 "characters")
    ASSERT_TRUE "[[ ${#random_str} -eq 10 ]]" "GENERATE_RANDOM should generate correct length for characters" "10"
    ASSERT_TRUE "[[ $random_str =~ ^[a-zA-Z]+$ ]]" "GENERATE_RANDOM should generate only letters" "$random_str"
    
    local random_mixed=$(GENERATE_RANDOM 10 "mixed")
    ASSERT_TRUE "[[ ${#random_mixed} -eq 10 ]]" "GENERATE_RANDOM should generate correct length for mixed" "10"
    ASSERT_TRUE "[[ $random_mixed =~ ^[a-zA-Z0-9]+$ ]]" "GENERATE_RANDOM should generate alphanumeric characters" "$random_mixed"
    
    # Test STRING_LENGTH
    ASSERT_EQUALS "4" "$(STRING_LENGTH 'test')" "STRING_LENGTH should return correct length"
    ASSERT_FALSE "STRING_LENGTH ''" "STRING_LENGTH for empty string" ""
}
# 7. Network Operations Tests
test_network_operations() {
    echo -e "\n${YELLOW}${BOLD}7. Testing Network Operations...${NC}"
    
    
    # Test GET_LOCAL_IP
    echo -e "\n${YELLOW}${BOLD}7.1 Testing GET_LOCAL_IP...${NC}"
    ASSERT_TRUE "GET_PUBLIC_IP" "GET_PUBLIC_IP should return valid IP" "$(GET_PUBLIC_IP)"
    ASSERT_TRUE "GET_LOCAL_IP" "GET_LOCAL_IP should return valid IP" ""

}

# Print test summary
# Modified print_summary function to ensure proper display
print_summary() {
    echo -e "\n${YELLOW}${BOLD}Test Summary${NC}"
    echo -e "${GRAY}══════════════════${NC}"
    echo -e "Total Tests Run: ${BLUE}${BOLD}${TOTAL_TESTS}${NC}"
    echo -e "Tests Passed:    ${GREEN}${BOLD}${PASSED_TESTS}${NC}"
    echo -e "Tests Failed:    ${RED}${BOLD}${FAILED_TESTS}${NC}"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "\n${GREEN}${BOLD}All tests passed successfully! 🎉${NC}"
    else
        echo -e "\n${RED}${BOLD}${FAILED_TESTS} test(s) failed! 😞${NC}"
        echo -e "Check the test output above for details."
    fi
    
    echo -e "\n${GRAY}Test execution time: $SECONDS seconds${NC}"
}


# 8. Testing Logging Functions
test_logging() {
    echo -e "\n${YELLOW}${BOLD}8. Testing Logging Functions...${NC}"
    
    # Setup log file path
    
    # Test LOG with no arguments
    ASSERT_FALSE "LOG" "LOG should return 1 when no arguments are provided" ""
    ASSERT_TRUE "LOG 'LOG MESSAGE'" "LOG should return 0 when only message is provided" "LOG message"
    ASSERT_TRUE "LOG 'INFO' 'Test info message'" "LOG should write INFO message to log file" "INFO message"
    ASSERT_TRUE "LOG 'Invalid status' 'Test info message'" "LOG should return 1 when invalid status is provided" "Invalid status"   
    ASSERT_TRUE "LOG 'INFO' 'Test info message' '/tmp/log/test.log'" "LOG should write INFO message to specified log file" "Specified log file"
    ASSERT_TRUE "LOG 'Invalid status' 'Test info message' '/tmp/log/test.log'" "LOG should write INFO message to specified log file" "Invalid status"
}



# 9. Testing Download Function
test_download() {
    echo -e "\n${YELLOW}${BOLD}10. Testing Download Function...${NC}"
    
    local test_url="https://example.com/test.txt"
    local test_output="$TEST_DIR/downloaded_file"
    

    

    # Test with one argument
    ASSERT_TRUE "DOWNLOAD '$test_url' 2>/dev/null" "DOWNLOAD should succeed with one argument" "one argument"
    rm -f "test.txt"
    # Test with two arguments
    ASSERT_TRUE "DOWNLOAD '$test_url' '$test_output' 2>/dev/null" "DOWNLOAD should succeed with two arguments" "two arguments"
    rm -f "$test_output"
    # Test with invalid URL
    ASSERT_FALSE "DOWNLOAD 'invalid-url' '$test_output' 2>/dev/null" "DOWNLOAD should fail with invalid URL" "invalid-url"

    # Test with invalid output path
    ASSERT_FALSE "DOWNLOAD '$test_url' '/invalid/path' 2>/dev/null" "DOWNLOAD should fail with invalid output path" "invalid path"
}

# Enhanced run_tests function with better error handling
run_tests() {
    # Start timer
    SECONDS=0
    
    echo -e "${YELLOW}${BOLD}Starting BashFrame Test Suite${NC}"
    echo -e "${GRAY}══════════════════════════════════${NC}"
    echo -e "Date: $(date)"
    echo -e "BashFrame Version: ${VERSION:-Unknown}"
    echo -e "${GRAY}══════════════════════════════════${NC}\n"
    
    # Setup test environment
    setup

    export TOTAL_TESTS
    export PASSED_TESTS
    export FAILED_TESTS
    
    # Run test categories in subshells to prevent complete script failure
    test_user_privilege_checks
    test_tool_installation_checks
    test_user_interaction
    test_variable_checks
    test_file_directory_management
    test_string_operations
    test_network_operations
    test_logging
    test_download

    # Cleanup and print summary
    cleanup
    print_summary
    
    return $FAILED_TESTS
}

run_tests
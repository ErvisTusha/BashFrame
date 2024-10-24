#!/bin/bash

# Source the main script
source ./bashframe.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m'

declare -g TOTAL_TESTS=0
declare -g PASSED_TESTS=0
declare -g FAILED_TESTS=0

# Assert functions
assert_true() {
    local command="$1"
    local message="$2"
    local args="$3"
    
    let TOTAL_TESTS+=1
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}${BOLD}✓ PASS${NC}: $message (${CYAN}'$args'${NC}) ${GRAY}→${NC} Expected: ${GREEN}${BOLD}TRUE${NC}, Got: ${GREEN}${BOLD}TRUE${NC}"
        let PASSED_TESTS+=1
        return 0
    else
        echo -e "${RED}${BOLD}✗ FAIL${NC}: $message (${CYAN}'$args'${NC}) ${GRAY}→${NC} Expected: ${GREEN}${BOLD}TRUE${NC}, Got: ${RED}${BOLD}FALSE${NC}"
        let FAILED_TESTS+=1
        return 1
    fi
}

assert_false() {
    local command="$1"
    local message="$2"
    local args="$3"
    
    let TOTAL_TESTS+=1
    
    if ! eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}${BOLD}✓ PASS${NC}: $message (${CYAN}'$args'${NC}) ${GRAY}→${NC} Expected: ${GREEN}${BOLD}FALSE${NC}, Got: ${GREEN}${BOLD}FALSE${NC}"
        let PASSED_TESTS+=1
        return 0
    else
        echo -e "${RED}${BOLD}✗ FAIL${NC}: $message (${CYAN}'$args'${NC}) ${GRAY}→${NC} Expected: ${GREEN}${BOLD}FALSE${NC}, Got: ${RED}${BOLD}TRUE${NC}"
        let FAILED_TESTS+=1
        return 1
    fi
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="$3"
    
    let TOTAL_TESTS+=1
    
    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}${BOLD}✓ PASS${NC}: $message ${GRAY}→${NC} Expected: ${GREEN}${BOLD}'$expected'${NC}, Got: ${GREEN}${BOLD}'$actual'${NC}"
        let PASSED_TESTS+=1
        return 0
    else
        echo -e "${RED}${BOLD}✗ FAIL${NC}: $message ${GRAY}→${NC} Expected: ${GREEN}${BOLD}'$expected'${NC}, Got: ${BLUE}${BOLD}'$actual'${NC}"
        let FAILED_TESTS+=1
        return 1
    fi
}

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
        assert_true "IS_SUDO" "IS_SUDO for root user" "root"
    else
        assert_false "IS_SUDO" "IS_SUDO for non-root user" "non-root"
    fi
}

# 2. Tool and Installation Management Tests
test_tool_installation_checks() {
    echo -e "\n${YELLOW}${BOLD}2. Testing Tool Installation Checks...${NC}"
    
    assert_true "IS_INSTALLED 'ls'" "IS_INSTALLED for command" "ls"
    assert_false "IS_INSTALLED 'nonexistentcommand123'" "IS_INSTALLED for non-existent command" "nonexistentcommand123"
}

# 3. User Interaction Tests
test_user_interaction() {
    echo -e "\n${YELLOW}${BOLD}3. Testing User Interaction...${NC}"
    
    # Test ASK_USER with 'yes'
    echo "y" | assert_true "ASK_USER 'Test question?'" "ASK_USER for 'y'" "y"
    echo "Y" | assert_true "ASK_USER 'Test question?'" "ASK_USER for 'Y'" "Y"
    echo "" | assert_true "ASK_USER 'Test question?'" "ASK_USER for empty (default)" "default"
    
    # Test ASK_USER with 'no'
    echo "n" | assert_false "ASK_USER 'Test question?'" "ASK_USER for 'n'" "n"
    echo "N" | assert_false "ASK_USER 'Test question?'" "ASK_USER for 'N'" "N"
}

# 4. Variable Checks Tests
test_variable_checks() {
    echo -e "\n${YELLOW}${BOLD}4. Testing Variable Checks...${NC}"
    
    # Test IS_EMPTY
    assert_true "IS_EMPTY ''" "IS_EMPTY for empty string" ""
    assert_false "IS_EMPTY 'test'" "IS_EMPTY for non-empty string" "test"
    
    # Test IS_NUMBER
    assert_true "IS_NUMBER '123'" "IS_NUMBER for valid number" "123"
    assert_false "IS_NUMBER 'abc'" "IS_NUMBER for non-number" "abc"
    
    # Test IS_STRING
    assert_true "IS_STRING 'abc'" "IS_STRING for valid string" "abc"
    assert_false "IS_STRING '123'" "IS_STRING for non-string" "123"
    
    # Test VAL_EMAIL
    assert_true "VAL_EMAIL 'test@example.com'" "VAL_EMAIL for valid email" "test@example.com"
    assert_false "VAL_EMAIL 'invalid-email'" "VAL_EMAIL for invalid email" "invalid-email"
    
    # Test VAL_URL
    assert_true "VAL_URL 'https://example.com'" "VAL_URL for valid URL" "https://example.com"
    assert_false "VAL_URL 'invalid-url'" "VAL_URL for invalid URL" "invalid-url"
    
    # Test VAL_IP
    assert_true "VAL_IP '192.168.1.1'" "VAL_IP for valid IPv4" "192.168.1.1"
    assert_false "VAL_IP '256.256.256.256'" "VAL_IP for invalid IPv4" "256.256.256.256"
    
    # Test VAL_IPV6
    assert_true "VAL_IPV6 '2001:0db8:85a3:0000:0000:8a2e:0370:7334'" "VAL_IPV6 for valid IPv6" "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
    assert_false "VAL_IPV6 'invalid-ipv6'" "VAL_IPV6 for invalid IPv6" "invalid-ipv6"
    
    # Test VAL_MACADDR
    assert_true "VAL_MACADDR '00:11:22:33:44:55'" "VAL_MACADDR for valid MAC" "00:11:22:33:44:55"
    assert_false "VAL_MACADDR 'invalid-mac'" "VAL_MACADDR for invalid MAC" "invalid-mac"
}

# 5. File and Directory Management Tests
test_file_directory_management() {
    echo -e "\n${YELLOW}${BOLD}5. Testing File and Directory Management...${NC}"
    
    # Test FILE_EXISTS
    assert_true "FILE_EXISTS '$TEST_FILE'" "FILE_EXISTS for existing file" "$TEST_FILE"
    assert_false "FILE_EXISTS '$TEST_DIR/nonexistent'" "FILE_EXISTS for non-existent file" "$TEST_DIR/nonexistent"
    
    # Test DIR_EXISTS
    assert_true "DIR_EXISTS '$TEST_DIR'" "DIR_EXISTS for existing directory" "$TEST_DIR"
    assert_false "DIR_EXISTS '$TEST_DIR/nonexistent'" "DIR_EXISTS for non-existent directory" "$TEST_DIR/nonexistent"
    
    # Test FILE_EMPTY
    assert_false "FILE_EMPTY '$TEST_FILE'" "FILE_EMPTY for non-empty file" "$TEST_FILE"
    touch "$TEST_DIR/empty_file"
    assert_true "FILE_EMPTY '$TEST_DIR/empty_file'" "FILE_EMPTY for empty file" "$TEST_DIR/empty_file"
    
    # Test DIR_EMPTY
    assert_true "DIR_EMPTY '$TEST_DIR_EMPTY'" "DIR_EMPTY for empty directory" "$TEST_DIR_EMPTY"
    touch "$TEST_DIR_EMPTY/file"
    assert_false "DIR_EMPTY '$TEST_DIR_EMPTY'" "DIR_EMPTY for non-empty directory" "$TEST_DIR_EMPTY"
    
    # Test IS_WRITABLE
    assert_true "IS_WRITABLE '$TEST_FILE'" "IS_WRITABLE for writable file" "$TEST_FILE"
    chmod 444 "$TEST_FILE"
    assert_false "IS_WRITABLE '$TEST_FILE'" "IS_WRITABLE for non-writable file" "$TEST_FILE"
    
    # Test IS_READABLE
    assert_true "IS_READABLE '$TEST_FILE'" "IS_READABLE for readable file" "$TEST_FILE"
    chmod 000 "$TEST_FILE"
    assert_false "IS_READABLE '$TEST_FILE'" "IS_READABLE for non-readable file" "$TEST_FILE"
    
    # Test IS_EXECUTABLE
    chmod 755 "$TEST_FILE"
    assert_true "IS_EXECUTABLE '$TEST_FILE'" "IS_EXECUTABLE for executable file" "$TEST_FILE"
    chmod 644 "$TEST_FILE"
    assert_false "IS_EXECUTABLE '$TEST_FILE'" "IS_EXECUTABLE for non-executable file" "$TEST_FILE"
    
    # Test IS_OWNED_BY_USER
    current_user=$(whoami)
    assert_true "IS_OWNED_BY_USER '$TEST_FILE' '$current_user'" "IS_OWNED_BY_USER for current user" "$current_user"
    assert_false "IS_OWNED_BY_USER '$TEST_FILE' 'nonexistentuser'" "IS_OWNED_BY_USER for non-existent user" "nonexistentuser"
    
    # Test IS_OWNED_BY_GROUP
    current_group=$(id -gn)
    assert_true "IS_OWNED_BY_GROUP '$TEST_FILE' '$current_group'" "IS_OWNED_BY_GROUP for current group" "$current_group"
    assert_false "IS_OWNED_BY_GROUP '$TEST_FILE' 'nonexistentgroup'" "IS_OWNED_BY_GROUP for non-existent group" "nonexistentgroup"
    
    # Test IS_OLDER_THAN (might need adjustment based on file creation time)
    assert_false "IS_OLDER_THAN '$TEST_FILE' 1" "IS_OLDER_THAN for new file" "1 day"
}

# 6. String Operations Tests
test_string_operations() {
    echo -e "\n${YELLOW}${BOLD}6. Testing String Operations...${NC}"
    
    # Test GENERATE_RANDOM
    local random_num=$(GENERATE_RANDOM 10 "numbers")
    assert_true "[[ ${#random_num} -eq 10 ]]" "GENERATE_RANDOM should generate correct length for numbers" "10"
    assert_true "[[ $random_num =~ ^[0-9]+$ ]]" "GENERATE_RANDOM should generate only numbers" "$random_num"
    
    local random_str=$(GENERATE_RANDOM 10 "characters")
    assert_true "[[ ${#random_str} -eq 10 ]]" "GENERATE_RANDOM should generate correct length for characters" "10"
    assert_true "[[ $random_str =~ ^[a-zA-Z]+$ ]]" "GENERATE_RANDOM should generate only letters" "$random_str"
    
    local random_mixed=$(GENERATE_RANDOM 10 "mixed")
    assert_true "[[ ${#random_mixed} -eq 10 ]]" "GENERATE_RANDOM should generate correct length for mixed" "10"
    assert_true "[[ $random_mixed =~ ^[a-zA-Z0-9]+$ ]]" "GENERATE_RANDOM should generate alphanumeric characters" "$random_mixed"
    
    # Test STRING_LENGTH
    assert_equals "4" "$(STRING_LENGTH 'test')" "STRING_LENGTH should return correct length"
    assert_equals "0" "$(STRING_LENGTH '')" "STRING_LENGTH should return 0 for empty string"
}

# 7. Network Operations Tests
test_network_operations() {
    echo -e "\n${YELLOW}${BOLD}7. Testing Network Operations...${NC}"
    
    if command -v curl >/dev/null 2>&1; then
        local public_ip=$(GET_PUBLIC_IP)
        assert_true "VAL_IP '$public_ip'" "GET_PUBLIC_IP should return valid IPv4" "$public_ip"
    else
        echo -e "${YELLOW}Skipping GET_PUBLIC_IP test - curl not installed${NC}"
    fi
    
    if command -v ifconfig >/dev/null 2>&1; then
        local local_ip=$(GET_LOCAL_IP "lo")
        assert_true "VAL_IP '$local_ip'" "GET_LOCAL_IP should return valid IPv4" "$local_ip"
    else
        echo -e "${YELLOW}Skipping GET_LOCAL_IP test - ifconfig not installed${NC}"
    fi
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
    local log_file="/tmp/log/$SCRIPT.log"
    
    # Test INFO logging
    LOG "INFO" "Test info message"
    assert_true "grep -q 'INFO.*Test info message' '$log_file'" "LOG should write INFO message to log file" "INFO message"
    
    # Test WARNING logging
    LOG "WARNING" "Test warning message"
    assert_true "grep -q 'WARNING.*Test warning message' '$log_file'" "LOG should write WARNING message to log file" "WARNING message"
    
    # Test ERROR logging
    LOG "ERROR" "Test error message"
    assert_true "grep -q 'ERROR.*Test error message' '$log_file'" "LOG should write ERROR message to log file" "ERROR message"
    
    # Test DEBUG logging
    LOG_LEVEL="DEBUG"
    LOG "DEBUG" "Test debug message"
    assert_true "grep -q 'DEBUG.*Test debug message' '$log_file'" "LOG should write DEBUG message to log file" "DEBUG message"
    
    # Test invalid log level
    LOG_LEVEL="INVALID"
    assert_true "LOG 'WARNING' 'Invalid log level test'" "LOG should handle invalid log level gracefully" "Invalid log level"
    
    # Reset log level
    LOG_LEVEL="INFO"
}

# 9. Testing Error Handling
test_error_handling() {
    echo -e "\n${YELLOW}${BOLD}9. Testing Error Handling...${NC}"
    
    # Test handle_error without exit code
    local log_file="/tmp/log/$SCRIPT.log"
    handle_error "Test error message" > /dev/null 2>&1
    assert_true "grep -q 'ERROR.*Test error message' '$log_file'" "handle_error should log error message" "Error message logging"
    
    # Test handle_error with exit code (in subshell to prevent test script termination)
    (handle_error "Test error with exit" 1 > /dev/null 2>&1)
    assert_equals "1" "$?" "handle_error should exit with specified code"
}

# 10. Testing Download Function
test_download() {
    echo -e "\n${YELLOW}${BOLD}10. Testing Download Function...${NC}"
    
    local test_url="https://example.com/test.txt"
    local test_output="$TEST_DIR/downloaded_file"
    
    # Test with wget
    if command -v wget >/dev/null 2>&1; then
        DOWNLOAD "$test_url" "$test_output" > /dev/null 2>&1
        assert_true "[ -f '$test_output' ]" "DOWNLOAD should create output file with wget" "wget"
    else
        echo -e "${YELLOW}Skipping wget download test - wget not installed${NC}"
    fi
    
    # Test with curl
    if command -v curl >/dev/null 2>&1; then
        DOWNLOAD "$test_url" "$test_output" > /dev/null 2>&1
        assert_true "[ -f '$test_output' ]" "DOWNLOAD should create output file with curl" "curl"
    else
        echo -e "${YELLOW}Skipping curl download test - curl not installed${NC}"
    fi
    
    # Test with invalid output path
    assert_false "DOWNLOAD '$test_url' '/invalid/path' 2>/dev/null" "DOWNLOAD should fail with invalid output path" "invalid path"

    # Test with one argument
    assert_true "DOWNLOAD '$test_url' 2>/dev/null" "DOWNLOAD should succeed with one argument" "one argument"

    # Test with invalid URL
    assert_false "DOWNLOAD 'invalid-url' '$test_output' 2>/dev/null" "DOWNLOAD should fail with invalid URL" "invalid-url"
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
    test_error_handling
    test_download
    
    # Cleanup and print summary
    cleanup
    print_summary
    
    return $FAILED_TESTS
}



# Enhanced cleanup function
cleanup() {
    # Only cleanup if TEST_DIR exists and is a directory
    if [[ -d "${TEST_DIR:-}" ]]; then
        rm -rf "$TEST_DIR"
    fi
    
    # Clean up log files
    if [[ -d "/tmp/log" ]]; then
        rm -f "/tmp/log/$SCRIPT.log"
    fi
}


run_tests
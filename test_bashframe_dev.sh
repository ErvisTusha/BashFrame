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

# 1. Test IS_SUDO
test_user_privilege_checks() {
     echo -e "\n${YELLOW}${BOLD}1. Testing User and Privilege Checks...${NC}"
    
    if [[ $EUID -eq 0 ]]; then 
        assert_true "IS_SUDO" "User has root privileges" ""
    else
        assert_false "IS_SUDO" "User does not have root privileges" ""
    fi
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
   
    
    # Cleanup and print summary
    
    print_summary
    
    return $FAILED_TESTS
}



run_tests
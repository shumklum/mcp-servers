#!/bin/bash

# Main MCP Server Verification Script
# This script can verify individual MCP servers or all servers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFY_DIR="$SCRIPT_DIR/scripts/verify"

# Available servers
AVAILABLE_SERVERS=("github" "dockerhub" "memory" "context7" "shopify" "fetch" "bitbucket")

# Function to show usage
show_usage() {
    echo -e "${BLUE}MCP Server Verification Script${NC}"
    echo "Usage: $0 [server_name]"
    echo ""
    echo "Available servers:"
    for server in "${AVAILABLE_SERVERS[@]}"; do
        echo "  - $server"
    done
    echo ""
    echo "Examples:"
    echo "  $0 github          # Verify GitHub MCP server"
    echo "  $0 fetch           # Verify Fetch MCP server"
    echo "  $0 all             # Verify all MCP servers"
    echo "  $0                 # Show this help message"
    echo ""
    echo "Note: Use './run-all-tests.sh' for comprehensive testing with status reporting"
}

# Function to verify a single server
verify_server() {
    local server_name=$1
    local script_path="$VERIFY_DIR/verify-${server_name}-mcp.sh"
    
    if [ ! -f "$script_path" ]; then
        echo -e "${RED}❌ Verification script not found: $script_path${NC}"
        echo -e "${YELLOW}Available servers: ${AVAILABLE_SERVERS[*]}${NC}"
        exit 1
    fi
    
    if [ ! -x "$script_path" ]; then
        echo -e "${YELLOW}Making script executable: $script_path${NC}"
        chmod +x "$script_path"
    fi
    
    echo -e "${BLUE}🔍 Verifying $server_name MCP server...${NC}"
    echo "=================================="
    
    # Run the verification script
    if bash "$script_path"; then
        echo -e "${GREEN}✅ $server_name MCP server verification completed successfully${NC}"
    else
        echo -e "${RED}❌ $server_name MCP server verification failed${NC}"
        exit 1
    fi
}

# Function to verify all servers
verify_all() {
    echo -e "${BLUE}🧪 Verifying all MCP servers...${NC}"
    echo "=================================="
    
    local failed_servers=()
    local total_servers=${#AVAILABLE_SERVERS[@]}
    local passed_servers=0
    
    for server in "${AVAILABLE_SERVERS[@]}"; do
        echo ""
        echo -e "${BLUE}Testing: $server${NC}"
        echo "----------------------------------------"
        
        if verify_server "$server" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ $server: PASSED${NC}"
            ((passed_servers++))
        else
            echo -e "${RED}❌ $server: FAILED${NC}"
            failed_servers+=("$server")
        fi
    done
    
    echo ""
    echo "========================================="
    echo -e "${BLUE}📊 Summary${NC}"
    echo "========================================="
    echo -e "Total servers: ${BLUE}$total_servers${NC}"
    echo -e "Passed: ${GREEN}$passed_servers${NC}"
    echo -e "Failed: ${RED}${#failed_servers[@]}${NC}"
    
    if [ ${#failed_servers[@]} -gt 0 ]; then
        echo -e "${RED}Failed servers: ${failed_servers[*]}${NC}"
        echo -e "${YELLOW}Run individual tests for more details:${NC}"
        for server in "${failed_servers[@]}"; do
            echo "  $0 $server"
        done
        exit 1
    else
        echo -e "${GREEN}🎉 All servers passed!${NC}"
    fi
}

# Main script logic
if [ $# -eq 0 ]; then
    show_usage
    exit 0
fi

# Check if verify directory exists
if [ ! -d "$VERIFY_DIR" ]; then
    echo -e "${RED}❌ Verification scripts directory not found: $VERIFY_DIR${NC}"
    exit 1
fi

# Handle the argument
case "$1" in
    "all")
        verify_all
        ;;
    "help"|"-h"|"--help")
        show_usage
        ;;
    *)
        # Check if it's a valid server name
        if [[ " ${AVAILABLE_SERVERS[*]} " =~ " $1 " ]]; then
            verify_server "$1"
        else
            echo -e "${RED}❌ Unknown server: $1${NC}"
            echo -e "${YELLOW}Available servers: ${AVAILABLE_SERVERS[*]}${NC}"
            echo ""
            show_usage
            exit 1
        fi
        ;;
esac

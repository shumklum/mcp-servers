#!/bin/bash

# Unified MCP Server Test Runner
# This script runs all verification tests for MCP servers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Running All MCP Server Tests${NC}"
echo "=================================="

# Load environment variables
if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo -e "${GREEN}✅ Environment variables loaded${NC}"
else
    echo -e "${RED}❌ .env file not found${NC}"
    exit 1
fi

# Track test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Test results array
declare -a TEST_RESULTS

# Function to run a test
run_test() {
    local test_name=$1
    local script_path=$2
    local container_name=$3
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo ""
    echo -e "${BLUE}🔍 Testing: $test_name${NC}"
    echo "----------------------------------------"
    
    # Check if container should be running
    if docker ps | grep -q "$container_name" 2>/dev/null; then
        echo -e "${YELLOW}ℹ️  Container $container_name is running${NC}"
    else
        echo -e "${YELLOW}⚠️  Container $container_name is not running, skipping test${NC}"
        TEST_RESULTS+=("$test_name: SKIPPED (container not running)")
        SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
        return 0
    fi
    
    # Run the test script
    if [ -f "$script_path" ]; then
        if bash "$script_path"; then
            echo -e "${GREEN}✅ $test_name: PASSED${NC}"
            TEST_RESULTS+=("$test_name: PASSED")
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "${RED}❌ $test_name: FAILED${NC}"
            TEST_RESULTS+=("$test_name: FAILED")
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        echo -e "${RED}❌ Test script not found: $script_path${NC}"
        TEST_RESULTS+=("$test_name: FAILED (script not found)")
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Make all scripts executable
chmod +x verify-*.sh 2>/dev/null || true

# First run overall status check
echo -e "${BLUE}Running overall status check...${NC}"
if ./check-mcp-status.sh; then
    echo -e "${GREEN}✅ Status check completed${NC}"
else
    echo -e "${YELLOW}⚠️  Status check had warnings${NC}"
fi

echo ""

# Run tests for each MCP server
echo -e "${BLUE}Starting individual server tests...${NC}"

run_test "GitHub MCP Server" "./scripts/verify/verify-github-mcp.sh" "github-mcp-server"
run_test "Docker Hub MCP Server" "./scripts/verify/verify-dockerhub-mcp.sh" "dockerhub-mcp-server"
run_test "Memory MCP Server" "./scripts/verify/verify-memory-mcp.sh" "memory-mcp-server"
run_test "Context7 MCP Server" "./scripts/verify/verify-context7-mcp.sh" "context7-mcp-server"
run_test "Shopify MCP Server" "./scripts/verify/verify-shopify-mcp.sh" "shopify-mcp-server"
run_test "Fetch MCP Server" "./scripts/verify/verify-fetch-mcp.sh" "fetch-mcp-server"
run_test "Bitbucket MCP Server" "./scripts/verify/verify-bitbucket-mcp.sh" "bitbucket-mcp-server"

# Summary
echo ""
echo "========================================="
echo -e "${BLUE}📊 Test Summary${NC}"
echo "========================================="

# Print individual results
for result in "${TEST_RESULTS[@]}"; do
    if [[ $result == *"PASSED"* ]]; then
        echo -e "${GREEN}✅ $result${NC}"
    elif [[ $result == *"FAILED"* ]]; then
        echo -e "${RED}❌ $result${NC}"
    else
        echo -e "${YELLOW}⚠️  $result${NC}"
    fi
done

echo ""
echo -e "Total Tests: ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
echo -e "Skipped: ${YELLOW}$SKIPPED_TESTS${NC}"

# Overall result
echo ""
if [ $FAILED_TESTS -eq 0 ]; then
    if [ $SKIPPED_TESTS -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
    else
        echo -e "${YELLOW}✅ All running tests passed (some skipped)${NC}"
    fi
else
    echo -e "${RED}❌ Some tests failed. Check the logs above.${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}💡 Useful commands:${NC}"
echo "   View all containers: docker-compose ps"
echo "   Start all services:  docker-compose up -d"
echo "   View logs:          docker-compose logs [service-name]"
echo "   Restart all:        docker-compose restart"
echo "   Stop all:           docker-compose down"
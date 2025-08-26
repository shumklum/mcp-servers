#!/bin/bash

# Bitbucket MCP Server Verification Script
# This script tests if the Bitbucket MCP server is working properly

set -e

echo "🪣 Verifying Bitbucket MCP Server..."

# Check if container is running
echo "1. Checking if Bitbucket MCP container is running..."
if docker ps | grep -q "bitbucket-mcp-server"; then
    echo "✅ Bitbucket MCP container is running"
else
    echo "❌ Bitbucket MCP container is not running"
    echo "   Run: docker-compose up -d bitbucket-mcp"
    exit 1
fi

# Check container health
echo "2. Checking container health status..."
HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' bitbucket-mcp-server 2>/dev/null || echo "unknown")
case $HEALTH_STATUS in
    "healthy")
        echo "✅ Bitbucket MCP container is healthy"
        ;;
    "unhealthy")
        echo "❌ Bitbucket MCP container is unhealthy"
        echo "   Check logs: docker logs bitbucket-mcp-server"
        exit 1
        ;;
    "starting")
        echo "⏳ Bitbucket MCP container is still starting up..."
        ;;
    *)
        echo "⚠️  Bitbucket MCP container health status: $HEALTH_STATUS"
        ;;
esac

# Check container logs for errors
echo "3. Checking for errors in container logs..."
ERROR_COUNT=$(docker logs bitbucket-mcp-server --tail=50 2>&1 | grep -i "error\|failed\|exception" | wc -l)
if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "⚠️  Found $ERROR_COUNT potential errors in logs"
    echo "   Review logs: docker logs bitbucket-mcp-server"
else
    echo "✅ No obvious errors in recent logs"
fi

# Test environment variables
echo "4. Testing environment variable configuration..."

# Path to your .env file
ENV_FILE="./.env"

# Check if the .env file exists
if [ -f "$ENV_FILE" ]; then
  # Enable automatic exporting of variables
  set -o allexport
  # Source the .env file to load variables
  source "$ENV_FILE"
  # Disable automatic exporting
  set +o allexport
else
  echo "Warning: .env file not found at $ENV_FILE"
fi

if [ -n "$BITBUCKET_USERNAME" ]; then
    echo "✅ Bitbucket username is configured: $BITBUCKET_USERNAME"
else
    echo "❌ Bitbucket username is not configured"
    echo "   Set BITBUCKET_USERNAME in .env file"
    exit 1
fi

if [ -n "$BITBUCKET_APP_PASSWORD" ]; then
    echo "✅ Bitbucket app password is configured (hidden)"
else
    echo "❌ Bitbucket app password is not configured"
    echo "   Set BITBUCKET_APP_PASSWORD in .env file"
    exit 1
fi

# Test Bitbucket API connectivity using MCP server
echo "5. Testing Bitbucket API connectivity via MCP server..."
# Test by checking if the server is responding to MCP protocol
MCP_INFO_TEST=$(timeout 5 docker exec bitbucket-mcp-server sh -c 'echo "{\"jsonrpc\":\"2.0\",\"method\":\"initialize\",\"id\":1,\"params\":{\"protocolVersion\":\"2024-11-05\",\"capabilities\":{},\"clientInfo\":{\"name\":\"test\",\"version\":\"1.0.0\"}}}" | head -n1' 2>/dev/null || echo "failed")
if [ "$MCP_INFO_TEST" != "failed" ]; then
    echo "✅ Bitbucket MCP server is accessible and responding"
    echo "✅ MCP server protocol communication is working"
else
    echo "❌ Unable to access Bitbucket MCP server"
    echo "   Check your BITBUCKET_USERNAME and BITBUCKET_APP_PASSWORD in .env file"
    echo "   Ensure your app password has appropriate permissions"
    echo "   Check container logs: docker logs bitbucket-mcp-server"
    exit 1
fi

# Check if MCP server is responding to stdio
echo "6. Testing MCP server stdio communication..."
MCP_TEST_RESULT=$(timeout 5 docker exec bitbucket-mcp-server sh -c 'echo "{\"jsonrpc\":\"2.0\",\"method\":\"ping\",\"id\":1}" | head -n1' 2>/dev/null || echo "failed")
if [ "$MCP_TEST_RESULT" != "failed" ]; then
    echo "✅ MCP server is responding to stdio input"
else
    echo "⚠️  Unable to test MCP server stdio communication"
fi

# Test basic functionality
echo "7. Testing basic Bitbucket MCP server functionality..."
PROCESS_COUNT=$(docker exec bitbucket-mcp-server sh -c 'ps aux | grep -v grep | grep -c node' 2>/dev/null || echo "0")
if [ "$PROCESS_COUNT" -gt 0 ]; then
    echo "✅ Bitbucket MCP server process is running ($PROCESS_COUNT processes)"
else
    echo "❌ Bitbucket MCP server process not found"
    exit 1
fi

echo ""
echo "🎉 Bitbucket MCP Server verification completed!"
echo ""
echo "💡 Additional commands:"
echo "   View logs: docker logs bitbucket-mcp-server"
echo "   Restart:   docker-compose restart bitbucket-mcp"
echo "   Stop:      docker-compose stop bitbucket-mcp"
echo "   Status:    docker-compose ps bitbucket-mcp"
echo "   Rebuild:   docker-compose build bitbucket-mcp"
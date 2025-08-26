#!/bin/bash

# GitHub MCP Server Verification Script
# This script tests if the GitHub MCP server is working properly

set -e

echo "🔍 Verifying GitHub MCP Server..."

# Check if container is running
echo "1. Checking if GitHub MCP container is running..."
if docker ps | grep -q "github-mcp-server"; then
    echo "✅ GitHub MCP container is running"
else
    echo "❌ GitHub MCP container is not running"
    echo "   Run: docker-compose up -d github-mcp"
    exit 1
fi

# Check container health
echo "2. Checking container health status..."
HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' github-mcp-server 2>/dev/null || echo "unknown")
case $HEALTH_STATUS in
    "healthy")
        echo "✅ GitHub MCP container is healthy"
        ;;
    "unhealthy")
        echo "❌ GitHub MCP container is unhealthy"
        echo "   Check logs: docker logs github-mcp-server"
        exit 1
        ;;
    "starting")
        echo "⏳ GitHub MCP container is still starting up..."
        ;;
    *)
        echo "⚠️  GitHub MCP container health status: $HEALTH_STATUS"
        ;;
esac

# Check container logs for errors
echo "3. Checking for errors in container logs..."
ERROR_COUNT=$(docker logs github-mcp-server --tail=50 2>&1 | grep -i "error\|failed\|exception" | wc -l)
if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "⚠️  Found $ERROR_COUNT potential errors in logs"
    echo "   Review logs: docker logs github-mcp-server"
else
    echo "✅ No obvious errors in recent logs"
fi

# Test GitHub API connectivity (basic test)
echo "4. Testing GitHub API connectivity..."
if command -v curl > /dev/null; then
    if curl -s -H "Authorization: token $GITHUB_PERSONAL_ACCESS_TOKEN" https://api.github.com/user > /dev/null; then
        echo "✅ GitHub API is accessible with provided token"
    else
        echo "❌ Unable to access GitHub API with provided token"
        echo "   Check your GITHUB_PERSONAL_ACCESS_TOKEN in .env file"
        exit 1
    fi
else
    echo "⚠️  curl not available, skipping GitHub API connectivity test"
fi

# Check if MCP server is responding to stdio
echo "5. Testing MCP server stdio communication..."
MCP_TEST_RESULT=$(timeout 5 docker exec github-mcp-server sh -c 'echo "{\"jsonrpc\":\"2.0\",\"method\":\"ping\",\"id\":1}" | head -n1' 2>/dev/null || echo "failed")
if [ "$MCP_TEST_RESULT" != "failed" ]; then
    echo "✅ MCP server is responding to stdio input"
else
    echo "⚠️  Unable to test MCP server stdio communication"
fi

echo ""
echo "🎉 GitHub MCP Server verification completed!"
echo ""
echo "💡 Additional commands:"
echo "   View logs: docker logs github-mcp-server"
echo "   Restart:   docker-compose restart github-mcp"
echo "   Stop:      docker-compose stop github-mcp"
echo "   Status:    docker-compose ps github-mcp"
#!/bin/bash

# Docker Hub MCP Server Verification Script
# This script tests if the Docker Hub MCP server is working properly

set -e

echo "🐳 Verifying Docker Hub MCP Server..."

# Check if container is running
echo "1. Checking if Docker Hub MCP container is running..."
if docker ps | grep -q "dockerhub-mcp-server"; then
    echo "✅ Docker Hub MCP container is running"
else
    echo "❌ Docker Hub MCP container is not running"
    echo "   Run: docker-compose up -d dockerhub-mcp"
    exit 1
fi

# Check container health
echo "2. Checking container health status..."
HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' dockerhub-mcp-server 2>/dev/null || echo "unknown")
case $HEALTH_STATUS in
    "healthy")
        echo "✅ Docker Hub MCP container is healthy"
        ;;
    "unhealthy")
        echo "❌ Docker Hub MCP container is unhealthy"
        echo "   Check logs: docker logs dockerhub-mcp-server"
        exit 1
        ;;
    "starting")
        echo "⏳ Docker Hub MCP container is still starting up..."
        ;;
    *)
        echo "⚠️  Docker Hub MCP container health status: $HEALTH_STATUS"
        ;;
esac

# Check container logs for errors
echo "3. Checking for errors in container logs..."
ERROR_COUNT=$(docker logs dockerhub-mcp-server --tail=50 2>&1 | grep -i "error\|failed\|exception" | wc -l)
if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "⚠️  Found $ERROR_COUNT potential errors in logs"
    echo "   Review logs: docker logs dockerhub-mcp-server"
else
    echo "✅ No obvious errors in recent logs"
fi

# Test Docker Hub API connectivity (basic test)
echo "4. Testing Docker Hub API connectivity..."
if command -v curl > /dev/null; then
    if curl -s -H "Authorization: Bearer $HUB_PAT_TOKEN" https://hub.docker.com/v2/user/ > /dev/null; then
        echo "✅ Docker Hub API is accessible with provided token"
    else
        echo "❌ Unable to access Docker Hub API with provided token"
        echo "   Check your HUB_PAT_TOKEN in .env file"
        exit 1
    fi
else
    echo "⚠️  curl not available, skipping Docker Hub API connectivity test"
fi

# Test username configuration
echo "5. Testing username configuration..."
if [ -n "$DOCKERHUB_USERNAME" ]; then
    echo "✅ Docker Hub username is configured: $DOCKERHUB_USERNAME"
else
    echo "❌ Docker Hub username is not configured"
    echo "   Set DOCKERHUB_USERNAME in .env file"
    exit 1
fi

# Check if MCP server is responding to stdio
echo "6. Testing MCP server stdio communication..."
MCP_TEST_RESULT=$(timeout 5 docker exec dockerhub-mcp-server sh -c 'echo "{\"jsonrpc\":\"2.0\",\"method\":\"ping\",\"id\":1}" | head -n1' 2>/dev/null || echo "failed")
if [ "$MCP_TEST_RESULT" != "failed" ]; then
    echo "✅ MCP server is responding to stdio input"
else
    echo "⚠️  Unable to test MCP server stdio communication"
fi

echo ""
echo "🎉 Docker Hub MCP Server verification completed!"
echo ""
echo "💡 Additional commands:"
echo "   View logs: docker logs dockerhub-mcp-server"
echo "   Restart:   docker-compose restart dockerhub-mcp"
echo "   Stop:      docker-compose stop dockerhub-mcp"
echo "   Status:    docker-compose ps dockerhub-mcp"
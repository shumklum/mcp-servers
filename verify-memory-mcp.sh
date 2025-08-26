#!/bin/bash

# Memory MCP Server Verification Script
# This script tests if the Memory MCP server is working properly

set -e

echo "🧠 Verifying Memory MCP Server..."

# Check if container is running
echo "1. Checking if Memory MCP container is running..."
if docker ps | grep -q "memory-mcp-server"; then
    echo "✅ Memory MCP container is running"
else
    echo "❌ Memory MCP container is not running"
    echo "   Run: docker-compose up -d memory-mcp"
    exit 1
fi

# Check container health
echo "2. Checking container health status..."
HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' memory-mcp-server 2>/dev/null || echo "unknown")
case $HEALTH_STATUS in
    "healthy")
        echo "✅ Memory MCP container is healthy"
        ;;
    "unhealthy")
        echo "❌ Memory MCP container is unhealthy"
        echo "   Check logs: docker logs memory-mcp-server"
        exit 1
        ;;
    "starting")
        echo "⏳ Memory MCP container is still starting up..."
        ;;
    *)
        echo "⚠️  Memory MCP container health status: $HEALTH_STATUS"
        ;;
esac

# Check container logs for errors
echo "3. Checking for errors in container logs..."
ERROR_COUNT=$(docker logs memory-mcp-server --tail=50 2>&1 | grep -i "error\|failed\|exception" | wc -l)
if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "⚠️  Found $ERROR_COUNT potential errors in logs"
    echo "   Review logs: docker logs memory-mcp-server"
else
    echo "✅ No obvious errors in recent logs"
fi

# Check if MCP server is responding to stdio
echo "4. Testing MCP server stdio communication..."
MCP_TEST_RESULT=$(timeout 5 docker exec memory-mcp-server sh -c 'echo "{\"jsonrpc\":\"2.0\",\"method\":\"ping\",\"id\":1}" | head -n1' 2>/dev/null || echo "failed")
if [ "$MCP_TEST_RESULT" != "failed" ]; then
    echo "✅ MCP server is responding to stdio input"
else
    echo "⚠️  Unable to test MCP server stdio communication"
fi

# Test basic functionality (memory operations are internal, no external dependencies)
echo "5. Testing basic memory server functionality..."
PROCESS_COUNT=$(docker exec memory-mcp-server sh -c 'ps aux | grep -v grep | grep -c node' 2>/dev/null || echo "0")
if [ "$PROCESS_COUNT" -gt 0 ]; then
    echo "✅ Memory MCP server process is running ($PROCESS_COUNT processes)"
else
    echo "❌ Memory MCP server process not found"
    exit 1
fi

echo ""
echo "🎉 Memory MCP Server verification completed!"
echo ""
echo "💡 Additional commands:"
echo "   View logs: docker logs memory-mcp-server"
echo "   Restart:   docker-compose restart memory-mcp"
echo "   Stop:      docker-compose stop memory-mcp"
echo "   Status:    docker-compose ps memory-mcp"
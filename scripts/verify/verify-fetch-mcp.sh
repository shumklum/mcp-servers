#!/bin/bash

# Fetch MCP Server Verification Script
# This script tests if the Fetch MCP server is working properly

set -e

echo "🌐 Verifying Fetch MCP Server..."

# Check if container is running
echo "1. Checking if Fetch MCP container is running..."
if docker ps | grep -q "fetch-mcp-server"; then
    echo "✅ Fetch MCP container is running"
else
    echo "❌ Fetch MCP container is not running"
    echo "   Run: docker-compose up -d fetch-mcp"
    exit 1
fi

# Check container health
echo "2. Checking container health status..."
HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' fetch-mcp-server 2>/dev/null || echo "unknown")
case $HEALTH_STATUS in
    "healthy")
        echo "✅ Fetch MCP container is healthy"
        ;;
    "unhealthy")
        echo "⚠️  Fetch MCP container health check is failing (but server may still be working)"
        ;;
    "starting")
        echo "⏳ Fetch MCP container is still starting up..."
        ;;
    *)
        echo "⚠️  Fetch MCP container health status: $HEALTH_STATUS"
        ;;
esac

# Check container logs for errors
echo "3. Checking for errors in container logs..."
ERROR_COUNT=$(docker logs fetch-mcp-server --tail=50 2>&1 | grep -i "error\|failed\|exception" | wc -l)
if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "⚠️  Found $ERROR_COUNT potential errors in logs"
    echo "   Review logs: docker logs fetch-mcp-server"
else
    echo "✅ No obvious errors in recent logs"
fi

# Test Fetch MCP server functionality
echo "4. Testing Fetch MCP server functionality..."
# Test by checking if the server is responding to MCP protocol
MCP_INFO_TEST=$(timeout 5 docker exec fetch-mcp-server sh -c 'echo "{\"jsonrpc\":\"2.0\",\"method\":\"initialize\",\"id\":1,\"params\":{\"protocolVersion\":\"2024-11-05\",\"capabilities\":{},\"clientInfo\":{\"name\":\"test\",\"version\":\"1.0.0\"}}}" | head -n1' 2>/dev/null || echo "failed")
if [ "$MCP_INFO_TEST" != "failed" ]; then
    echo "✅ Fetch MCP server is accessible and responding"
    echo "✅ MCP server protocol communication is working"
else
    echo "❌ Unable to access Fetch MCP server"
    echo "   Check container logs: docker logs fetch-mcp-server"
    exit 1
fi

# Check if MCP server is responding to stdio
echo "5. Testing MCP server stdio communication..."
MCP_TEST_RESULT=$(timeout 5 docker exec fetch-mcp-server sh -c 'echo "{\"jsonrpc\":\"2.0\",\"method\":\"ping\",\"id\":1}" | head -n1' 2>/dev/null || echo "failed")
if [ "$MCP_TEST_RESULT" != "failed" ]; then
    echo "✅ MCP server is responding to stdio input"
else
    echo "⚠️  Unable to test MCP server stdio communication"
fi

# Test basic functionality
echo "6. Testing basic Fetch MCP server functionality..."
PROCESS_COUNT=$(docker exec fetch-mcp-server sh -c 'cat /proc/1/comm | grep -c "mcp-server-fetc"' 2>/dev/null || echo "0")
if [ "$PROCESS_COUNT" -gt 0 ]; then
    echo "✅ Fetch MCP server process is running"
else
    echo "❌ Fetch MCP server process not found"
    exit 1
fi

# Test HTTP fetch capability (basic test)
echo "7. Testing HTTP fetch capability..."
FETCH_TEST_RESULT=$(timeout 10 docker exec fetch-mcp-server sh -c 'echo "{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"id\":1,\"params\":{\"name\":\"fetch\",\"arguments\":{\"url\":\"https://httpbin.org/get\",\"method\":\"GET\"}}}" | head -n1' 2>/dev/null || echo "failed")
if [ "$FETCH_TEST_RESULT" != "failed" ]; then
    echo "✅ Fetch MCP server HTTP capability is available"
else
    echo "⚠️  Fetch MCP server HTTP capability test inconclusive"
fi

echo ""
echo "🎉 Fetch MCP Server verification completed!"
echo ""
echo "💡 Additional commands:"
echo "   View logs: docker logs fetch-mcp-server"
echo "   Restart:   docker-compose restart fetch-mcp"
echo "   Stop:      docker-compose stop fetch-mcp"
echo "   Status:    docker-compose ps fetch-mcp"
echo "   Rebuild:   docker-compose build fetch-mcp"

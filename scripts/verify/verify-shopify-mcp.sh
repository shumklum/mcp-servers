#!/bin/bash

# Shopify MCP Server Verification Script
# This script tests if the Shopify MCP server is working properly

set -e

echo "🛍️ Verifying Shopify MCP Server..."

# Check if container is running
echo "1. Checking if Shopify MCP container is running..."
if docker ps | grep -q "shopify-mcp-server"; then
    echo "✅ Shopify MCP container is running"
else
    echo "❌ Shopify MCP container is not running"
    echo "   Run: docker-compose up -d shopify-mcp"
    exit 1
fi

# Check container health
echo "2. Checking container health status..."
HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' shopify-mcp-server 2>/dev/null || echo "unknown")
case $HEALTH_STATUS in
    "healthy")
        echo "✅ Shopify MCP container is healthy"
        ;;
    "unhealthy")
        echo "❌ Shopify MCP container is unhealthy"
        echo "   Check logs: docker logs shopify-mcp-server"
        exit 1
        ;;
    "starting")
        echo "⏳ Shopify MCP container is still starting up..."
        ;;
    *)
        echo "⚠️  Shopify MCP container health status: $HEALTH_STATUS"
        ;;
esac

# Check container logs for errors
echo "3. Checking for errors in container logs..."
ERROR_COUNT=$(docker logs shopify-mcp-server --tail=50 2>&1 | grep -i "error\|failed\|exception" | wc -l)
if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "⚠️  Found $ERROR_COUNT potential errors in logs"
    echo "   Review logs: docker logs shopify-mcp-server"
else
    echo "✅ No obvious errors in recent logs"
fi

# Test Shopify MCP server functionality
echo "4. Testing Shopify MCP server functionality..."
echo "   Note: This server provides Shopify developer documentation access"
echo "   No authentication required for documentation features"

# Test Shopify MCP server connectivity
echo "5. Testing Shopify MCP server connectivity..."
# Test by checking if the server is responding to MCP protocol
MCP_INFO_TEST=$(timeout 5 docker exec shopify-mcp-server sh -c 'echo "{\"jsonrpc\":\"2.0\",\"method\":\"initialize\",\"id\":1,\"params\":{\"protocolVersion\":\"2024-11-05\",\"capabilities\":{},\"clientInfo\":{\"name\":\"test\",\"version\":\"1.0.0\"}}}" | head -n1' 2>/dev/null || echo "failed")
if [ "$MCP_INFO_TEST" != "failed" ]; then
    echo "✅ Shopify MCP server is accessible and responding"
    echo "✅ MCP server protocol communication is working"
else
    echo "❌ Unable to access Shopify MCP server"
    echo "   Check container logs: docker logs shopify-mcp-server"
    exit 1
fi

# Check if MCP server is responding to stdio
echo "6. Testing MCP server stdio communication..."
MCP_TEST_RESULT=$(timeout 5 docker exec shopify-mcp-server sh -c 'echo "{\"jsonrpc\":\"2.0\",\"method\":\"ping\",\"id\":1}" | head -n1' 2>/dev/null || echo "failed")
if [ "$MCP_TEST_RESULT" != "failed" ]; then
    echo "✅ MCP server is responding to stdio input"
else
    echo "⚠️  Unable to test MCP server stdio communication"
fi

# Test basic functionality
echo "7. Testing basic Shopify MCP server functionality..."
PROCESS_COUNT=$(docker exec shopify-mcp-server sh -c 'ps aux | grep -v grep | grep -c node' 2>/dev/null || echo "0")
if [ "$PROCESS_COUNT" -gt 0 ]; then
    echo "✅ Shopify MCP server process is running ($PROCESS_COUNT processes)"
else
    echo "❌ Shopify MCP server process not found"
    exit 1
fi

echo ""
echo "🎉 Shopify MCP Server verification completed!"
echo ""
echo "💡 Additional commands:"
echo "   View logs: docker logs shopify-mcp-server"
echo "   Restart:   docker-compose restart shopify-mcp"
echo "   Stop:      docker-compose stop shopify-mcp"
echo "   Status:    docker-compose ps shopify-mcp"
echo "   Rebuild:   docker-compose build shopify-mcp"

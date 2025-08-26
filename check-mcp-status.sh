#!/bin/bash

# Quick MCP Server Status Check
# Shows status of all MCP servers

echo "📊 MCP Server Status Overview"
echo "================================"

# Check Docker Compose services
echo "🐳 Docker Compose Services:"
docker-compose ps

echo ""
echo "🔍 Container Health Status:"
for container in github-mcp-server dockerhub-mcp-server memory-mcp-server context7-mcp-server shopify-mcp-server fetch-mcp-server bitbucket-mcp-server; do
    if docker ps --format "table {{.Names}}" | grep -q "$container"; then
        health=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "no-healthcheck")
        status=$(docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null || echo "unknown")
        echo "  $container: $status ($health)"
    else
        echo "  $container: not running"
    fi
done

echo ""
echo "💡 Quick Commands:"
echo "  Full verification: ./verify-github-mcp.sh"
echo "  View logs:        docker-compose logs [service-name]"
echo "  Restart all:      docker-compose restart"
echo "  Stop all:         docker-compose down"
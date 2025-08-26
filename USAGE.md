# MCP Server Usage Guide

This document explains how to use the MCP servers configured in this project in other development environments like VSCode or Cursor working on different code repositories.

## Available MCP Servers

This project manages the following MCP servers:

| Server | Container Name | Description | External Dependencies |
|--------|----------------|-------------|---------------------|
| **GitHub** | `github-mcp-server` | GitHub API integration for repos, issues, PRs | GitHub Personal Access Token |
| **Docker Hub** | `dockerhub-mcp-server` | Docker Hub API integration | Docker Hub PAT + Username |
| **Memory** | `memory-mcp-server` | In-memory storage and retrieval | None |
| **Context7** | `context7-mcp-server` | Context management and tracking | None |

## Quick Start

1. **Start all servers:**
   ```bash
   docker-compose up -d
   ```

2. **Verify servers are working:**
   ```bash
   ./run-all-tests.sh
   ```

3. **Check status:**
   ```bash
   ./check-mcp-status.sh
   ```

## Using MCP Servers in Other Projects

### Method 1: Direct Container Communication

If your other project is also running in Docker, you can connect to the MCP network:

```yaml
# In your other project's docker-compose.yml
version: '3.8'
services:
  your-app:
    # ... your app configuration
    networks:
      - mcp-servers_mcp-network  # Connect to the MCP network

networks:
  mcp-servers_mcp-network:
    external: true  # Use the external network from mcp-servers
```

### Method 2: Claude Code Configuration

For VSCode/Cursor with Claude Code extension, configure MCP servers in your Claude settings:

#### 1. GitHub MCP Server
```json
{
  "name": "github",
  "command": "docker",
  "args": [
    "exec", "-i", 
    "github-mcp-server", 
    "/server/github-mcp-server"
  ],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "your_github_token_here"
  }
}
```

#### 2. Docker Hub MCP Server  
```json
{
  "name": "dockerhub",
  "command": "docker",
  "args": [
    "exec", "-i",
    "dockerhub-mcp-server",
    "node", "dist/index.js",
    "--transport=stdio",
    "--username=your_dockerhub_username"
  ],
  "env": {
    "HUB_PAT_TOKEN": "your_docker_hub_token_here"
  }
}
```

#### 3. Memory MCP Server
```json
{
  "name": "memory",
  "command": "docker",
  "args": [
    "exec", "-i",
    "memory-mcp-server",
    "node", "/app/dist/index.js"
  ]
}
```

#### 4. Context7 MCP Server
```json
{
  "name": "context7", 
  "command": "docker",
  "args": [
    "exec", "-i",
    "context7-mcp-server",
    "node", "/app/dist/index.js"
  ]
}
```

### Method 3: Direct Binary Execution

If you want to run MCP servers directly without Docker:

1. **Install the MCP servers locally:**
   ```bash
   # GitHub MCP Server
   npm install -g @github/github-mcp-server
   
   # Docker Hub MCP Server  
   npm install -g @mcp/dockerhub
   
   # Memory MCP Server
   npm install -g @mcp/memory
   
   # Context7 MCP Server
   npm install -g @mcp/context7
   ```

2. **Configure in Claude Code:**
   ```json
   [
     {
       "name": "github",
       "command": "github-mcp-server",
       "env": {
         "GITHUB_PERSONAL_ACCESS_TOKEN": "your_token"
       }
     },
     {
       "name": "memory", 
       "command": "mcp-server-memory"
     }
   ]
   ```

## Environment Variables

Create a `.env` file in your project with the required tokens:

```bash
# GitHub MCP Server
GITHUB_PERSONAL_ACCESS_TOKEN=github_pat_your_token_here

# Docker Hub MCP Server
HUB_PAT_TOKEN=dckr_pat_your_token_here
DOCKERHUB_USERNAME=your_dockerhub_username

# Optional: Logging
GITHUB_MCP_LOG_LEVEL=info
```

## Server Capabilities

### GitHub MCP Server
- Repository management (create, clone, search)
- Issue management (create, update, search)
- Pull request operations
- Actions workflow management
- Code security scanning

### Docker Hub MCP Server
- Image search and information
- Repository management
- Tag operations
- Registry interactions

### Memory MCP Server
- Temporary data storage
- Session memory management
- Key-value operations
- Data persistence across requests

### Context7 MCP Server
- Context tracking and management
- Conversation history
- Context switching
- State management

## Networking and Ports

The MCP servers communicate via stdio (standard input/output) and don't expose HTTP ports. They run on an internal Docker network (`mcp-network`) for inter-container communication.

## Troubleshooting

### Common Issues

1. **Container not starting:**
   ```bash
   docker logs [container-name]
   docker-compose restart [service-name]
   ```

2. **Permission denied errors:**
   ```bash
   # Fix script permissions
   chmod +x *.sh
   ```

3. **Network connectivity:**
   ```bash
   # Recreate network
   docker-compose down
   docker-compose up -d
   ```

4. **Token/Authentication issues:**
   ```bash
   # Verify tokens in .env file
   cat .env
   # Test API connectivity
   ./verify-github-mcp.sh
   ```

### Verification Scripts

Each server has a dedicated verification script:
- `./verify-github-mcp.sh` - GitHub server tests
- `./verify-dockerhub-mcp.sh` - Docker Hub server tests  
- `./verify-memory-mcp.sh` - Memory server tests
- `./verify-context7-mcp.sh` - Context7 server tests
- `./run-all-tests.sh` - All servers comprehensive test

## Advanced Configuration

### Custom Network Configuration

To use a custom network name:

```yaml
networks:
  custom-mcp-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### Resource Limits

Add resource constraints:

```yaml
services:
  github-mcp:
    # ... existing config
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          memory: 256M
```

### Persistent Storage

For servers that need data persistence:

```yaml
volumes:
  mcp-data:
    driver: local

services:
  memory-mcp:
    # ... existing config  
    volumes:
      - mcp-data:/data
```

## Security Considerations

1. **Token Management:** Store tokens securely, never commit to version control
2. **Network Isolation:** Use Docker networks to isolate MCP traffic
3. **Access Control:** Limit container permissions and capabilities
4. **Regular Updates:** Keep MCP server images updated

## Support

For issues with:
- **This setup:** Check logs with `docker logs [container-name]`
- **MCP protocol:** Refer to the [MCP specification](https://modelcontextprotocol.io)
- **Individual servers:** Check the respective GitHub repositories
- **Claude Code:** Use the built-in help or GitHub issues
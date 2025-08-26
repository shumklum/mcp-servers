# [Server Name] MCP Server Template

This is a template for dockerizing MCP servers. Replace this content with server-specific information.

## Package Information

- **Package Manager:** [npm/pip/go/cargo]
- **Package Name:** [package-name]
- **GitHub Repository:** [github-url]
- **Author:** [author-name]

## Features

- [List key features of the MCP server]
- [Integration capabilities]
- [Supported operations]

## Environment Variables

The following environment variables are required/optional:

- `REQUIRED_VAR` - Description of required variable
- `OPTIONAL_VAR` - Description of optional variable (default: value)

## Configuration

### Authentication Setup

1. [Step-by-step authentication setup]
2. [API key/token generation]
3. [Permission requirements]

## Usage

This image is integrated into the main docker-compose.yaml file and can be used with:

```bash
# Start the server
docker-compose up -d [server-name]-mcp

# Test the server  
./verify-[server-name]-mcp.sh

# View logs
docker logs [server-name]-mcp-server

# Rebuild image
docker-compose build [server-name]-mcp
```

## Troubleshooting

### Common Issues

1. **Issue description**
   - Cause: Explanation
   - Solution: Steps to resolve

2. **Another common issue**
   - Cause: Explanation  
   - Solution: Steps to resolve

### Debug Commands

```bash
# Check container status
docker-compose ps [server-name]-mcp

# View detailed logs
docker logs [server-name]-mcp-server --tail=100

# Execute shell in container
docker exec -it [server-name]-mcp-server sh

# Test API connectivity manually
curl -H "Authorization: Bearer $TOKEN" https://api.service.com/test
```
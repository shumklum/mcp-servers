# Dockerizing Custom MCP Servers

This directory contains Docker configurations for MCP servers that aren't yet available in the official Docker Hub MCP Catalog.

## Directory Structure

```
dockerized/
├── README.md                    # This file
├── TEMPLATE/                    # Template for new MCP servers
│   ├── Dockerfile
│   └── README.md
└── [server-name]-mcp/           # Individual MCP server directories
    ├── Dockerfile
    └── README.md
```

## How to Add a New MCP Server

### 1. Research the MCP Server

First, identify the package manager and installation method:
- **Node.js/npm**: Look for `npm install -g @author/package-name`
- **Python/pip**: Look for `pip install package-name`
- **Go**: Look for `go install github.com/author/repo@latest`
- **Rust/cargo**: Look for `cargo install package-name`

### 2. Create Directory Structure

```bash
mkdir -p dockerized/[server-name]-mcp
cd dockerized/[server-name]-mcp
```

### 3. Create Dockerfile

Use the appropriate base image and package manager:

#### Node.js Example:
```dockerfile
FROM node:18-alpine
WORKDIR /app
RUN npm install -g @author/mcp-server-package
RUN addgroup -g 1001 -S mcp && adduser -S mcp -u 1001 -G mcp
USER mcp
CMD ["mcp-server-command"]
```

#### Python Example:
```dockerfile
FROM python:3.11-alpine
WORKDIR /app
RUN pip install package-name
RUN addgroup -g 1001 -S mcp && adduser -S mcp -u 1001 -G mcp
USER mcp
CMD ["mcp-server-command"]
```

### 4. Add to Docker Compose

Add the service to `docker-compose.yaml`:

```yaml
  # [Server Name] MCP Server (Custom Build)
  [server-name]-mcp:
    build:
      context: ./dockerized/[server-name]-mcp
      dockerfile: Dockerfile
    container_name: [server-name]-mcp-server
    stdin_open: true
    tty: false
    environment:
      - ENV_VAR_1=${ENV_VAR_1}
      - ENV_VAR_2=${ENV_VAR_2}
    restart: unless-stopped
    networks:
      - mcp-network
    healthcheck:
      test: ["CMD", "ps", "aux"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
```

### 5. Create Verification Script

Create `verify-[server-name]-mcp.sh`:

```bash
#!/bin/bash
set -e
echo "🔍 Verifying [Server Name] MCP Server..."

# Standard verification steps:
# 1. Container running check
# 2. Health status check  
# 3. Log error check
# 4. Environment variables check
# 5. API connectivity (if applicable)
# 6. MCP stdio communication test
# 7. Process verification
```

### 6. Update Configuration Files

1. **Add environment variables** to `.env.example`
2. **Update test runner** in `run-all-tests.sh`
3. **Update status checker** in `check-mcp-status.sh`
4. **Update documentation** in `README.md`

### 7. Build and Test

```bash
# Build the new service
docker-compose build [server-name]-mcp

# Start the service
docker-compose up -d [server-name]-mcp

# Run verification
./verify-[server-name]-mcp.sh

# Run all tests
./run-all-tests.sh
```

## Common Dockerfile Patterns

### Security Best Practices

```dockerfile
# Always use non-root user
RUN addgroup -g 1001 -S mcp && \
    adduser -S mcp -u 1001 -G mcp
USER mcp

# Use specific version tags
FROM node:18-alpine  # not "latest"
```

### Multi-stage Builds (if needed)

```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /build
RUN npm install -g package-name

# Runtime stage
FROM node:18-alpine
COPY --from=builder /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=builder /usr/local/bin /usr/local/bin
USER mcp
CMD ["command"]
```

### Environment Variable Handling

```dockerfile
# Set default values
ENV SERVER_PORT=3000
ENV LOG_LEVEL=info

# Or require them to be set
# (validation should be in verification script)
```

## Troubleshooting

### Build Issues

1. **Package not found**: Verify package name and registry
2. **Permission denied**: Ensure non-root user setup
3. **Build context**: Check Dockerfile location relative to docker-compose.yaml

### Runtime Issues

1. **Container exits immediately**: Check CMD and entrypoint
2. **Environment variables**: Verify .env file and docker-compose config
3. **Network connectivity**: Ensure container is on mcp-network

### Testing Issues

1. **Verification script fails**: Check container name matches script
2. **API tests fail**: Verify credentials and API endpoints
3. **Health check fails**: Adjust health check command if needed

## Examples

See existing implementations:
- `bitbucket-mcp/` - Node.js npm package example
- Future additions will follow the same pattern

## Contributing

When adding a new MCP server:
1. Follow the directory structure above
2. Include comprehensive verification script
3. Update all relevant configuration files
4. Test thoroughly before committing
5. Document any special requirements
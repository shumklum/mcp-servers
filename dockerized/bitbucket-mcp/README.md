# Bitbucket MCP Server Docker Image

This directory contains the Docker configuration for the Atlassian Bitbucket MCP Server.

## Package Information

- **NPM Package:** `@aashari/mcp-server-atlassian-bitbucket`
- **GitHub Repository:** https://github.com/aashari/mcp-server-atlassian-bitbucket
- **Author:** @aashari

## Features

- List Bitbucket workspaces and repositories
- Manage pull requests
- Search code through natural language
- Direct AI integration with version control workflows

## Environment Variables

The following environment variables are required:

- `BITBUCKET_USERNAME` - Your Bitbucket username
- `BITBUCKET_APP_PASSWORD` - Bitbucket App Password (not your account password)
- `BITBUCKET_DEFAULT_WORKSPACE` - The BitBucket workspace your working in

## Configuration

### Creating Bitbucket App Password

1. Go to Bitbucket Settings → Personal Bitbucket settings → App passwords
2. Create a new app password with appropriate permissions:
   - Repositories: Read, Write (as needed)
   - Pull requests: Read, Write (as needed)
   - Account: Read

## Usage

This image is integrated into the main docker-compose.yaml file and can be used with:

```bash
# Start the server
docker-compose up -d bitbucket-mcp

# Test the server
./verify-bitbucket-mcp.sh

# View logs
docker logs bitbucket-mcp-server
```
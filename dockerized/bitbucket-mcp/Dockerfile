FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install the MCP server globally
RUN npm install -g @aashari/mcp-server-atlassian-bitbucket

# Create a non-root user for security
RUN addgroup -g 1001 -S mcp && \
    adduser -S mcp -u 1001 -G mcp

# Switch to non-root user
USER mcp

# Set up stdio transport
STOPSIGNAL SIGTERM

# Default command to run the MCP server
ENTRYPOINT [ "npx","-y","@aashari/mcp-server-atlassian-bitbucket" ]
# Template Dockerfile for MCP Servers
# Replace [PACKAGE_MANAGER], [PACKAGE_NAME], and [COMMAND] with actual values

FROM node:18-alpine
# Alternative base images:
# FROM python:3.11-alpine
# FROM golang:1.21-alpine
# FROM rust:1.70-alpine

# Set working directory
WORKDIR /app

# Install the MCP server package
RUN npm install -g [PACKAGE_NAME]
# Alternatives:
# RUN pip install [PACKAGE_NAME]
# RUN go install github.com/[AUTHOR]/[REPO]@latest
# RUN cargo install [PACKAGE_NAME]

# Create a non-root user for security
RUN addgroup -g 1001 -S mcp && \
    adduser -S mcp -u 1001 -G mcp

# Switch to non-root user
USER mcp

# Set up stdio transport
STOPSIGNAL SIGTERM

# Default command to run the MCP server
CMD ["[COMMAND]"]
# Examples:
# CMD ["mcp-server-name"]
# CMD ["python", "-m", "package_name"]
# CMD ["/go/bin/binary-name"]
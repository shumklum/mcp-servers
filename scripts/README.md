# Scripts Directory

This directory contains organized scripts for managing and testing MCP servers.

## Directory Structure

```
scripts/
├── README.md              # This file
└── verify/                # Verification scripts for individual MCP servers
    ├── verify-github-mcp.sh
    ├── verify-dockerhub-mcp.sh
    ├── verify-memory-mcp.sh
    ├── verify-context7-mcp.sh
    ├── verify-shopify-mcp.sh
    ├── verify-fetch-mcp.sh
    └── verify-bitbucket-mcp.sh
```

## Verification Scripts

All verification scripts are located in the `verify/` subdirectory. These scripts perform comprehensive testing of individual MCP servers including:

- Container status and health checks
- Environment variable validation
- API connectivity testing
- MCP protocol communication
- Process monitoring
- Error log analysis

## Usage

### Individual Server Testing
```bash
# From the project root
./scripts/verify/verify-github-mcp.sh
./scripts/verify/verify-fetch-mcp.sh
```

### Using the Main Verification Script
```bash
# From the project root
./verify.sh github          # Test GitHub server
./verify.sh fetch           # Test Fetch server
./verify.sh all             # Test all servers
./verify.sh                 # Show help
```

### Comprehensive Testing
```bash
# From the project root
./run-all-tests.sh          # Comprehensive testing with status reporting
```

## Adding New Verification Scripts

When adding a new MCP server:

1. Create the verification script in `scripts/verify/`
2. Name it `verify-[server-name]-mcp.sh`
3. Make it executable: `chmod +x scripts/verify/verify-[server-name]-mcp.sh`
4. Update the main `verify.sh` script to include the new server
5. Update `run-all-tests.sh` to reference the new script
6. Update documentation in the main README.md and USAGE.md

## Script Standards

All verification scripts should:

- Use consistent error handling and exit codes
- Provide clear, colored output
- Include comprehensive testing of server functionality
- Follow the same structure and naming conventions
- Be executable and self-contained

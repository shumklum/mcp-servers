# MCP Server Management

A Docker Compose project for managing Multiple Context Protocol (MCP) servers with comprehensive verification and testing.

## 🚀 Quick Start

1. **Setup environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your tokens
   ```

2. **Start all servers:**
   ```bash
   docker-compose up -d
   ```

3. **Verify everything is working:**
   ```bash
   ./run-all-tests.sh
   ```

## 🗂️ Available MCP Servers

| Server | Description | Status |
|--------|-------------|--------|
| **GitHub** | GitHub API integration (repos, issues, PRs) | ✅ Active |
| **Docker Hub** | Docker Hub API integration | ✅ Active |
| **Memory** | In-memory storage and retrieval | ✅ Active |
| **Context7** | Context management and tracking | ✅ Active |
| **Shopify** | Shopify developer documentation access | ✅ Active |
| **Fetch** | HTTP/HTTPS request capabilities | ✅ Active |
| **Bitbucket** | Bitbucket API integration (custom build) | ✅ Active |

## 🔧 Management Commands

- `./run-all-tests.sh` - Comprehensive testing of all servers
- `./check-mcp-status.sh` - Quick status overview
- `./verify.sh [server]` - Test individual or all servers
  - `./verify.sh github` - Test GitHub server
  - `./verify.sh dockerhub` - Test Docker Hub server
  - `./verify.sh memory` - Test Memory server
  - `./verify.sh context7` - Test Context7 server
  - `./verify.sh shopify` - Test Shopify server
  - `./verify.sh fetch` - Test Fetch server
  - `./verify.sh bitbucket` - Test Bitbucket server
  - `./verify.sh all` - Test all servers

## 📚 Documentation

See [USAGE.md](USAGE.md) for detailed instructions on:
- Using MCP servers in other projects (VSCode/Cursor)
- Claude Code configuration examples
- Troubleshooting and networking
- Security considerations

## 🛠️ Development

### Prerequisites
- Docker & Docker Compose
- Required API tokens (see .env.example)

### Environment Setup
```bash
# Required tokens
GITHUB_PERSONAL_ACCESS_TOKEN=your_token_here
HUB_PAT_TOKEN=your_docker_hub_token
DOCKERHUB_USERNAME=your_username
BITBUCKET_USERNAME=your_bitbucket_username
BITBUCKET_APP_PASSWORD=your_bitbucket_app_password
BITBUCKET_DEFAULT_WORKSPACE=your_bitbucket_workspace

# Optional
GITHUB_MCP_LOG_LEVEL=info
```

### Testing
All servers include health checks and comprehensive verification:
- Container status monitoring
- API connectivity testing
- MCP protocol communication
- Error log analysis

## 🔒 Security

- Tokens are stored in `.env` (excluded from git)
- Containers run with minimal privileges
- Network isolation via Docker networks
- No exposed ports (stdio communication only)

## 📋 Requirements

- Docker Engine 20.10+
- Docker Compose 2.0+
- GitHub Personal Access Token (for GitHub MCP)
- Docker Hub Personal Access Token (for Docker Hub MCP)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add/modify MCP server configurations
4. Update tests and documentation
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details
# Claude Development Environment - Workspace Context

This workspace is a Coder development environment with integrated secrets management and deployment patterns. Claude Code is pre-configured to understand and work with this system.

## Secrets Management System

### Infisical Integration
- **Primary**: Environment variables injected by Infisical
- **Access**: Secrets are available as standard environment variables
- **No Helper Needed**: Direct access via `$VARIABLE_NAME`

### Available API Keys
The following secrets are dynamically configured in this workspace:

#### Core Secrets
- **ANTHROPIC_API_KEY** - Your Claude Code authentication (required)
- **GITHUB_TOKEN** - GitHub CLI and MCP integration (optional)
- **TAVILY_API_KEY** - Web search capabilities (optional) 
- **MORPHLLM_API_KEY** - Alternative LLM access (optional)

#### Usage in Code
```bash
# Access secrets directly from environment
API_KEY="$ANTHROPIC_API_KEY"

# Check if optional secrets are available
if [ -n "$GITHUB_TOKEN" ]; then
    echo "GitHub integration available"
fi
```

### Secrets Commands
- `env | grep -E 'ANTHROPIC|GITHUB|TAVILY'` - View available secrets
- `gh auth status` - Check GitHub authentication
- `claude-auth` - Comprehensive authentication testing

## Development Patterns

### Available Patterns
The workspace supports these development patterns via the `DEV_PATTERN` environment variable:

1. **none** - Clean workspace (default)
2. **laravel-standard** - PHP Laravel framework with standard tools
3. **python-api** - Python FastAPI/Flask development setup
4. **python-data** - Python data science and analytics setup
5. **node-fullstack** - Node.js with React/Vue frontend development

### Pattern Configuration
Patterns are mounted at `/patterns/` and integrated during workspace startup.

### Development Services
Pre-configured service endpoints available:
- **PostgreSQL**: `$DEV_POSTGRES_HOST:$DEV_POSTGRES_PORT` (host.docker.internal:5432)
- **MySQL**: `$DEV_MYSQL_HOST:$DEV_MYSQL_PORT` (host.docker.internal:3306)  
- **Redis**: `$DEV_REDIS_HOST:$DEV_REDIS_PORT` (host.docker.internal:6379)
- **MinIO**: `$DEV_MINIO_HOST:$DEV_MINIO_PORT` (host.docker.internal:9000)

## MCP Server Configuration

### Core MCPs (Always Available)
- **filesystem** - File operations in `/home/coder/projects`
- **git** - Repository operations
- **memory** - Persistent context storage

### Optional MCPs (Based on Available Secrets)
- **github** - Available if `GITHUB_TOKEN` exists
- **brave-search** - Available if `TAVILY_API_KEY` exists

### MCP Configuration Location
- Project-specific: `/home/coder/projects/.mcp.json`
- Dynamic configuration based on available secrets

## Workspace Layout

### Key Directories
- `/home/coder/` - User home directory (persistent)
- `/home/coder/projects/` - Main development directory (persistent)
- `/home/coder/bin/` - Custom scripts and tools
- `/opt/secrets/` - Secrets management system (read-only)
- `/patterns/` - Development patterns (read-only)
- `/dev-services/` - Service configurations (read-only)

### Important Files
- `/home/coder/projects/.mcp.json` - MCP server configuration
- `/home/coder/.claude/settings.json` - Claude directory trust settings
- `/home/coder/.config/claude-code/` - Claude Code configuration
- `/home/coder/bin/get-secret` - Secret retrieval helper
- `/home/coder/bin/claude-auth` - Authentication testing script

## Tools and Commands

### Pre-installed Tools
- **Claude Code** - AI coding assistant (this tool!)
- **GitHub CLI** (`gh`) - GitHub integration (if token available)
- **SuperClaude** - Enhanced Claude features with web search
- **Docker CLI** - Container operations
- **Node.js 22** - JavaScript/TypeScript runtime
- **Python 3.12** - Python runtime with pipx
- **VS Code Server** - Browser-based IDE at http://localhost:8080

### Useful Commands
```bash
# First time: Authenticate Claude
claude login
# Enter API key when prompted (available as $ANTHROPIC_API_KEY)

# Check what secrets are available
get-secret GITHUB_TOKEN && echo "GitHub available" || echo "GitHub not configured"

# List available MCPs
claude --list-mcps

# Check current development pattern
echo "Pattern: $DEV_PATTERN"

# Access VS Code in browser
# Visit http://localhost:8080
```

## Development Workflows

### Starting a New Project
1. Navigate to projects directory: `cd /home/coder/projects`
2. Check available services: `echo $DEV_POSTGRES_HOST`
3. Verify MCPs are loaded: `claude --list-mcps`
4. Create your project structure
5. Use Claude with full MCP integration for assistance

### Working with Secrets
1. Use `get-secret` for any secret retrieval in scripts
2. Check secret availability before using optional features
3. Secrets are automatically exported to environment
4. File-based secrets take priority over environment variables

### Using MCPs Effectively
- **filesystem MCP** - For file operations and project navigation
- **git MCP** - For repository management and history
- **github MCP** - For issues, PRs, and GitHub integration (if available)
- **memory MCP** - For maintaining context across sessions
- **brave-search MCP** - For web research and documentation (if available)

## Troubleshooting

### Secret Issues
```bash
# Check secrets system
ls -la /opt/secrets/
get-secret ANTHROPIC_API_KEY

# Test authentication
claude-auth
```

### MCP Issues
```bash
# Check MCP configuration
cat /home/coder/projects/.mcp.json
claude --list-mcps
```

### GitHub Integration
```bash
# Check GitHub status
gh auth status
get-secret GITHUB_TOKEN
```

This workspace is designed to provide a seamless development experience with integrated secrets management, dynamic MCP configuration, and support for various development patterns. Claude Code is pre-configured to understand and work with all these systems.
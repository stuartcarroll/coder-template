# Claude Development Environment - Coder Template

This Coder template provides a fully-configured development environment with **automatic Claude Code authentication**, **file-based secrets management**, **dynamic MCP integration**, and **pre-configured Claude context awareness**. When a workspace is created from this template, it automatically authenticates with Claude Code, configures essential development tools, and pre-loads Claude with knowledge about the workspace.

## ✨ Key Features

### 🔑 **Advanced Secrets Management**
- **File-based Integration**: Seamless integration with `/opt/secrets/manage-secrets.sh`
- **Automatic Fallback**: Environment variables (`TF_VAR_*`) as backup
- **Smart Retrieval**: `get-secret` command with priority-based fallback
- **Dynamic Configuration**: Features enable/disable based on available secrets

### 🤖 **Intelligent Claude Code Integration**
- **Simple Authentication**: Manual login with API key from environment
- **Pre-loaded Context**: Claude knows about workspace layout, tools, and patterns
- **Dynamic MCPs**: Server configuration based on available API keys
- **Memory Integration**: Persistent workspace knowledge across sessions
- **Serena MCP**: Advanced code navigation and editing capabilities

### 🛠️ **Development Tools & Services**
- **VS Code Server**: Browser-based IDE at port 8080 with extensions
- **GitHub CLI**: Pre-authenticated (if token available)
- **SuperClaude**: Enhanced features with web search capabilities
- **Development Patterns**: Support for Laravel, Python, Node.js workflows
- **Pre-configured Services**: PostgreSQL, MySQL, Redis, MinIO endpoints

### 🚀 **Smart Workspace Features**
- **Graceful Degradation**: Works with partial secret availability
- **Error Recovery**: Comprehensive troubleshooting tools
- **Dynamic Status**: Real-time reporting of available features
- **Helper Commands**: `claude-auth`, `get-secret`, `claude-with-context`

### 🐳 **Robust Container Environment**
- **Ubuntu 24.04 LTS**: Stable and well-supported base system
- **Docker Support**: Full container operations with socket mounting
- **Persistent Volumes**: Home directory and projects survive restarts
- **Resource Monitoring**: Built-in CPU, memory, and disk metrics

## Architecture

### Files Structure
```
├── main.tf                     # Main Terraform configuration with secrets integration
├── build/
│   ├── Dockerfile             # Container image with tools and scripts
│   ├── config.yaml            # Code-server configuration
│   ├── get-secret.sh          # Universal secret retrieval helper
│   ├── init-claude-context.sh # Claude workspace context initialization
│   ├── CLAUDE.md              # Comprehensive workspace documentation
│   └── claude-startup-prompt.md # Welcome message for Claude sessions
├── README.md                   # This documentation
├── DEPLOYMENT.md               # Detailed deployment guide
├── TROUBLESHOOTING.md          # Comprehensive troubleshooting guide
├── EXAMPLES.md                 # Usage examples and workflows
└── CHANGELOG.md               # Version history and improvements
```

### Container Components
- **Base Image**: Ubuntu 24.04 with development tools and utilities
- **Runtime**: Node.js 22, Python 3.12, Docker CLI, GitHub CLI
- **Editor**: VS Code Server with extension support
- **Authentication**: Multi-method setup for Claude Code and GitHub CLI
- **Helper Scripts**: Secret management, authentication testing, context initialization

### Dynamic MCP Servers
MCPs are configured based on available secrets:

**Core MCPs (Always Available)**:
1. **Filesystem**: File operations in `/home/coder/projects`
2. **Git**: Repository operations and version control
3. **Memory**: Persistent context and conversation history
4. **Serena**: Advanced code navigation, search, and editing

**Optional MCPs (Secret-Dependent)**:
5. **GitHub**: Issues, PRs, and repository management (requires `GITHUB_TOKEN`)
6. **Brave Search**: Web research capabilities (requires `TAVILY_API_KEY`)

### Claude Context Pre-configuration
- **Workspace Knowledge**: Complete understanding of secrets, tools, and layout
- **Memory Integration**: Persistent context across Claude sessions
- **Helper Functions**: `claude-with-context` and `cw` aliases for enhanced experience
- **Documentation Access**: Built-in help and troubleshooting guides

## Secrets Management System

This template integrates with a file-based secrets management system while maintaining compatibility with traditional environment variables. The system uses a priority-based approach for retrieving secrets.

### Priority Order
1. **File-based secrets** (`/opt/secrets/manage-secrets.sh`)
2. **Environment variables** (`TF_VAR_*`)

### File-based Secrets Integration

The template automatically detects and uses the secrets management system at `/opt/secrets/`. If available, it will retrieve API keys using:

```bash
/opt/secrets/manage-secrets.sh get-secret SECRET_NAME
```

### Supported Secrets
- **ANTHROPIC_API_KEY** (required) - Claude Code authentication
- **GITHUB_TOKEN** (optional) - GitHub CLI and MCP integration
- **TAVILY_API_KEY** (optional) - SuperClaude web search and Brave MCP
- **MORPHLLM_API_KEY** (optional) - Alternative LLM access

### Fallback to Environment Variables

If file-based secrets are not available, the template falls back to traditional Coder environment variables:

```bash
# Set these in your Coder server's environment file (typically `coder.env`):

# Required - Anthropic API key for Claude Code
TF_VAR_anthropic_api_key=sk-ant-api03-...

# Optional - GitHub Personal Access Token
TF_VAR_github_token=ghp_...

# Optional - Tavily API key for SuperClaude search
TF_VAR_tavily_api_key=tvly-...

# Optional - MorphLLM API key for alternative models
TF_VAR_morphllm_api_key=...
```

### Testing Secrets Configuration

Inside a workspace, you can test the secrets system:

```bash
# Test secret retrieval
get-secret ANTHROPIC_API_KEY

# Check all authentication
claude-auth

# Verify what MCPs are available
cd /home/coder/projects && claude --list-mcps
```

### Mixed Configuration Support

The template supports mixed configurations where some secrets come from the file-based system and others from environment variables. This allows for flexible deployment scenarios.

### Error Handling

- **Missing required secrets**: Claude Code features will be disabled with clear error messages
- **Missing optional secrets**: Related features (GitHub, web search) will be gracefully skipped
- **Graceful degradation**: The workspace will still be functional with core features even if some secrets are missing

## Deployment Instructions

### Prerequisites
- Coder server running on 192.168.71.2 (or your Coder instance)
- Docker provider configured in Coder
- Environment variables set in `coder.env`

### Step 1: Deploy Template to Coder Server
```bash
# SSH to your Coder server
ssh coder@192.168.71.2

# Navigate to templates directory
cd /path/to/coder/templates

# Clone this repository
git clone https://github.com/stuartcarroll/claude-dev.git
cd claude-dev

# Create the template in Coder
coder templates create claude-dev
```

### Step 2: Create Workspace
1. Open your Coder dashboard
2. Click "Create Workspace"
3. Select the "claude-dev" template
4. Configure workspace name and resources
5. Click "Create"

### Step 3: Access Your Environment
- **VS Code**: Click the "VS Code" app in your workspace
- **Terminal**: Use the terminal tab in Coder or VS Code
- **Claude Code**: Run `claude` in the terminal to start

## Usage

### Quick Start
```bash
# Navigate to development directory
cd /home/coder/projects

# First time: Authenticate Claude (only needed once)
claude login
# When prompted, use the API key from environment: echo $ANTHROPIC_API_KEY

# Start Claude with full workspace context (recommended)
claude-with-context
# or use the alias: cw

# Alternative: Start Claude normally
claude

# Verify everything is working
claude --list-mcps
```

### Secret Management
```bash
# Check what secrets are available
get-secret ANTHROPIC_API_KEY
get-secret GITHUB_TOKEN

# Test comprehensive authentication
claude-auth

# View workspace context (what Claude knows)
cat ~/.claude/WORKSPACE_CONTEXT.md
```

### GitHub Integration
```bash
# GitHub CLI is automatically authenticated if token available
gh auth status
gh repo create my-project --private

# GitHub MCP provides repository management in Claude
# Available automatically if GITHUB_TOKEN is configured
```

### Web Search & Research
```bash
# SuperClaude with web search (if Tavily API available)
superclaude "research latest AI developments"

# Brave Search MCP integrated in Claude
# Available automatically if TAVILY_API_KEY is configured
```

### Development Workflow
```bash
# Start development session
cd /home/coder/projects
cw  # Start Claude with full context

# Claude now knows about:
# - Available secrets and their status
# - Development pattern (Laravel, Python, etc.)
# - Service endpoints (PostgreSQL, MySQL, Redis)
# - Workspace layout and available tools
# - MCP servers based on your configuration
```

## Configuration Details

### Claude Code Authentication
First-time setup:
1. The `ANTHROPIC_API_KEY` is automatically available in the environment
2. Run `claude login` and enter your API key when prompted
3. Authentication persists across workspace restarts
4. MCP servers are pre-configured in `/home/coder/projects/.mcp.json`

### MCP Configuration
MCPs are configured in `/home/coder/projects/.mcp.json`:
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/coder/projects"]
    },
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git", "--repository", "/home/coder/projects"]
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "serena": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-serena", "/home/coder/projects"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "$GITHUB_TOKEN"
      }
    }
  }
}
```

### Persistent Data
- **Home Directory**: `/home/coder` - User configurations, SSH keys, etc.
- **Projects**: `/home/coder/projects` - Your development projects
- **Docker Volumes**: Automatically created and managed by Coder

## Troubleshooting

### Secrets Management Issues

```bash
# Check if file-based secrets are available
ls -la /opt/secrets/

# Test the secrets management script
/opt/secrets/manage-secrets.sh get-secret ANTHROPIC_API_KEY

# Test the get-secret helper
get-secret ANTHROPIC_API_KEY

# Check environment variables as fallback
echo $TF_VAR_anthropic_api_key
```

### Claude Code Not Authenticated
```bash
# Check if API key is available
get-secret ANTHROPIC_API_KEY

# Check environment variable
echo $ANTHROPIC_API_KEY

# Login to Claude
claude login
# Enter API key when prompted (copy from environment)

# Verify authentication
claude --version

# Check MCP servers
claude --list-mcps
```

### GitHub CLI Issues
```bash
# Check authentication status
gh auth status

# Re-authenticate if needed
gh auth login --with-token < ~/.github-token
```

### MCP Servers Not Loading
```bash
# Check MCP configuration
cat ~/.claude/config.json

# Test MCP server manually
npx -y @modelcontextprotocol/server-filesystem /home/coder/projects
```

### Container Issues
```bash
# Check container logs in Coder UI
# Or rebuild the template:
coder templates push claude-dev
```

## Development

### Modifying the Template
1. Clone this repository
2. Make changes to `main.tf` or `build/` files
3. Test with `terraform plan`
4. Push changes: `coder templates push claude-dev`

### Adding New Tools
Add to `build/Dockerfile`:
```dockerfile
RUN apt-get update && apt-get install -y your-tool
```

Or install in startup script in `main.tf`.

### Custom MCP Servers
Add to the MCP configuration in the startup script:
```json
"your-mcp": {
  "command": "npx",
  "args": ["-y", "your-mcp-package"]
}
```

## 📚 Documentation

This template includes comprehensive documentation:

- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Complete deployment guide with file-based secrets integration
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Comprehensive troubleshooting guide for common issues  
- **[EXAMPLES.md](EXAMPLES.md)** - Practical usage examples and development workflows
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and detailed feature documentation

### Built-in Workspace Documentation
Inside workspaces, Claude has access to:
- `~/.claude/WORKSPACE_CONTEXT.md` - Complete workspace knowledge base
- `~/.claude/STARTUP_PROMPT.md` - Quick start guide and welcome message
- `~/.claude/startup_message.md` - Dynamic status summary

### Quick Reference Commands
- `claude login` - Authenticate Claude with your API key (first time only)
- `get-secret <name>` - Retrieve secrets with automatic fallback
- `claude-with-context` (or `cw`) - Start Claude with full workspace awareness
- `cat ~/.claude/WORKSPACE_CONTEXT.md` - View what Claude knows about your workspace

## Security Notes

- API keys are stored as Terraform variables and passed securely to containers
- File-based secrets accessed read-only from `/opt/secrets`
- GitHub token is used for authentication and stored in git credentials
- Containers are isolated and have limited host access
- Docker socket is mounted for development purposes only

## Support

For issues with:
- **Coder**: Check Coder documentation or server logs
- **Claude Code**: Verify API key and authentication
- **Template**: Review startup script logs in container
- **MCPs**: Check individual MCP server documentation

## License

Private repository - all rights reserved.

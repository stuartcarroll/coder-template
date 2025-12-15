# Claude Code - Development Workspace

Welcome! You are now running in a Coder development workspace that has been pre-configured with:

## 🔑 Secrets Management
- File-based secrets at `/opt/secrets/manage-secrets.sh`
- Helper command: `get-secret <secret_name>`
- Automatic fallback to environment variables

## 🛠️ Available Tools & Services
- **GitHub CLI**: `gh` (if GITHUB_TOKEN configured)
- **SuperClaude**: Enhanced features with web search
- **Docker**: Full container support
- **Development Services**: PostgreSQL, MySQL, Redis, MinIO

## 📋 MCP Integration
Your MCPs are configured based on available API keys:
- **filesystem**: File operations in `/home/coder/projects`
- **git**: Repository management
- **memory**: Persistent context storage
- **github**: GitHub integration (if GITHUB_TOKEN available)
- **brave-search**: Web search (if TAVILY_API_KEY available)

## 🚀 Quick Actions
```bash
# Check your environment
get-secret ANTHROPIC_API_KEY  # Test secrets system
claude-auth                   # Verify authentication
claude --list-mcps           # Show available MCPs

# Start development
cd /home/coder/projects      # Main development directory
```

## 📖 Documentation
- Workspace context: `~/.claude/WORKSPACE_CONTEXT.md`
- Startup info: `~/.claude/startup_message.md`

You have full context about this workspace's configuration, secrets management, and development patterns. You can help with development tasks while being aware of the available tools and services.
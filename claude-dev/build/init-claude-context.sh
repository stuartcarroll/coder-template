#!/bin/bash
# Initialize Claude Code context with workspace-specific information

echo "Initializing Claude Code context with workspace knowledge..."

# Create Claude configuration directory
mkdir -p ~/.claude

# Create workspace configuration file
cat > ~/.claude/workspace_info.json << EOF
{
  "workspace_type": "coder_development_environment",
  "secrets_management": {
    "system": "file_based_with_fallback",
    "primary_location": "/opt/secrets/manage-secrets.sh",
    "fallback": "environment_variables",
    "helper_command": "get-secret"
  },
  "development_patterns": {
    "current": "$DEV_PATTERN",
    "available": ["none", "laravel-standard", "python-api", "python-data", "node-fullstack"],
    "location": "/patterns/"
  },
  "services": {
    "postgresql": "$DEV_POSTGRES_HOST:$DEV_POSTGRES_PORT",
    "mysql": "$DEV_MYSQL_HOST:$DEV_MYSQL_PORT",
    "redis": "$DEV_REDIS_HOST:$DEV_REDIS_PORT",
    "minio": "$DEV_MINIO_HOST:$DEV_MINIO_PORT"
  },
  "tools_available": {
    "secrets": "$(command -v get-secret >/dev/null 2>&1 && echo 'true' || echo 'false')",
    "github_cli": "$(command -v gh >/dev/null 2>&1 && echo 'true' || echo 'false')",
    "superclaude": "$(command -v superclaude >/dev/null 2>&1 && echo 'true' || echo 'false')",
    "docker": "$(command -v docker >/dev/null 2>&1 && echo 'true' || echo 'false')"
  },
  "workspace_layout": {
    "home": "/home/coder",
    "projects": "/home/coder/projects", 
    "bin": "/home/coder/bin",
    "secrets": "/opt/secrets",
    "patterns": "/patterns",
    "services": "/dev-services"
  }
}
EOF

# Initialize Claude memory with workspace context if memory MCP is available
if command -v claude >/dev/null 2>&1 && [ -f /home/coder/projects/.mcp.json ]; then
    # Check if memory MCP is configured
    if grep -q '"memory"' /home/coder/projects/.mcp.json 2>/dev/null; then
        echo "Initializing Claude memory with workspace context..."
        
        # Store workspace context in Claude memory
        cat > /tmp/claude_init.txt << 'CTXEOF'
This is a Coder development workspace with the following key features:

SECRETS MANAGEMENT:
- Primary: /opt/secrets/manage-secrets.sh get-secret <name>
- Helper: get-secret command with automatic fallback
- Available secrets: ANTHROPIC_API_KEY (required), GITHUB_TOKEN, TAVILY_API_KEY, MORPHLLM_API_KEY

DEVELOPMENT PATTERN: $DEV_PATTERN

AVAILABLE SERVICES:
- PostgreSQL: $DEV_POSTGRES_HOST:$DEV_POSTGRES_PORT
- MySQL: $DEV_MYSQL_HOST:$DEV_MYSQL_PORT  
- Redis: $DEV_REDIS_HOST:$DEV_REDIS_PORT
- MinIO: $DEV_MINIO_HOST:$DEV_MINIO_PORT

KEY COMMANDS:
- get-secret <name>: Retrieve any secret safely
- claude-auth: Test all authentication
- gh: GitHub CLI (if GITHUB_TOKEN available)
- superclaude: Enhanced Claude with web search

MCP SERVERS:
- filesystem: File operations in /home/coder/projects
- git: Repository operations  
- memory: Persistent context (this conversation)
- github: GitHub integration (if token available)
- brave-search: Web search (if Tavily key available)

The workspace is designed for seamless development with integrated secrets management and dynamic feature availability based on configured API keys.
CTXEOF
        
        # Try to initialize Claude memory (but don't fail if it doesn't work)
        timeout 10 claude memory store "workspace_context" "$(cat /tmp/claude_init.txt)" 2>/dev/null || \
        echo "Could not initialize Claude memory (normal if not authenticated yet)"
        
        rm -f /tmp/claude_init.txt
    fi
fi

# Create a helpful startup message for Claude
cat > ~/.claude/startup_message.md << EOF
# Welcome to Your Coder Development Workspace

## Quick Start
\`\`\`bash
cd /home/coder/projects    # Main development directory
claude                     # Start Claude Code with full MCP integration
\`\`\`

## Secrets Available
$(get-secret ANTHROPIC_API_KEY >/dev/null 2>&1 && echo "✅ ANTHROPIC_API_KEY" || echo "❌ ANTHROPIC_API_KEY")
$(get-secret GITHUB_TOKEN >/dev/null 2>&1 && echo "✅ GITHUB_TOKEN" || echo "❌ GITHUB_TOKEN")  
$(get-secret TAVILY_API_KEY >/dev/null 2>&1 && echo "✅ TAVILY_API_KEY" || echo "❌ TAVILY_API_KEY")

## Development Pattern
Current: $DEV_PATTERN

## Useful Commands
- \`get-secret <name>\` - Retrieve any secret
- \`claude-auth\` - Test authentication
- \`claude --list-mcps\` - Show available MCPs

Read the full context: \`cat ~/.claude/WORKSPACE_CONTEXT.md\`
EOF

# Create a helpful shell function for launching Claude
cat >> ~/.bashrc << 'EOF'

# Claude Code with workspace context
claude-with-context() {
    echo "🤖 Starting Claude Code with workspace awareness..."
    echo "📖 Workspace info: ~/.claude/WORKSPACE_CONTEXT.md"
    echo ""
    cd /home/coder/projects
    claude "$@"
}

# Alias for convenience
alias cw='claude-with-context'
EOF

echo "✅ Claude context initialized"
echo "📖 Workspace documentation: ~/.claude/WORKSPACE_CONTEXT.md"
echo "🚀 Startup message: ~/.claude/startup_message.md"
echo "🔧 Use 'claude-with-context' or 'cw' to start Claude with context awareness"
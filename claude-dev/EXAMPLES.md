# Usage Examples - Claude Development Environment

This guide provides practical examples of using the Claude development environment with various workflows and scenarios.

## 🚀 Getting Started Examples

### Example 1: First Time Setup
```bash
# After workspace creation, verify everything is working
claude-auth  # Comprehensive authentication test

# Expected output:
# ✅ ANTHROPIC_API_KEY found and configured
# ✅ GITHUB_TOKEN found - GitHub integration will be enabled
# ✅ TAVILY_API_KEY found - Web search features will be enabled
# ✅ Claude Code is authenticated and working!
```

### Example 2: Starting a Development Session
```bash
# Navigate to projects directory
cd /home/coder/projects

# Start Claude with full context awareness (recommended)
claude-with-context  # or use alias: cw

# Claude now knows about:
# - Your secrets and available services
# - Development pattern configuration
# - Workspace layout and tools
# - Which MCPs are available
```

---

## 🔑 Secrets Management Examples

### Example 3: Working with Secrets
```bash
# Check what secrets are available
get-secret ANTHROPIC_API_KEY  # Should return your API key
get-secret GITHUB_TOKEN       # Returns token or empty if not configured
get-secret TAVILY_API_KEY     # For web search features

# Use secrets in scripts safely
#!/bin/bash
API_KEY=$(get-secret ANTHROPIC_API_KEY)
if [ -n "$API_KEY" ]; then
    echo "Claude API key available"
else
    echo "No Claude API key found"
    exit 1
fi
```

### Example 4: Mixed Secret Configuration
```bash
# File-based secrets (priority)
/opt/secrets/manage-secrets.sh get-secret ANTHROPIC_API_KEY

# Environment variable fallback
echo $TF_VAR_anthropic_api_key

# get-secret handles both automatically
get-secret ANTHROPIC_API_KEY  # Uses file-based first, then env var
```

---

## 🤖 Claude Code Integration Examples

### Example 5: Claude with MCP Awareness
```bash
# Start Claude and ask about available tools
cw

# Example conversation:
# You: "What MCPs do I have available?"
# Claude: "Based on your configuration, you have these MCPs available:
#          - filesystem (for file operations)
#          - git (for repository management) 
#          - memory (for persistent context)
#          - github (enabled - you have a GITHUB_TOKEN)
#          - brave-search (enabled - you have a TAVILY_API_KEY)"
```

### Example 6: Claude Understanding Your Environment
```bash
cw

# Claude already knows:
# - Your development pattern (e.g., "laravel-standard")
# - Available services (PostgreSQL at host.docker.internal:5432)
# - Secret status and available integrations
# - Workspace directory structure

# You can ask questions like:
# "How do I connect to the database?"
# "What's my GitHub token status?"
# "Can I use web search in this workspace?"
```

---

## 🐙 GitHub Integration Examples

### Example 7: Automatic GitHub Setup
```bash
# If GITHUB_TOKEN is available, GitHub CLI is pre-authenticated
gh auth status
# ✓ Logged in to github.com as yourusername

# Create repositories
gh repo create my-new-project --private --description "New project"

# Work with issues and PRs
gh issue list
gh pr create --title "Feature: new functionality"
```

### Example 8: GitHub MCP in Action
```bash
cw

# Ask Claude to help with GitHub operations:
# "Can you list my recent repositories?"
# "Help me create an issue for this bug"
# "What are the open PRs on my main project?"

# Claude can use the GitHub MCP to perform these operations
```

---

## 🔍 Web Search and Research Examples

### Example 9: SuperClaude Research
```bash
# If TAVILY_API_KEY is configured, SuperClaude has web search
superclaude "research latest AI developments in 2024"

# SuperClaude can:
# - Search the web for current information
# - Provide researched summaries
# - Access real-time data
```

### Example 10: Brave Search MCP
```bash
cw

# Ask Claude to search the web:
# "Can you search for the latest Docker best practices?"
# "Find recent articles about Python performance optimization"
# "What are the current trends in web development?"

# Claude uses the Brave Search MCP to provide current information
```

---

## 🛠️ Development Pattern Examples

### Example 11: Laravel Development Pattern
```bash
# If workspace is configured with laravel-standard pattern
echo $DEV_PATTERN  # outputs: laravel-standard

# Claude knows about Laravel workflow
cw

# Ask Laravel-specific questions:
# "Help me set up a new Laravel project"
# "What's the best way to configure my database connection?"
# "Generate a Laravel controller for user management"
```

### Example 12: Python Data Science Pattern
```bash
# If workspace is configured with python-data pattern
echo $DEV_PATTERN  # outputs: python-data

# Claude understands data science workflow
cw

# Ask data science questions:
# "Help me set up a Jupyter notebook environment"
# "What's the best way to connect to PostgreSQL for data analysis?"
# "Create a Python script for data visualization"
```

---

## 🗃️ Database and Services Examples

### Example 13: Database Connections
```bash
# Service endpoints are pre-configured
echo "PostgreSQL: $DEV_POSTGRES_HOST:$DEV_POSTGRES_PORT"
echo "MySQL: $DEV_MYSQL_HOST:$DEV_MYSQL_PORT"
echo "Redis: $DEV_REDIS_HOST:$DEV_REDIS_PORT"

# Claude knows about these services
cw

# Ask about database setup:
# "How do I connect to the PostgreSQL database?"
# "What's the Redis connection string?"
# "Help me set up database migrations"
```

### Example 14: Using Services in Code
```python
# Python example using environment variables
import os
import psycopg2

# Connection details are available as environment variables
db_config = {
    'host': os.environ['DEV_POSTGRES_HOST'],
    'port': os.environ['DEV_POSTGRES_PORT'],
    'database': 'mydb',
    'user': 'myuser',
    'password': 'mypass'
}

conn = psycopg2.connect(**db_config)
```

---

## 🧪 Testing and Debugging Examples

### Example 15: Debugging Secret Issues
```bash
# Comprehensive debugging
echo "=== Secrets Debug ==="
get-secret ANTHROPIC_API_KEY >/dev/null && echo "✅ Claude" || echo "❌ Claude"
get-secret GITHUB_TOKEN >/dev/null && echo "✅ GitHub" || echo "❌ GitHub"
get-secret TAVILY_API_KEY >/dev/null && echo "✅ Tavily" || echo "❌ Tavily"

# Check file-based vs environment
/opt/secrets/manage-secrets.sh get-secret ANTHROPIC_API_KEY 2>/dev/null && echo "File-based available"
echo ${TF_VAR_anthropic_api_key:+Environment available}
```

### Example 16: MCP Troubleshooting
```bash
# Check MCP configuration
cat /home/coder/projects/.mcp.json | jq .

# Test individual MCPs
claude --list-mcps

# Verify Claude can use MCPs
cw
# Ask: "Can you list the files in my current directory using the filesystem MCP?"
```

---

## 📱 VS Code Integration Examples

### Example 17: Using VS Code with Claude
```bash
# Access VS Code in browser at http://localhost:8080
# Open terminal in VS Code

# All the same commands work:
cw  # Start Claude with context
get-secret ANTHROPIC_API_KEY  # Check secrets
claude-auth  # Test authentication
```

### Example 18: Integrated Development Workflow
```bash
# Typical workflow:
# 1. Open VS Code in browser
# 2. Open terminal
# 3. Start Claude with context: cw
# 4. Ask Claude to help with your development tasks
# 5. Use GitHub CLI for version control: gh commands
# 6. Claude understands your complete environment
```

---

## 🔄 Advanced Workflow Examples

### Example 19: Multi-Tool Development Session
```bash
# Start comprehensive development session
cd /home/coder/projects
cw  # Claude with full context

# In the Claude session, you can ask:
# "Help me start a new Python project with proper structure"
# "Set up GitHub repository and initial commit"
# "Configure database connection for this project"
# "Research best practices for this technology stack"

# Claude coordinates between:
# - Filesystem MCP (creating files)
# - Git MCP (version control)
# - GitHub MCP (repository management)
# - Brave Search MCP (research)
# - Memory MCP (remembering your preferences)
```

### Example 20: Cross-Session Continuity
```bash
# Session 1
cw
# Work on a project, Claude remembers context via Memory MCP

# Session 2 (later)
cw
# Ask: "What were we working on last time?"
# Claude can recall previous context and continue where you left off
```

---

## 🚨 Error Recovery Examples

### Example 21: When Authentication Fails
```bash
# If Claude authentication issues occur
claude-auth  # Run comprehensive test

# Manual recovery
echo $(get-secret ANTHROPIC_API_KEY) | claude login --key-stdin

# Reset and retry
init-claude-context
cw
```

### Example 22: When Secrets Are Missing
```bash
# Check what's available
get-secret ANTHROPIC_API_KEY || echo "No Claude key - features limited"
get-secret GITHUB_TOKEN || echo "No GitHub integration"
get-secret TAVILY_API_KEY || echo "No web search"

# Graceful degradation - workspace still works with available features
```

---

## 💡 Pro Tips

### Tip 1: Context-Aware Development
Always use `cw` instead of `claude` for the best experience - Claude will understand your environment completely.

### Tip 2: Leverage Claude's Knowledge
Ask Claude about your workspace: "What tools are available?" or "What's my development pattern setup?"

### Tip 3: Secrets in Scripts
Always use `get-secret` instead of direct environment variables for maximum compatibility.

### Tip 4: Error Recovery
When in doubt, run `claude-auth` for comprehensive diagnostic information.

### Tip 5: Documentation Access
Use `cat ~/.claude/WORKSPACE_CONTEXT.md` to see what Claude knows about your workspace.
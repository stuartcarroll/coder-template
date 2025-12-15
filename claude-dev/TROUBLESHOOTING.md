# Troubleshooting Guide - Claude Development Environment

This guide helps resolve common issues with the Claude development environment Coder template.

## Quick Diagnostics

### 🔍 Run Comprehensive Check
```bash
# Inside a workspace, run these commands for full diagnosis
claude --version              # Check Claude is installed
get-secret ANTHROPIC_API_KEY  # Test secrets system
claude --list-mcps            # Verify MCP configuration
gh auth status                # Check GitHub integration
```

---

## 🔑 Secrets Management Issues

### Problem: `get-secret: command not found`
```bash
# Check if the helper script exists
ls -la /home/coder/bin/get-secret

# If missing, the PATH might not be set
export PATH="/home/coder/bin:$PATH"

# Or call directly
/home/coder/bin/get-secret ANTHROPIC_API_KEY
```

### Problem: Secrets not found
```bash
# Debug the secrets system
echo "=== Secrets Debug ==="

# 1. Check file-based secrets
ls -la /opt/secrets/
/opt/secrets/manage-secrets.sh get-secret ANTHROPIC_API_KEY 2>&1 || echo "File-based secrets not available"

# 2. Check environment variables
echo "TF_VAR_anthropic_api_key: ${TF_VAR_anthropic_api_key:0:10}..."
echo "ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY:0:10}..."

# 3. Manual retrieval test
get-secret ANTHROPIC_API_KEY
```

### Problem: Permission denied on secrets
```bash
# Check permissions
ls -la /opt/secrets/manage-secrets.sh
# Should be executable (x permission)

# Test direct execution
sudo /opt/secrets/manage-secrets.sh get-secret ANTHROPIC_API_KEY
```

---

## 🤖 Claude Code Authentication Issues

### Problem: "Not authenticated" or login prompts
```bash
# Check API key is available
echo $ANTHROPIC_API_KEY

# Login to Claude (first time only)
claude login
# Enter API key when prompted

# Check if config files exist after login
ls -la ~/.config/claude-code/
cat ~/.config/claude-code/config.json 2>/dev/null || echo "Config not found"

# Verify authentication
claude --version

# Check MCP servers
claude --list-mcps
```

### Problem: Claude hangs or times out
```bash
# Check if Claude process is running
ps aux | grep claude

# Kill hung processes
pkill -f claude

# Try authentication with timeout
timeout 30 claude --version

# Check for authentication files
find ~/.config/claude-code -name "*" -type f
```

### Problem: API key format issues
```bash
# Verify API key format
API_KEY=$(get-secret ANTHROPIC_API_KEY)
echo "Length: ${#API_KEY}"
echo "Starts with: ${API_KEY:0:15}"
# Should be ~100+ characters starting with 'sk-ant-api03-'

# Test with curl
curl -H "x-api-key: $API_KEY" https://api.anthropic.com/v1/messages -X POST -d '{}' 2>&1 | head -5
```

---

## 📋 MCP Server Issues

### Problem: MCPs not loading
```bash
# Check MCP configuration file
cat /home/coder/projects/.mcp.json

# Verify JSON syntax
jq '.' /home/coder/projects/.mcp.json || echo "Invalid JSON"

# Test individual MCP servers
npx -y @modelcontextprotocol/server-filesystem /home/coder/projects
npx -y @modelcontextprotocol/server-git --repository /home/coder/projects
```

### Problem: GitHub MCP fails
```bash
# Debug GitHub MCP specifically
echo "GitHub Token: ${GITHUB_TOKEN:0:10}..."
echo "GitHub Personal Access Token: ${GITHUB_PERSONAL_ACCESS_TOKEN:0:10}..."

# Test GitHub API access
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user 2>&1 | jq .login

# Check if GitHub MCP is in configuration
grep -A 10 '"github"' /home/coder/projects/.mcp.json
```

### Problem: Brave Search MCP fails
```bash
# Check Tavily API key
echo "Tavily Key: ${TAVILY_API_KEY:0:10}..."
echo "Brave API Key: ${BRAVE_API_KEY:0:10}..."

# Test Tavily API
curl -X POST https://api.tavily.com/search -H "Content-Type: application/json" -d "{\"api_key\":\"$TAVILY_API_KEY\",\"query\":\"test\"}" 2>&1 | head -5
```

---

## 🐙 GitHub Integration Issues

### Problem: GitHub CLI not authenticated
```bash
# Check authentication status
gh auth status

# Re-authenticate manually
get-secret GITHUB_TOKEN | gh auth login --with-token

# Verify token permissions
gh api user
gh auth refresh
```

### Problem: Git operations fail
```bash
# Check git configuration
git config --global --list | grep user

# Check credentials
ls -la ~/.git-credentials
head -1 ~/.git-credentials 2>/dev/null | sed 's/ghp_[^@]*/ghp_***/'

# Test git operation
git ls-remote https://github.com/octocat/Hello-World.git
```

---

## 🚀 Workspace Startup Issues

### Problem: Startup script fails
```bash
# Check recent startup logs (if available)
journalctl --user -u coder-agent.service -f

# Look for startup script in process list
ps aux | grep -E "(coder|init)"

# Check if initialization completed
ls -la ~/.claude/
cat ~/.claude/startup_message.md 2>/dev/null || echo "Context not initialized"
```

### Problem: Environment variables not set
```bash
# Check key environment variables
echo "=== Environment Debug ==="
env | grep -E "(ANTHROPIC|GITHUB|TAVILY)" | sed 's/=.*/=***/'

# Check if variables are in .bashrc
grep -E "(ANTHROPIC|GITHUB|TAVILY)" ~/.bashrc 2>/dev/null || echo "Not in .bashrc"

# Re-source bashrc
source ~/.bashrc
```

### Problem: Services not available
```bash
# Check service endpoints
echo "PostgreSQL: $DEV_POSTGRES_HOST:$DEV_POSTGRES_PORT"
echo "MySQL: $DEV_MYSQL_HOST:$DEV_MYSQL_PORT"
echo "Redis: $DEV_REDIS_HOST:$DEV_REDIS_PORT"

# Test connectivity (if services are running)
nc -zv $DEV_POSTGRES_HOST $DEV_POSTGRES_PORT 2>&1 || echo "PostgreSQL not reachable"
```

---

## 🛠️ Development Pattern Issues

### Problem: Pattern not applied correctly
```bash
# Check current pattern
echo "Development Pattern: $DEV_PATTERN"

# Check pattern files
ls -la /patterns/ 2>/dev/null || echo "Patterns directory not mounted"

# Verify pattern parameter
cat /proc/1/environ | tr '\0' '\n' | grep DEV_PATTERN
```

---

## 🔄 Container and Volume Issues

### Problem: Files not persisting
```bash
# Check volume mounts
df -h | grep -E "(home|projects)"
mount | grep -E "(home|projects)"

# Check permissions
ls -la /home/coder/
ls -la /home/coder/projects/

# Test write permissions
touch /home/coder/test_file && rm /home/coder/test_file && echo "Home writable"
touch /home/coder/projects/test_file && rm /home/coder/projects/test_file && echo "Projects writable"
```

### Problem: Docker operations fail
```bash
# Check Docker socket
ls -la /var/run/docker.sock

# Test Docker access
docker version
docker ps 2>&1 || echo "Docker not accessible"

# Check user permissions
groups | grep docker || echo "User not in docker group"
```

---

## 📱 VS Code Server Issues

### Problem: Can't access VS Code in browser
```bash
# Check if code-server is running
ps aux | grep code-server
netstat -tlnp | grep :8080

# Check logs
journalctl --user -u code-server -f

# Restart code-server (if needed)
pkill code-server
code-server --bind-addr 0.0.0.0:8080 &
```

---

## 🔧 Recovery Procedures

### Nuclear Option: Reset Everything
```bash
# 1. Re-initialize Claude context
init-claude-context

# 2. Re-authenticate Claude
claude-auth

# 3. Recreate MCP configuration
rm -f /home/coder/projects/.mcp.json
# Restart workspace or re-run startup script

# 4. Source environment
source ~/.bashrc

# 5. Test everything
get-secret ANTHROPIC_API_KEY && echo "Secrets OK"
claude --version && echo "Claude OK"
claude --list-mcps && echo "MCPs OK"
```

### Workspace Recreation
If all else fails, recreate the workspace:
```bash
# From Coder server
coder stop your-workspace-name
coder delete your-workspace-name
coder create your-workspace-name --template claude-dev
```

---

## 📞 Getting Help

### Information to Collect
When asking for help, include:

```bash
# System information
uname -a
cat /etc/os-release | head -5
echo "Coder Agent: $(cat /proc/1/environ | tr '\0' '\n' | grep CODER_AGENT)"

# Secrets status
get-secret ANTHROPIC_API_KEY >/dev/null && echo "✅ ANTHROPIC" || echo "❌ ANTHROPIC"
get-secret GITHUB_TOKEN >/dev/null && echo "✅ GITHUB" || echo "❌ GITHUB"

# Claude status
claude --version 2>&1 || echo "Claude not working"
claude --list-mcps 2>&1 | head -5

# Recent logs (last 20 lines of any errors)
journalctl --user -n 20 --no-pager 2>/dev/null || echo "No user journal"
```

### Support Resources
- **Template Issues**: https://github.com/stuartcarroll/claude-dev/issues
- **Claude Code Documentation**: Built-in help with `cat ~/.claude/WORKSPACE_CONTEXT.md`
- **Coder Documentation**: https://coder.com/docs
- **Secrets Management**: Check your organization's secrets documentation
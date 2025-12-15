# Deployment Guide - Claude Development Environment

This guide provides step-by-step instructions for deploying the Claude development environment template with **file-based secrets management integration** to your Coder server.

## Prerequisites

### 1. Coder Server Setup
- Coder server running (e.g., on 192.168.71.2)
- Docker provider configured and working
- Access to server via SSH or web interface
- **File-based secrets system** at `/opt/secrets/manage-secrets.sh` (recommended)

### 2. Secrets Configuration Options

The template supports **two methods** for providing API keys with automatic priority-based fallback:

#### Option A: File-Based Secrets (Recommended)
If you have a secrets management system at `/opt/secrets/`:

```bash
# Ensure your secrets are accessible via:
/opt/secrets/manage-secrets.sh get-secret ANTHROPIC_API_KEY
/opt/secrets/manage-secrets.sh get-secret GITHUB_TOKEN
/opt/secrets/manage-secrets.sh get-secret TAVILY_API_KEY
```

#### Option B: Environment Variables (Fallback)
Traditional Coder environment variables in `coder.env`:

```bash
# Required - Get from https://console.anthropic.com
TF_VAR_anthropic_api_key=sk-ant-api03-...

# Optional but recommended - Get from https://github.com/settings/tokens
TF_VAR_github_token=ghp_...

# Optional - For enhanced features
TF_VAR_tavily_api_key=tvly-...
TF_VAR_morphllm_api_key=...
```

#### Mixed Configuration (Supported)
You can use both methods - file-based secrets take priority, environment variables as fallback.

## Deployment Steps

### Step 1: Configure Secrets (Choose Your Method)

#### Method A: Using File-Based Secrets (Recommended)

If your secrets are managed via `/opt/secrets/manage-secrets.sh`:

```bash
# Verify your secrets system is working
ssh coder@192.168.71.2
sudo /opt/secrets/manage-secrets.sh get-secret ANTHROPIC_API_KEY

# The template will automatically detect and use file-based secrets
# No additional Coder configuration needed!
```

#### Method B: Using Environment Variables (Fallback)

If using traditional environment variables:

```bash
ssh coder@192.168.71.2
sudo nano /etc/coder/coder.env
```

Add your API keys:
```bash
# Claude Code (Required)
TF_VAR_anthropic_api_key=sk-ant-api03-...

# GitHub (Optional) 
TF_VAR_github_token=ghp_...

# Additional APIs (Optional)
TF_VAR_tavily_api_key=tvly-...
TF_VAR_morphllm_api_key=...
```

Restart Coder service:
```bash
sudo systemctl restart coder
```

#### Method C: Mixed Configuration

You can use both! File-based secrets take priority, with environment variables as fallback for any missing secrets.

### Step 2: Clone Template Repository

Navigate to your templates directory:
```bash
cd /opt/coder/templates  # or wherever you store templates
```

Clone this repository:
```bash
git clone https://github.com/stuartcarroll/claude-dev.git
cd claude-dev
```

### Step 3: Create Template in Coder

Create the template:
```bash
coder templates create claude-dev
```

Or if updating an existing template:
```bash
coder templates push claude-dev
```

### Step 4: Verify Template

List available templates to confirm:
```bash
coder templates list
```

You should see `claude-dev` in the list.

### Step 5: Test Template & Verify Secrets Integration

Create a test workspace:
```bash
coder create test-workspace --template claude-dev
```

Wait for the workspace to start, then SSH into it:
```bash
coder ssh test-workspace
```

**NEW: Comprehensive verification with secrets integration:**

```bash
# Test secrets management system
get-secret ANTHROPIC_API_KEY  # Should return your API key
get-secret GITHUB_TOKEN       # Should return token or empty if not configured

# Run comprehensive authentication test
claude-auth

# Verify Claude Code with context awareness
cd /home/coder/projects
claude-with-context  # or 'cw'

# Check what MCPs are dynamically configured
claude --list-mcps

# View Claude's workspace knowledge
cat ~/.claude/WORKSPACE_CONTEXT.md

# Test GitHub integration (if token available)
gh auth status
```

**Expected output should show:**
- ✅ Secrets retrieved successfully
- ✅ Claude Code authenticated automatically  
- ✅ MCPs configured based on available secrets
- ✅ GitHub CLI authenticated (if token provided)
- ✅ Claude pre-loaded with workspace context

### Step 6: Clean Up Test

Delete the test workspace when satisfied:
```bash
coder delete test-workspace
```

## Template Updates

When you make changes to the template:

### 1. Update Local Repository
```bash
cd /opt/coder/templates/claude-dev
git pull origin main
```

### 2. Push Updated Template
```bash
coder templates push claude-dev
```

### 3. Recreate Existing Workspaces (if needed)
```bash
# Stop workspace
coder stop workspace-name

# Start workspace (will use updated template)
coder start workspace-name
```

## Troubleshooting Deployment

### Template Creation Fails

**Check Terraform syntax:**
```bash
cd /opt/coder/templates/claude-dev
terraform validate
```

**Check Coder logs:**
```bash
sudo journalctl -u coder -f
```

### Environment Variables Not Working

**Verify variables are set:**
```bash
sudo systemctl show coder --property=Environment
```

**Check if Coder service restarted:**
```bash
sudo systemctl status coder
```

### Docker Issues

**Verify Docker is running:**
```bash
sudo systemctl status docker
```

**Check Docker permissions:**
```bash
sudo usermod -aG docker coder
```

### Network Issues

**Test container can reach external services:**
```bash
# From inside a workspace
curl -I https://api.anthropic.com
curl -I https://api.github.com
```

## Production Considerations

### 1. Resource Limits
Default container limits:
- Memory: 4GB
- CPU: 1024 shares
- Storage: Persistent volumes for home and projects

Adjust in `main.tf`:
```hcl
resource "docker_container" "workspace" {
  memory = 8192        # 8GB
  cpu_shares = 2048    # More CPU
}
```

### 2. Security
- API keys are passed as environment variables (secure)
- Docker socket is mounted (required for Docker-in-Docker)
- Containers run as non-root user
- Network access is limited to container

### 3. Backup
Important directories to backup:
- `/opt/coder/templates/` - Template definitions
- `/etc/coder/coder.env` - Environment configuration
- Docker volumes (automatic via Coder)

### 4. Monitoring
Monitor these metrics:
- Container resource usage (built-in Coder metrics)
- API key usage limits
- Docker storage usage

## Advanced Configuration

### Custom Base Image
To use a custom base image, modify `build/Dockerfile`:
```dockerfile
FROM your-custom-image:latest
# ... rest of Dockerfile
```

### Additional Tools
Add tools in `build/Dockerfile` or startup script in `main.tf`:
```dockerfile
RUN apt-get update && apt-get install -y \
    your-additional-tool \
    another-tool
```

### Custom MCP Servers
Add to the MCP configuration in `main.tf`:
```json
"custom-mcp": {
  "command": "your-mcp-command",
  "args": ["--your-args"],
  "env": {
    "YOUR_ENV_VAR": "$YOUR_VALUE"
  }
}
```

### Multiple Environments
Create variations by copying the template:
```bash
cp -r claude-dev claude-dev-python
# Modify claude-dev-python for Python-specific tools
```

## Support and Maintenance

### Getting Help
1. Check Coder documentation: https://coder.com/docs
2. Review template logs in Coder UI
3. Check container startup logs
4. Verify API key permissions and limits

### Regular Maintenance
- Update base image monthly
- Keep Claude Code CLI updated
- Monitor API key usage
- Review and update MCP servers
- Backup template configurations

### Template Versioning
Tag releases for production use:
```bash
git tag v1.0.0
git push origin v1.0.0
```

Reference specific versions in production:
```bash
coder templates create claude-dev --git-ref v1.0.0
```
terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

#===============================================================================
# Variables (from Coder's TF_VAR_* environment variables)
#===============================================================================

variable "anthropic_api_key" {
  type        = string
  description = "Anthropic API key for Claude Code"
  sensitive   = true
  default     = ""
}

variable "github_token" {
  type        = string
  description = "GitHub Personal Access Token for git operations"
  sensitive   = true
  default     = ""
}

variable "tavily_api_key" {
  type        = string
  description = "Tavily API key for SuperClaude research"
  sensitive   = true
  default     = ""
}

variable "morphllm_api_key" {
  type        = string
  description = "MorphLLM API key for alternative LLM access"
  sensitive   = true
  default     = ""
}

#===============================================================================
# Parameters
#===============================================================================

data "coder_parameter" "dev_pattern" {
  name         = "dev_pattern"
  display_name = "Development Pattern"
  description  = "Select a development pattern to apply to your workspace"
  type         = "string"
  default      = "none"
  mutable      = false
  option {
    name  = "None"
    value = "none"
    description = "No pattern - clean workspace"
  }
  option {
    name  = "Laravel Standard"
    value = "laravel-standard"
    description = "PHP Laravel framework with standard tools"
  }
  option {
    name  = "Python API"
    value = "python-api"
    description = "Python FastAPI/Flask development setup"
  }
  option {
    name  = "Python Data"
    value = "python-data"
    description = "Python data science and analytics setup"
  }
  option {
    name  = "Node.js Full-Stack"
    value = "node-fullstack"
    description = "Node.js with React/Vue frontend development"
  }
}

#===============================================================================
# Data Sources
#===============================================================================

data "coder_provisioner" "me" {}

data "coder_workspace" "me" {}

data "coder_workspace_owner" "me" {}

#===============================================================================
# Provider Configuration
#===============================================================================

provider "docker" {}

provider "coder" {}

#===============================================================================
# Coder Agent
#===============================================================================

resource "coder_agent" "main" {
  arch           = data.coder_provisioner.me.arch
  os             = "linux"
  startup_script = <<-EOT
    set -e

    # Install Claude Code CLI (already installed globally, but check)
    if ! command -v claude &> /dev/null; then
      echo "Installing Claude Code..."
      npm install -g @anthropic-ai/claude-code
    fi

    # Install SuperClaude in background (non-blocking)
    echo "Starting SuperClaude installation in background..."
    {
      echo "$(date): Starting SuperClaude installation..." > ~/.superclaude_install.log
      
      # Install pipx and SuperClaude
      if ! command -v superclaude >/dev/null 2>&1; then
        echo "$(date): Installing pipx..." >> ~/.superclaude_install.log
        python3 -m pip install --user --break-system-packages pipx >>~/.superclaude_install.log 2>&1
        
        # Ensure PATH is updated for this session
        export PATH="$HOME/.local/bin:$PATH"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        
        echo "$(date): Installing SuperClaude from GitHub..." >> ~/.superclaude_install.log
        python3 -m pipx install git+https://github.com/NomenAK/SuperClaude.git >>~/.superclaude_install.log 2>&1
        
        # Install Playwright (this takes time, so do it in background)
        echo "$(date): Installing Playwright..." >> ~/.superclaude_install.log
        python3 -m pipx inject superclaude playwright >>~/.superclaude_install.log 2>&1
        ~/.local/share/pipx/venvs/superclaude/bin/python -m playwright install chromium >>~/.superclaude_install.log 2>&1
        
        echo "$(date): SuperClaude installation completed successfully" >> ~/.superclaude_install.log
      else
        echo "$(date): SuperClaude already installed" >> ~/.superclaude_install.log
      fi
      
      # Configure with Tavily API key if available
      if [ -n "$TAVILY_API_KEY" ]; then
        echo "$(date): Configuring SuperClaude with Tavily API key..." >> ~/.superclaude_install.log
        mkdir -p ~/.config/superclaude
        cat > ~/.config/superclaude/config.json << EOF
{
  "tavily_api_key": "$TAVILY_API_KEY", 
  "search_provider": "tavily"
}
EOF
        echo 'export TAVILY_API_KEY="$TAVILY_API_KEY"' >> ~/.bashrc
        echo "$(date): SuperClaude configured with Tavily integration" >> ~/.superclaude_install.log
      fi
    } &
    
    # Continue with startup while SuperClaude installs in background
    echo "✅ SuperClaude installation started (background process - check ~/.superclaude_install.log)"

    # Note: GitHub CLI configuration will be done after secret retrieval is set up

    # Initialize git repository in projects directory for MCP git server
    cd /home/coder/projects
    if [ ! -d ".git" ]; then
      echo "Initializing git repository for MCP git server..."
      git init
      git config user.name "Workspace User"
      git config user.email "user@workspace.local"
    fi
    
    # Configure authentication from environment (secrets injected by Infisical)
    echo "=== Configuring Authentication ==="
    
    # All secrets are provided via environment variables by Infisical
    echo "Using Infisical-injected environment variables..."
    
    # These are already set in the environment by the container configuration
    # Just validate they exist
    
    # Export environment variables
    export ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY"
    export TAVILY_API_KEY="$TAVILY_API_KEY"
    export GITHUB_TOKEN="$GITHUB_TOKEN"
    export GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_TOKEN"
    export GH_TOKEN="$GITHUB_TOKEN"
    export BRAVE_API_KEY="$TAVILY_API_KEY"
    export MORPHLLM_API_KEY="$MORPHLLM_API_KEY"
    
    # Add to shell profile for persistence
    echo "export ANTHROPIC_API_KEY='$ANTHROPIC_API_KEY'" >> ~/.bashrc
    echo "export TAVILY_API_KEY='$TAVILY_API_KEY'" >> ~/.bashrc
    echo "export GITHUB_TOKEN='$GITHUB_TOKEN'" >> ~/.bashrc
    echo "export GITHUB_PERSONAL_ACCESS_TOKEN='$GITHUB_TOKEN'" >> ~/.bashrc
    echo "export GH_TOKEN='$GITHUB_TOKEN'" >> ~/.bashrc
    echo "export BRAVE_API_KEY='$TAVILY_API_KEY'" >> ~/.bashrc
    echo "export MORPHLLM_API_KEY='$MORPHLLM_API_KEY'" >> ~/.bashrc
    
    # Validate required secrets
    if [ -z "$ANTHROPIC_API_KEY" ]; then
        echo "❌ ERROR: ANTHROPIC_API_KEY is required but not found in environment"
        echo "Please ensure it's injected via Infisical or set as environment variable"
        # Don't exit, but Claude Code won't work
    else
        echo "✅ ANTHROPIC_API_KEY found and configured"
    fi
    
    # Configure GitHub CLI if token is available
    if [ -n "$GITHUB_TOKEN" ]; then
        echo "✅ GITHUB_TOKEN found - Configuring GitHub integration..."
        
        git config --global credential.helper store
        echo "https://$GITHUB_TOKEN@github.com" > ~/.git-credentials
        chmod 600 ~/.git-credentials
        
        # Authenticate GitHub CLI
        echo "$GITHUB_TOKEN" | gh auth login --with-token
        
        # Verify authentication worked
        if gh auth status >/dev/null 2>&1; then
          echo "✅ GitHub CLI authentication successful"
        else
          echo "⚠️  GitHub CLI authentication failed, but token is available in environment"
        fi
        
        # Configure git with GitHub user info (with fallbacks)
        GH_USER_NAME=$(gh api user 2>/dev/null | jq -r .name 2>/dev/null || echo "")
        GH_USER_EMAIL=$(gh api user 2>/dev/null | jq -r .email 2>/dev/null || echo "")
        
        if [ -n "$GH_USER_NAME" ] && [ "$GH_USER_NAME" != "null" ]; then
          git config --global user.name "$GH_USER_NAME"
          echo "✅ Git user.name set to: $GH_USER_NAME"
        else
          git config --global user.name "Coder User"
          echo "⚠️  Using fallback git user.name: Coder User"
        fi
        
        if [ -n "$GH_USER_EMAIL" ] && [ "$GH_USER_EMAIL" != "null" ]; then
          git config --global user.email "$GH_USER_EMAIL"
          echo "✅ Git user.email set to: $GH_USER_EMAIL"
        else
          git config --global user.email "user@workspace.local"
          echo "⚠️  Using fallback git user.email: user@workspace.local"
        fi
    else
        echo "⚠️  GITHUB_TOKEN not found - GitHub features will be skipped"
        
        # Set fallback git configuration when no GitHub token
        git config --global user.name "Coder User"
        git config --global user.email "user@workspace.local"
        echo "✅ Set fallback git configuration"
    fi
    
    if [ -n "$TAVILY_API_KEY" ]; then
        echo "✅ TAVILY_API_KEY found - Web search features will be enabled"
    else
        echo "⚠️  TAVILY_API_KEY not found - Web search features will be limited"
    fi
    
    # Create Claude Code config directories
    mkdir -p ~/.config/claude-code
    mkdir -p ~/.claude
    
    # Claude Code is installed but requires manual authentication
    if [ -n "$ANTHROPIC_API_KEY" ]; then
      echo "✅ Claude Code is installed. To authenticate, run: claude login"
      echo "   Your API key is available in the environment as ANTHROPIC_API_KEY"
    fi
    
    # Create Claude settings for automatic directory trust
    cat > ~/.claude/settings.json << EOF
{
  "trustedDirectories": ["/home/coder", "/home/coder/projects"],
  "autoAcceptDirectoryTrust": true,
  "skipSecurityWarnings": true
}
EOF

    # Configure Claude Code MCP settings in the projects directory
    mkdir -p /home/coder/projects
    echo "Configuring MCP servers based on available secrets..."
    
    # Start building MCP configuration
    cat > /home/coder/projects/.mcp.json << 'MCPEOF'
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
    }
MCPEOF

    # Add GitHub MCP only if token is available
    if [ -n "$GITHUB_TOKEN" ]; then
        echo "Adding GitHub MCP server..."
        sed -i '$s/}//' /home/coder/projects/.mcp.json
        cat >> /home/coder/projects/.mcp.json << EOF
    ,
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "$GITHUB_TOKEN"
      }
    }
EOF
    else
        echo "Skipping GitHub MCP server (no token available)"
    fi
    
    # Add Brave Search MCP only if Tavily API key is available
    if [ -n "$TAVILY_API_KEY" ]; then
        echo "Adding Brave Search MCP server..."
        sed -i '$s/}//' /home/coder/projects/.mcp.json
        cat >> /home/coder/projects/.mcp.json << EOF
    ,
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "$TAVILY_API_KEY"
      }
    }
EOF
    else
        echo "Skipping Brave Search MCP server (no Tavily API key available)"
    fi
    
    # Close the MCP configuration
    cat >> /home/coder/projects/.mcp.json << 'MCPEOF'
  }
}
MCPEOF

    # Also create a global Claude config for general settings
    cat > ~/.claude/config.json << EOF
{
  "trustedDirectories": ["/home/coder", "/home/coder/projects"],
  "autoAcceptDirectoryTrust": true,
  "skipSecurityWarnings": true
}
EOF

    # Set proper ownership
    chown coder:coder /home/coder/projects/.mcp.json

    # Register MCP servers with Claude
    echo "=== Registering MCP servers with Claude ==="
    
    # Core MCP servers (always available)
    echo "Adding core MCP servers..."
    claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem /home/coder/projects 2>/dev/null || true
    claude mcp add git -- npx -y @modelcontextprotocol/server-git --repository /home/coder/projects 2>/dev/null || true
    claude mcp add memory -- npx -y @modelcontextprotocol/server-memory 2>/dev/null || true
    claude mcp add serena -- npx -y @anthropic-ai/mcp-server-serena /home/coder/projects 2>/dev/null || true
    
    # Optional MCP servers based on available secrets
    if [ -n "$GITHUB_TOKEN" ]; then
        echo "Adding GitHub MCP server..."
        claude mcp add github --env GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_TOKEN" -- npx -y @modelcontextprotocol/server-github 2>/dev/null || true
    fi
    
    if [ -n "$TAVILY_API_KEY" ]; then
        echo "Adding Tavily MCP server..."
        claude mcp add tavily --env TAVILY_API_KEY="$TAVILY_API_KEY" -- npx -y tavily-mcp@0.1.4 2>/dev/null || true
        
        echo "Adding Brave Search MCP server..."
        claude mcp add brave-search --env BRAVE_API_KEY="$TAVILY_API_KEY" -- npx -y @modelcontextprotocol/server-brave-search 2>/dev/null || true
    fi
    
    echo "✅ MCP servers registered with Claude"

    # Final authentication check and setup
    echo "=== Final Authentication Check ==="
    
    # Ensure Claude Code is properly authenticated
    if command -v claude &> /dev/null && [ -n "$ANTHROPIC_API_KEY" ]; then
      # Test if authentication is working
      if ! timeout 15 claude --version >/dev/null 2>&1; then
        echo "Claude authentication failed, attempting final setup..."
        
        # Last resort: Create the auth token file in the expected location
        mkdir -p ~/.config/claude-code
        cat > ~/.config/claude-code/auth.json << EOF
{
  "apiKey": "$ANTHROPIC_API_KEY",
  "authMethod": "api_key"
}
EOF
        chmod 600 ~/.config/claude-code/auth.json
        
        # Also try setting it in the environment more permanently
        echo "export ANTHROPIC_API_KEY='$ANTHROPIC_API_KEY'" > ~/.config/claude-code/env
        source ~/.config/claude-code/env
      fi
    fi

    echo "=== Workspace Setup Complete ==="
    echo "✓ Secrets management system integrated"
    echo "✓ Claude Code installed and configured"
    echo "✓ MCPs configured in /home/coder/projects/.mcp.json"
    
    # Dynamic status based on available secrets
    if [ -n "$GITHUB_TOKEN" ]; then
        echo "✅ GitHub integration enabled (CLI + MCP)"
    else
        echo "⚠️  GitHub integration disabled (no token)"
    fi
    
    if [ -n "$TAVILY_API_KEY" ]; then
        echo "✅ Web search enabled (SuperClaude + Brave MCP)"
    else
        echo "⚠️  Web search limited (no Tavily API key)"
    fi
    
    echo "✓ SuperClaude installing in background (check ~/.superclaude_install.log)"
    echo ""
    echo "🚀 Start coding with: cd /home/coder/projects && claude"
    # echo "🌐 Or use code-server: http://localhost:8080" # Removed for minimal build
    echo ""
    echo "📋 Core MCPs: filesystem, git, memory, serena"
    
    # Show optional MCPs
    OPTIONAL_MCPS=""
    [ -n "$GITHUB_TOKEN" ] && OPTIONAL_MCPS="$OPTIONAL_MCPS github"
    [ -n "$TAVILY_API_KEY" ] && OPTIONAL_MCPS="$OPTIONAL_MCPS tavily brave-search"
    if [ -n "$OPTIONAL_MCPS" ]; then
        echo "📋 Optional MCPs:$OPTIONAL_MCPS"
    fi
    
    echo ""
    echo "🔧 Commands:"
    echo "   Test authentication: claude-auth"
    echo "   Check environment: env | grep -E 'ANTHROPIC|GITHUB|TAVILY'"
    echo "   Check GitHub: gh auth status"
    echo "   Claude context: cat ~/.claude/WORKSPACE_CONTEXT.md"
    
    # Initialize Claude context with workspace information
    echo ""
    echo "=== Initializing Claude Context ==="
    init-claude-context
    
    echo ""
    echo "💡 Claude is now pre-configured with knowledge of:"
    echo "   • Infisical secrets management (environment variables)"
    echo "   • Development pattern: $DEV_PATTERN"
    echo "   • Available services and MCPs"
    echo "   • Workspace layout and tools"
  EOT

  # Environment variables for the workspace
  env = {
    ANTHROPIC_API_KEY = var.anthropic_api_key
    GITHUB_TOKEN      = var.github_token
    TAVILY_API_KEY    = var.tavily_api_key
    MORPHLLM_API_KEY  = var.morphllm_api_key

    # Claude Code configuration
    CLAUDE_CODE_USE_BEDROCK = "0"
    
    # Development pattern selection
    DEV_PATTERN = data.coder_parameter.dev_pattern.value
    
    # Development services connection endpoints
    DEV_POSTGRES_HOST = "host.docker.internal"
    DEV_POSTGRES_PORT = "5432"
    DEV_MYSQL_HOST    = "host.docker.internal"
    DEV_MYSQL_PORT    = "3306"
    DEV_REDIS_HOST    = "host.docker.internal"
    DEV_REDIS_PORT    = "6379"
    DEV_MINIO_HOST    = "host.docker.internal"
    DEV_MINIO_PORT    = "9000"
  }

  # Metadata displayed in Coder UI
  metadata {
    display_name = "CPU Usage"
    key          = "cpu"
    script       = "coder stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Memory Usage"
    key          = "mem"
    script       = "coder stat mem"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Disk Usage"
    key          = "disk"
    script       = "coder stat disk --path /home/coder"
    interval     = 60
    timeout      = 1
  }
}

#===============================================================================
# Coder Script (for long-running processes)
#===============================================================================

# Commented out for minimal build - uncomment if you need VS Code in browser
# resource "coder_script" "code_server" {
#   agent_id = coder_agent.main.id
#   
#   display_name = "code-server"
#   icon         = "/icon/code.svg"
#   
#   script = <<-EOT
#     #!/bin/bash
#     # Start code-server and keep it running
#     exec code-server --bind-addr 0.0.0.0:8080
#   EOT
#   
#   run_on_start = true
# }

#===============================================================================
# Coder Apps (Web UIs)
#===============================================================================

# Commented out for minimal build - uncomment if you need VS Code in browser
# resource "coder_app" "code-server" {
#   agent_id     = coder_agent.main.id
#   slug         = "code-server"
#   display_name = "VS Code"
#   url          = "http://localhost:8080/?folder=/home/coder/projects"
#   icon         = "/icon/code.svg"
#   subdomain    = true
#   share        = "owner"
# 
#   healthcheck {
#     url       = "http://localhost:8080/healthz"
#     interval  = 5
#     threshold = 6
#   }
# }

#===============================================================================
# Docker Image
#===============================================================================

resource "docker_image" "claude_dev" {
  name = "claude-workspace:minimal-github-v3"
  build {
    context    = "./build"
    dockerfile = "Dockerfile"
  }
  triggers = {
    dockerfile_hash = filemd5("${path.module}/build/Dockerfile")
  }
}

#===============================================================================
# Docker Volume (persistent home directory)
#===============================================================================

resource "docker_volume" "home_volume" {
  name = "coder-${data.coder_workspace_owner.me.name}-${data.coder_workspace.me.name}-home"
}

resource "docker_volume" "projects_volume" {
  name = "coder-${data.coder_workspace_owner.me.name}-${data.coder_workspace.me.name}-projects"
}

#===============================================================================
# Docker Container
#===============================================================================

resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count

  image = docker_image.claude_dev.image_id
  name  = "coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}"

  # Hostname
  hostname = data.coder_workspace.me.name

  # DNS
  dns = ["1.1.1.1", "8.8.8.8"]

  # Coder agent init command
  entrypoint = ["sh", "-c", coder_agent.main.init_script]

  # Environment
  env = [
    "CODER_AGENT_TOKEN=${coder_agent.main.token}",
    "ANTHROPIC_API_KEY=${var.anthropic_api_key}",
    "GITHUB_TOKEN=${var.github_token}",
    "GITHUB_PERSONAL_ACCESS_TOKEN=${var.github_token}",
    "TAVILY_API_KEY=${var.tavily_api_key}",
    "BRAVE_API_KEY=${var.tavily_api_key}",
    "MORPHLLM_API_KEY=${var.morphllm_api_key}",
    "DEV_PATTERN=${data.coder_parameter.dev_pattern.value}",
    "DEV_POSTGRES_HOST=host.docker.internal",
    "DEV_POSTGRES_PORT=5432",
    "DEV_MYSQL_HOST=host.docker.internal",
    "DEV_MYSQL_PORT=3306",
    "DEV_REDIS_HOST=host.docker.internal",
    "DEV_REDIS_PORT=6379",
    "DEV_MINIO_HOST=host.docker.internal",
    "DEV_MINIO_PORT=9000",
  ]

  # Resource limits
  memory = 4096
  cpu_shares = 1024

  # Volumes
  volumes {
    container_path = "/home/coder"
    volume_name    = docker_volume.home_volume.name
    read_only      = false
  }

  volumes {
    container_path = "/home/coder/projects"
    volume_name    = docker_volume.projects_volume.name
    read_only      = false
  }

  # Docker socket for container operations (optional)
  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
    read_only      = false
  }

  # Pattern system integration
  volumes {
    container_path = "/patterns"
    host_path      = "/opt/dev-patterns"
    read_only      = true
  }

  # Development services
  volumes {
    container_path = "/dev-services"
    host_path      = "/opt/dev-services"
    read_only      = true
  }

  # Secrets are now handled via Infisical environment injection

  # Keep container running
  stdin_open = true
  tty        = true
}

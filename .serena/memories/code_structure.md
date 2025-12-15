# Codebase Structure

## Root Directory Structure
```
claude-dev/
├── main.tf                     # Main Terraform configuration
├── build/                      # Container build files
│   ├── Dockerfile             # Ubuntu 24.04 container definition
│   ├── config.yaml            # Code-server configuration
│   ├── get-secret.sh          # Universal secret retrieval helper
│   ├── claude-auth.sh         # Authentication testing script
│   ├── init-claude-context.sh # Claude workspace context initialization
│   ├── CLAUDE.md              # Workspace documentation for Claude
│   └── claude-startup-prompt.md # Welcome message for Claude sessions
├── README.md                   # Main project documentation
├── DEPLOYMENT.md              # Deployment guide
├── TROUBLESHOOTING.md         # Troubleshooting guide
├── EXAMPLES.md                # Usage examples
└── CHANGELOG.md               # Version history
```

## Key Components
- **Terraform Files**: Infrastructure definition for Coder workspaces
- **Shell Scripts**: Helper scripts for secrets management and authentication
- **Documentation**: Comprehensive guides for deployment, troubleshooting, and usage
- **Container Build**: Dockerfile and supporting configuration files

## Configuration Files
- `.gitignore`: Git ignore rules
- `.claude/settings.local.json`: Claude local settings
- `build/config.yaml`: VS Code server configuration
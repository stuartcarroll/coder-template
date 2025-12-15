# Changelog

All notable changes to the Claude Development Environment Coder Template will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- **Simplified Authentication**: Removed automatic Claude login attempts in favor of manual authentication
- **Better User Experience**: Users now authenticate once with `claude login` instead of dealing with startup failures
- **Cleaner Startup**: Faster container initialization without authentication timeouts

### Added
- **Serena MCP**: Added @anthropic-ai/mcp-server-serena for advanced code navigation and editing

### Removed
- **Auto-login**: Removed all automatic Claude authentication attempts from startup
- **claude-auth.sh**: Removed authentication helper script as it's no longer needed

## [2.0.0] - 2024-12-10

### Added - Major Features

#### 🔑 File-Based Secrets Management Integration
- **Complete integration** with `/opt/secrets/manage-secrets.sh` system
- **Priority-based fallback**: File-based → Environment variables (`TF_VAR_*`)
- **Universal `get-secret` command** for safe secret retrieval
- **Dynamic feature configuration** based on available secrets
- **Graceful degradation** when secrets are missing

#### 🧠 Claude Context Pre-configuration
- **Workspace awareness**: Claude pre-loaded with complete environment knowledge
- **Memory integration**: Persistent context across Claude sessions
- **Documentation embedding**: CLAUDE.md and startup prompts built into container
- **Helper functions**: `claude-with-context` and `cw` aliases
- **Dynamic status reporting**: Real-time secret and feature availability

#### 🔧 Enhanced Development Experience
- **Smart MCP configuration**: Servers enabled based on available API keys
- **Comprehensive error handling**: Clear messages and recovery instructions
- **Multi-method authentication**: Robust Claude Code login with fallbacks
- **Development pattern support**: Laravel, Python API/Data, Node.js full-stack

### Changed - Major Improvements

#### 🚀 Startup Process
- **Redesigned startup flow** with proper secret initialization order
- **Fixed circular dependency** in `get_secret()` function
- **Enhanced status messages** with emoji indicators and clear feedback
- **Improved error recovery** with helpful troubleshooting commands

#### 📋 MCP Configuration
- **Dynamic server list** based on available secrets
- **Conditional GitHub MCP** (requires `GITHUB_TOKEN`)
- **Conditional Brave Search MCP** (requires `TAVILY_API_KEY`)
- **Core MCPs always available**: filesystem, git, memory
- **Proper environment variable mapping** for GitHub MCP

#### 🛠️ Tool Integration
- **Enhanced GitHub CLI setup** with automatic user configuration
- **SuperClaude integration** with Tavily API configuration
- **Docker socket mounting** for container development
- **Pre-configured service endpoints**: PostgreSQL, MySQL, Redis, MinIO

### Fixed - Critical Issues

#### 🐛 Startup Script Fixes
- **Resolved `get_secret: command not found`** error during startup
- **Fixed circular function reference** in secret retrieval
- **Corrected GitHub MCP environment variable** (`GITHUB_PERSONAL_ACCESS_TOKEN`)
- **Improved authentication order** to prevent dependency issues

#### 🔐 Authentication Improvements
- **Multiple Claude Code authentication methods** with comprehensive fallbacks
- **Timeout protection** to prevent hanging during startup
- **Direct config file creation** when interactive login fails
- **Enhanced error messages** for authentication troubleshooting

### Security

#### 🔒 Secrets Handling
- **Read-only secrets volume** mounting from `/opt/secrets`
- **Secure environment variable handling** with proper escaping
- **No secrets in logs** with redacted output in error messages
- **Proper file permissions** on generated credential files

## [1.0.0] - 2024-12-09

### Added - Initial Release

#### Core Features
- **Basic Claude Code integration** with environment variable authentication
- **MCP server configuration**: filesystem, git, memory, github
- **VS Code Server** setup with browser access
- **GitHub CLI** installation and basic configuration
- **SuperClaude** installation via pipx
- **Container environment**: Ubuntu 24.04, Node.js 22, Python 3.12

#### Infrastructure
- **Terraform configuration** for Coder workspaces
- **Docker image build** with development tools
- **Persistent volumes** for home directory and projects
- **Resource monitoring** with CPU, memory, disk metrics
- **Development patterns** parameter selection

#### Documentation
- **Basic README** with setup instructions
- **Deployment guide** for Coder server installation
- **Usage examples** for core tools

---

## Migration Guide

### From v1.x to v2.0

#### Required Changes
1. **Update server secrets**: Ensure `/opt/secrets/manage-secrets.sh` is available or configure `TF_VAR_*` variables
2. **Recreate workspaces**: New containers required for latest features
3. **Update deployment**: Pull latest template and push to Coder server

#### New Commands Available
- `get-secret <secret_name>` - Universal secret retrieval
- `claude-auth` - Comprehensive authentication testing
- `claude-with-context` or `cw` - Enhanced Claude startup
- `init-claude-context` - Manual context initialization

#### Breaking Changes
- **MCP configuration location**: Now in `/home/coder/projects/.mcp.json` (was `~/.claude/config.json`)
- **GitHub MCP environment**: Uses `GITHUB_PERSONAL_ACCESS_TOKEN` (was `GITHUB_TOKEN`)
- **Startup behavior**: More verbose with status reporting

### Compatibility Notes
- **Backward compatible** with existing `TF_VAR_*` environment variables
- **Graceful fallback** when file-based secrets are not available
- **Existing workspaces** will continue to work but won't have new features until recreated

---

## Support

For issues and questions:
- **Template Issues**: Create issue in GitHub repository
- **Claude Code**: Check authentication with `claude-auth`
- **Secrets Management**: Verify with `get-secret` command
- **Documentation**: Read built-in guides with `cat ~/.claude/WORKSPACE_CONTEXT.md`
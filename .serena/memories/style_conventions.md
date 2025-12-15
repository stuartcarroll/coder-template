# Code Style and Conventions

## Terraform Conventions
- Clear section separators with comments (e.g., `#===============================================================================`)
- Variables grouped at the top with descriptions and sensitivity flags
- Providers configured after data sources
- Meaningful resource names following `resource_type_purpose` pattern

## Shell Script Conventions
- Bash scripts with proper error handling
- Functions for reusable logic
- Clear comments explaining complex operations
- Use of `set -e` for error handling where appropriate
- Proper quoting of variables

## Documentation Style
- Markdown format for all documentation
- Clear section headers with emojis for visual distinction
- Code examples with syntax highlighting
- Step-by-step instructions for complex procedures
- Troubleshooting sections with common issues and solutions

## Naming Conventions
- **Files**: Lowercase with hyphens (e.g., `claude-auth.sh`)
- **Variables**: Lowercase with underscores (e.g., `anthropic_api_key`)
- **Functions**: Lowercase with underscores
- **Environment Variables**: Uppercase with underscores (e.g., `ANTHROPIC_API_KEY`)

## Security Practices
- Sensitive variables marked with `sensitive = true` in Terraform
- API keys never hardcoded, always from environment or secrets system
- Read-only access to secrets directory
- Proper file permissions for scripts
# Suggested Commands for Development

## Terraform Commands
```bash
# Validate Terraform configuration
terraform validate

# Format Terraform files
terraform fmt

# Plan infrastructure changes
terraform plan

# Initialize Terraform
terraform init
```

## Coder Template Commands
```bash
# Create/update template in Coder
coder templates create claude-dev
coder templates push claude-dev

# List templates
coder templates list

# Delete template
coder templates delete claude-dev
```

## Git Commands
```bash
# Check repository status
git status

# Stage and commit changes
git add .
git commit -m "Description of changes"

# Push to GitHub
git push origin master

# Pull latest changes
git pull origin master
```

## Testing & Validation
```bash
# Test shell scripts
bash -n script.sh  # Syntax check
shellcheck script.sh  # Linting (if available)

# Test Dockerfile build locally
docker build -t claude-dev-test build/

# Validate JSON files
jq . < file.json
```

## Documentation Commands
```bash
# Preview markdown files (if grip is installed)
grip README.md

# Check for broken links in markdown
# (Would need a tool like markdown-link-check)
```

## Development Workflow Commands
```bash
# Navigate to project
cd "C:\Users\StuCarroll\coder template\claude-dev"

# Open in VS Code
code .

# View recent changes
git log --oneline -10

# Check differences
git diff
```

## Utility Commands for Windows
```bash
# List files
dir /b
ls  # If using Git Bash or WSL

# Find files
where filename
find . -name "filename"  # In Git Bash/WSL

# Search in files
findstr "pattern" *.tf
grep -r "pattern" .  # In Git Bash/WSL

# View file contents
type filename.txt
cat filename.txt  # In Git Bash/WSL
```
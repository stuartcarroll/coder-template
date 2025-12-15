# Task Completion Checklist

When completing development tasks on this Coder template project, ensure you:

## Code Quality Checks
1. **Terraform Validation**
   - Run `terraform fmt` to format all .tf files
   - Run `terraform validate` to check syntax
   - Ensure all variables have descriptions
   - Mark sensitive variables appropriately

2. **Shell Script Validation**
   - Check syntax with `bash -n script.sh`
   - Test scripts in a safe environment
   - Ensure proper error handling
   - Add comments for complex operations

3. **Documentation Updates**
   - Update README.md if features change
   - Update CHANGELOG.md with version changes
   - Ensure examples in EXAMPLES.md are current
   - Add troubleshooting entries if new issues discovered

## Testing Requirements
1. **Local Testing**
   - Build Docker image locally to verify Dockerfile changes
   - Test shell scripts individually
   - Validate all JSON configuration files

2. **Integration Testing**
   - Deploy template to a test Coder instance
   - Create a workspace from the template
   - Verify all features work as documented
   - Test with both file-based and environment variable secrets

## Security Review
1. **Secrets Management**
   - No hardcoded API keys or tokens
   - All sensitive data marked appropriately
   - Proper file permissions on scripts
   - Secrets accessed through approved methods only

2. **Container Security**
   - Minimal required packages installed
   - No unnecessary privileges
   - Proper user permissions

## Pre-Commit Checklist
- [ ] All code formatted properly
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] No sensitive data exposed
- [ ] Scripts tested
- [ ] Terraform validated
- [ ] Git commit message describes changes clearly

## Deployment Checklist
- [ ] Template tested in Coder
- [ ] All features verified working
- [ ] Documentation reflects current state
- [ ] GitHub repository updated
- [ ] Coder template pushed/updated
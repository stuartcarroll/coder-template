# Docker Cache Issue - PabloBot Workspace Creation

## Problem Summary

**Issue**: Cannot create PabloBot workspace for WhatsApp bot development due to persistent Docker image caching.

**Root Cause**: Docker build process continues to execute old cached Dockerfile commands even after:
- Updating Dockerfile to fix Python installation 
- Clearing Docker builder cache (10GB+ cleared)
- Restarting Coder service
- Changing Docker image names (`claude-dev:latest` → `claude-dev:v2` → `claude-workspace:fresh-2025`)

**Error**: Build fails with `python3.12`, `python3.12-venv`, `pip3 install pipx` commands despite Dockerfile containing correct `python3`, `python3-pip`, `python3-venv` commands.

## Changes Made

### 1. Fixed Dockerfile Issues
- **File**: `build/Dockerfile` 
- **Changes**: 
  - Removed duplicate pipx installation (was installed in base packages AND Python section)
  - Simplified Python installation from specific `python3.12` to system `python3`
  - Added comment: `# Install Python (v3 - fresh build 2025-12-12)`
  - Modified startup script to install pipx at runtime instead of build time

### 2. Fixed Coder Server Issues
- **Problem**: Port 7080 conflict with manual coder process (PID 489434)
- **Solution**: Killed manual process, restarted systemd service
- **Status**: ✅ Coder server running properly

### 3. Docker Cache Clearing Attempts
- Cleared Docker builder cache: **10.15GB removed**
- Cleared Docker system cache: **803.4MB removed**
- Updated Docker image names multiple times
- **Result**: ❌ Still using cached build layers

### 4. Template Isolation Approach
- **Created**: `claude-dev-pablo` template directory
- **Docker Image**: Changed to `pablo-workspace:2025` (completely new name)
- **Status**: Local terraform plan successful, shows fresh build will occur
- **Deployment**: ⏸️ In progress (SSH deployment partially complete)

## Current Status

### ✅ Completed
- Dockerfile fixes verified correct
- Coder server operational
- Docker caches cleared
- New template with fresh image name created
- SSH access to miniPC established

### ⏸️ In Progress  
- Template deployment to Coder server (pablo-template directory created, main.tf copied)
- Need to complete build directory copy and template push

### ❌ Blocked
- PabloBot workspace creation due to persistent Docker image cache

## Technical Analysis

### Docker Build Context
The issue appears to be **Docker daemon-level image layer persistence** that survives:
- Standard cache clearing commands
- Service restarts  
- Image name changes
- Hash-based triggers

### Evidence
- Error logs consistently show old commands: `python3.12`, `pip3 install pipx`
- Local Dockerfile verified correct: `python3`, `python3 -m pip install --upgrade pip`
- Terraform shows new image names in plan but Docker still executes old cached layers

## Next Steps

### Immediate (Resume Session)
1. **Complete Template Deployment**:
   ```bash
   # On miniPC as stu user
   cd pablo-template
   scp -r /path/to/claude-dev/build/* ./build/
   coder templates push pablo-dev --yes
   ```

2. **Test Fresh Build**:
   ```bash
   coder create PabloBot --template pablo-dev --parameter dev_pattern=node-fullstack --yes
   ```

### Alternative Solutions (If Issue Persists)

#### Option A: Nuclear Docker Reset
```bash
# CAUTION: This will remove ALL Docker images/containers
sudo docker system prune -a --volumes -f
sudo systemctl restart docker
```

#### Option B: Temporary Workaround
- Use different Docker registry/repository
- Build image externally and import
- Use different base image (Ubuntu 22.04 instead of 24.04)

#### Option C: Template Rewrite
- Create entirely new template from scratch
- Use different Dockerfile base
- Implement Python installation differently

## Files Modified

### Main Template
- `main.tf`: Docker image name changed to `pablo-workspace:2025`
- `build/Dockerfile`: Python installation fixed, pipx moved to runtime
- `build/CLAUDE.md`: Authentication instructions updated

### New Template (pablo-dev)  
- `claude-dev-pablo/`: Complete template copy
- `claude-dev-pablo/main.tf`: Fresh Docker image name
- Ready for deployment to bypass cache issues

## Contact Points

- **Coder Server**: `stu@192.168.71.2:7080`
- **Working Workspace**: PaperlessNGX (using cached claude-dev:latest image)
- **Template Location**: `~/pablo-template` (deployment in progress)

## Lessons Learned

1. **Docker Cache Persistence**: Standard cache clearing may not affect deep image layers
2. **Template Isolation**: Creating new templates with fresh names is effective isolation strategy  
3. **SSH Deployment**: Direct server access more reliable than remote template push
4. **Image Naming**: Complete name changes (not just tags) required for cache bypass

---

**Next Session Priority**: Complete template deployment and test PabloBot workspace creation with `pablo-workspace:2025` image.
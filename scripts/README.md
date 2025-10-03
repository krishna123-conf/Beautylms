# Beauty LMS Scripts

Collection of deployment, testing, and maintenance scripts for Beauty LMS.

## 🚀 Production Deployment Scripts

### `production_deploy.sh`
**Purpose**: One-command production deployment
**Usage**: `./production_deploy.sh`
**Description**: 
- Automated deployment script for Beauty LMS backend
- Checks prerequisites (Node.js, PM2, Nginx, FFmpeg)
- Installs dependencies
- Validates configuration
- Starts application with PM2
- Runs health checks

**Prerequisites**:
- Must be run as `beautylms` user
- Must be in Beauty-lms root directory
- All dependencies must be installed

**Time**: ~5 minutes

---

### `optimize_for_production.sh`
**Purpose**: System optimization for 1000-1500 concurrent users
**Usage**: `sudo ./optimize_for_production.sh`
**Description**:
- Optimizes system limits (file descriptors, processes)
- Tunes kernel network parameters
- Configures systemd limits
- Optimizes Nginx for high performance
- Installs monitoring tools
- Sets up swap (if needed)
- Configures log rotation
- Creates monitoring scripts

**Prerequisites**:
- Must be run as root or with sudo
- Fresh system recommended

**Time**: ~3 minutes

**Important**: Requires system reboot after completion

---

## 🔧 Configuration Scripts

### `setup_firebase.sh`
**Purpose**: Firebase credentials configuration
**Usage**: `./setup_firebase.sh`
**Description**:
- Interactive Firebase setup helper
- Uploads service account key
- Configures environment variables
- Tests Firebase connection

**Time**: ~5 minutes

---

### `setup_recording_paths.sh`
**Purpose**: Recording directory setup
**Usage**: `./setup_recording_paths.sh`
**Description**:
- Creates recording directory structure
- Sets proper permissions
- Configures Nginx for recordings
- Creates environment template

**Time**: ~2 minutes

---

## ✅ Verification Scripts

### `verify_deployment.sh`
**Purpose**: Comprehensive deployment verification
**Usage**: `./verify_deployment.sh yourdomain.com`
**Description**:
- Tests DNS resolution
- Checks SSL certificate
- Verifies API endpoints
- Tests WebSocket connections
- Checks recording functionality
- Validates security headers
- Measures performance

**Time**: ~1 minute

**Example**:
```bash
./verify_deployment.sh krishnabarasiya.space
```

---

## 🧪 Testing Scripts

### `test_mediasoup.sh`
**Purpose**: MediaSoup configuration testing
**Usage**: `./test_mediasoup.sh`
**Description**:
- Tests MediaSoup port availability
- Checks firewall configuration
- Validates announced IP
- Tests system resources
- Provides optimization recommendations

**Time**: ~1 minute

---

### `system_validation.js`
**Purpose**: Complete system validation
**Usage**: `node system_validation.js`
**Description**:
- Validates package.json
- Checks environment variables
- Tests dependencies
- Validates configuration files
- Comprehensive system check

**Time**: ~30 seconds

---

### `test_api_locally.sh`
**Purpose**: Local API testing
**Usage**: `./test_api_locally.sh`
**Description**:
- Tests local API endpoints
- Validates responses
- Checks health endpoint

**Time**: ~30 seconds

---

### `test_recording_api.js`
**Purpose**: Recording API testing
**Usage**: `node test_recording_api.js`
**Description**:
- Tests recording start/stop
- Validates recording files
- Checks cleanup functionality

**Time**: ~1 minute

---

### `test_flutter_integration.js`
**Purpose**: Flutter integration testing
**Usage**: `node test_flutter_integration.js`
**Description**:
- Tests Flutter frontend integration
- Validates API compatibility
- Checks WebSocket connections

**Time**: ~2 minutes

---

## 🔍 Maintenance Scripts

### `comprehensive_test.js`
**Purpose**: Complete system test
**Usage**: `node comprehensive_test.js`
**Description**:
- Tests all API endpoints
- Validates database connections
- Checks MediaSoup functionality
- Tests Socket.IO

**Time**: ~3 minutes

---

## 📊 Usage Examples

### Quick Production Deployment
```bash
# 1. Optimize system first (as root)
sudo ./scripts/optimize_for_production.sh
sudo reboot

# 2. After reboot, deploy application (as beautylms)
cd ~/Beauty-lms
./scripts/production_deploy.sh

# 3. Verify deployment
./scripts/verify_deployment.sh yourdomain.com
```

### Setup Firebase
```bash
# Interactive Firebase setup
./scripts/setup_firebase.sh
```

### Regular Testing
```bash
# Test MediaSoup configuration
./scripts/test_mediasoup.sh

# Validate entire system
node scripts/system_validation.js

# Test API locally
./scripts/test_api_locally.sh
```

### Deployment Verification
```bash
# Comprehensive deployment check
./scripts/verify_deployment.sh yourdomain.com
```

---

## 🛠️ Script Requirements

### All Scripts
- Bash 4.0+
- Basic Linux utilities (curl, grep, awk, sed)

### Production Scripts
- Root/sudo access (for optimize_for_production.sh)
- beautylms user (for production_deploy.sh)

### Testing Scripts
- Node.js v18+
- Application installed and configured

---

## 📝 Script Execution Order

### Initial Setup
1. `optimize_for_production.sh` (as root) → Reboot
2. `setup_firebase.sh` (as beautylms)
3. `setup_recording_paths.sh` (as beautylms)
4. `production_deploy.sh` (as beautylms)
5. `verify_deployment.sh` (to validate)

### Regular Testing
1. `test_api_locally.sh`
2. `test_mediasoup.sh`
3. `system_validation.js`

### Deployment Verification
1. `verify_deployment.sh yourdomain.com`

---

## 🔒 Security Notes

- **production_deploy.sh**: Must be run as beautylms user (not root)
- **optimize_for_production.sh**: Must be run as root for system changes
- **setup_firebase.sh**: Handles sensitive credentials - use caution
- All scripts log to appropriate locations
- Never commit credentials to version control

---

## 📚 Documentation

For detailed information about deployment and configuration:
- **[HOSTINGER_VPS_DEPLOYMENT.md](../HOSTINGER_VPS_DEPLOYMENT.md)** - Complete deployment guide
- **[QUICK_REFERENCE.md](../QUICK_REFERENCE.md)** - Quick command reference
- **[DEPLOYMENT_SUMMARY.md](../DEPLOYMENT_SUMMARY.md)** - Deployment overview

---

## 🐛 Troubleshooting

### Script Won't Execute
```bash
# Make script executable
chmod +x scripts/script_name.sh

# Check shebang line
head -1 scripts/script_name.sh  # Should be #!/bin/bash
```

### Permission Denied
```bash
# Production scripts need proper user
# Check if running as correct user
whoami

# For root scripts
sudo ./scripts/optimize_for_production.sh

# For user scripts
sudo su - beautylms
./scripts/production_deploy.sh
```

### Script Fails
```bash
# Check script output carefully
# Most scripts provide detailed error messages

# Common issues:
# 1. Wrong directory: cd ~/Beauty-lms
# 2. Missing dependencies: Check prerequisites
# 3. Wrong user: Switch to correct user
# 4. Permissions: Check file permissions
```

---

## 📞 Support

For issues with scripts:
1. Check script output for error messages
2. Review relevant documentation
3. Check prerequisites are met
4. Verify you're running as the correct user
5. Open an issue on GitHub with script output

---

## 🔄 Updates

Scripts are maintained alongside the main application. 
Check repository for latest versions.

**Last Updated**: 2024
**Version**: 1.0.0

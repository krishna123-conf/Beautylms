#!/bin/bash

# Beauty LMS Quick Production Deployment Script
# One-command deployment for Hostinger VPS Ubuntu

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║        Beauty LMS Production Deployment Script               ║"
echo "║              For Hostinger VPS Ubuntu                         ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running as beautylms user
if [ "$USER" != "beautylms" ]; then
    log_error "This script must be run as 'beautylms' user"
    log_info "Run: sudo su - beautylms"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "backend/package.json" ]; then
    log_error "Not in Beautylms root directory"
    log_info "Navigate to: cd ~/Beautylms"
    exit 1
fi

echo ""
log_info "Starting deployment process..."
echo ""

# Step 1: Check prerequisites
echo "═══════════════════════════════════════"
echo "Step 1: Checking Prerequisites"
echo "═══════════════════════════════════════"

check_command() {
    if command -v $1 &> /dev/null; then
        log_success "$1 is installed"
        return 0
    else
        log_error "$1 is not installed"
        return 1
    fi
}

PREREQS_OK=true

check_command "node" || PREREQS_OK=false
check_command "npm" || PREREQS_OK=false
check_command "pm2" || PREREQS_OK=false
check_command "nginx" || PREREQS_OK=false
check_command "ffmpeg" || PREREQS_OK=false

if [ "$PREREQS_OK" = false ]; then
    log_error "Missing prerequisites. Please install required software first."
    log_info "Refer to HOSTINGER_VPS_DEPLOYMENT.md for installation instructions"
    exit 1
fi

echo ""

# Step 2: Install dependencies
echo "═══════════════════════════════════════"
echo "Step 2: Installing Dependencies"
echo "═══════════════════════════════════════"

log_info "Installing backend dependencies..."
cd backend
npm install --production
log_success "Backend dependencies installed"
echo ""

# Step 3: Check environment configuration
echo "═══════════════════════════════════════"
echo "Step 3: Checking Configuration"
echo "═══════════════════════════════════════"

if [ ! -f ".env.production" ]; then
    log_warning ".env.production not found"
    
    if [ -f ".env.production.example" ]; then
        log_info "Creating .env.production from example..."
        cp .env.production.example .env.production
        log_warning "IMPORTANT: Edit .env.production with your actual values"
        log_info "Required variables:"
        echo "  • FIREBASE_PROJECT_ID"
        echo "  • MEDIASOUP_ANNOUNCED_IP (your server's public IP)"
        echo "  • CORS_ORIGINS (your domain)"
        echo "  • JWT_SECRET (generate with: openssl rand -base64 64)"
        read -p "Press Enter to edit .env.production now (or Ctrl+C to exit)..."
        nano .env.production
    else
        log_error ".env.production.example not found"
        exit 1
    fi
fi

# Validate critical environment variables
log_info "Validating environment variables..."
MISSING_VARS=false

check_env_var() {
    if ! grep -q "^$1=" .env.production || grep -q "^$1=your-" .env.production; then
        log_warning "Variable $1 not configured properly"
        MISSING_VARS=true
    fi
}

check_env_var "FIREBASE_PROJECT_ID"
check_env_var "MEDIASOUP_ANNOUNCED_IP"

if [ "$MISSING_VARS" = true ]; then
    log_error "Some required environment variables are not configured"
    read -p "Do you want to edit .env.production now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        nano .env.production
    else
        log_error "Cannot proceed without proper configuration"
        exit 1
    fi
fi

# Check Firebase credentials
if grep -q "GOOGLE_APPLICATION_CREDENTIALS" .env.production; then
    CRED_PATH=$(grep "GOOGLE_APPLICATION_CREDENTIALS" .env.production | cut -d'=' -f2)
    if [ ! -f "$CRED_PATH" ]; then
        log_error "Firebase credentials file not found: $CRED_PATH"
        log_info "Please upload your serviceAccountKey.json to: $CRED_PATH"
        exit 1
    else
        log_success "Firebase credentials file found"
    fi
fi

log_success "Configuration validated"
echo ""

# Step 4: Create necessary directories
echo "═══════════════════════════════════════"
echo "Step 4: Setting Up Directories"
echo "═══════════════════════════════════════"

cd ~/Beautylms

log_info "Creating required directories..."
mkdir -p logs
mkdir -p recordings/{active,completed,failed,temp,private}

log_success "Directories created"
echo ""

# Step 5: Build frontend (if exists)
echo "═══════════════════════════════════════"
echo "Step 5: Building Frontend (Optional)"
echo "═══════════════════════════════════════"

if [ -d "frontend" ] && [ -f "frontend/package.json" ]; then
    log_info "Frontend detected. Building..."
    cd frontend
    
    if [ ! -d "node_modules" ]; then
        log_info "Installing frontend dependencies..."
        npm install
    fi
    
    log_info "Building production bundle..."
    npm run build
    log_success "Frontend built successfully"
    cd ..
else
    log_info "No frontend directory found, skipping..."
fi
echo ""

# Step 6: Test application
echo "═══════════════════════════════════════"
echo "Step 6: Testing Application"
echo "═══════════════════════════════════════"

log_info "Running quick test..."
cd backend

# Test that the app can start
timeout 10 node -e "
require('dotenv').config({path: '.env.production'});
console.log('✓ Environment loaded');
console.log('✓ PORT:', process.env.PORT || '3000');
console.log('✓ NODE_ENV:', process.env.NODE_ENV || 'production');
" && log_success "Application configuration test passed" || log_error "Configuration test failed"

echo ""

# Step 7: Start with PM2
echo "═══════════════════════════════════════"
echo "Step 7: Starting Application with PM2"
echo "═══════════════════════════════════════"

log_info "Stopping any existing instances..."
pm2 delete beauty-lms-backend 2>/dev/null || true

log_info "Starting application..."
pm2 start ecosystem.config.js --env production

log_info "Saving PM2 process list..."
pm2 save

log_success "Application started"
echo ""

# Wait for application to initialize
log_info "Waiting for application to initialize..."
sleep 5

# Check if application is running
if pm2 status | grep -q "online"; then
    log_success "Application is running!"
else
    log_error "Application failed to start. Check logs: pm2 logs beauty-lms-backend"
    exit 1
fi

echo ""

# Step 8: Test health endpoint
echo "═══════════════════════════════════════"
echo "Step 8: Testing Application"
echo "═══════════════════════════════════════"

log_info "Testing health endpoint..."
sleep 2

if curl -s http://localhost:3000/health | grep -q "OK"; then
    log_success "Health check passed!"
else
    log_warning "Health check failed. Application might still be starting..."
    log_info "Check logs: pm2 logs beauty-lms-backend"
fi

echo ""

# Step 9: Display status
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                 DEPLOYMENT COMPLETED                          ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

log_success "Beauty LMS backend is now running!"
echo ""
echo "📊 Application Status:"
pm2 status
echo ""

echo "📝 Useful Commands:"
echo "  • View logs:        pm2 logs beauty-lms-backend"
echo "  • Monitor:          pm2 monit"
echo "  • Restart:          pm2 restart beauty-lms-backend"
echo "  • Stop:             pm2 stop beauty-lms-backend"
echo "  • Status:           pm2 status"
echo ""

echo "🔗 Next Steps:"
echo "  1. Configure Nginx (if not already done)"
echo "  2. Setup SSL certificate with Certbot"
echo "  3. Test from external access: https://yourdomain.com/health"
echo "  4. Monitor performance: ~/monitor-performance.sh"
echo "  5. Review deployment guide: HOSTINGER_VPS_DEPLOYMENT.md"
echo ""

log_info "Deployment log saved to: ~/Beautylms/deployment.log"

# Save deployment info
cat > ~/Beautylms/deployment.log << EOF
Deployment completed: $(date)
Node version: $(node --version)
npm version: $(npm --version)
PM2 version: $(pm2 --version)
Application status: $(pm2 jlist | jq -r '.[0].pm2_env.status' 2>/dev/null || echo "running")
EOF

log_success "Deployment complete! 🚀"

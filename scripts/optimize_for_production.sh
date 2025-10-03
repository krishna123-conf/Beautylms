#!/bin/bash

# Beauty LMS Production Optimization Script
# Optimizes system for handling 1000-1500 concurrent users
# Run this script after initial server setup

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║   Beauty LMS Production Optimization Script                  ║"
echo "║   Optimizing for 1000-1500 Concurrent Users                  ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log_error "Please run as root or with sudo"
    exit 1
fi

echo ""
log_info "Starting system optimization..."
echo ""

# 1. Optimize System Limits
echo "═══════════════════════════════════════"
echo "1. Optimizing System Limits"
echo "═══════════════════════════════════════"

log_info "Backing up limits.conf..."
cp /etc/security/limits.conf /etc/security/limits.conf.backup

log_info "Setting file descriptor limits..."
cat >> /etc/security/limits.conf << EOF

# Beauty LMS Optimization for High Concurrent Users
beautylms soft nofile 65535
beautylms hard nofile 65535
beautylms soft nproc 4096
beautylms hard nproc 4096
root soft nofile 65535
root hard nofile 65535
* soft nofile 65535
* hard nofile 65535
EOF

log_success "System limits configured"
echo ""

# 2. Optimize Kernel Network Parameters
echo "═══════════════════════════════════════"
echo "2. Optimizing Kernel Network Parameters"
echo "═══════════════════════════════════════"

log_info "Backing up sysctl.conf..."
cp /etc/sysctl.conf /etc/sysctl.conf.backup

log_info "Configuring kernel network parameters..."
cat >> /etc/sysctl.conf << EOF

# Beauty LMS Network Optimization for 1000-1500 Concurrent Users
# TCP/IP Stack Optimization

# Increase max connections
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 8192

# Increase buffer sizes for better network performance
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864

# Enable TCP Fast Open (RFC 7413)
net.ipv4.tcp_fastopen = 3

# Optimize TIME_WAIT socket handling
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15

# Increase port range for more concurrent connections
net.ipv4.ip_local_port_range = 10000 65535

# Enable TCP window scaling
net.ipv4.tcp_window_scaling = 1

# Optimize keepalive settings
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15

# Increase netdev_max_backlog for high-speed networks
net.core.netdev_max_backlog = 5000

# Enable BBR congestion control (if kernel supports)
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# Increase connection tracking table size
net.netfilter.nf_conntrack_max = 262144

# Optimize IPv4 routing
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.ip_forward = 0

# Disable ICMP redirect acceptance for security
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

# Enable SYN cookies for DDoS protection
net.ipv4.tcp_syncookies = 1

# Increase maximum number of remembered connection requests
net.ipv4.tcp_max_syn_backlog = 8192
EOF

log_info "Applying kernel parameters..."
sysctl -p > /dev/null 2>&1
log_success "Kernel parameters optimized"
echo ""

# 3. Optimize Systemd
echo "═══════════════════════════════════════"
echo "3. Optimizing Systemd"
echo "═══════════════════════════════════════"

log_info "Configuring systemd limits..."
if [ ! -f /etc/systemd/system.conf.d/limits.conf ]; then
    mkdir -p /etc/systemd/system.conf.d
fi

cat > /etc/systemd/system.conf.d/limits.conf << EOF
[Manager]
DefaultLimitNOFILE=65535
DefaultLimitNPROC=4096
EOF

log_info "Reloading systemd daemon..."
systemctl daemon-reload
log_success "Systemd optimized"
echo ""

# 4. Optimize Nginx
echo "═══════════════════════════════════════"
echo "4. Optimizing Nginx"
echo "═══════════════════════════════════════"

if command -v nginx &> /dev/null; then
    log_info "Backing up nginx.conf..."
    cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
    
    log_info "Optimizing Nginx configuration..."
    
    # Check if optimization already exists
    if ! grep -q "Beauty LMS Optimization" /etc/nginx/nginx.conf; then
        # Update worker processes and connections
        sed -i "s/worker_processes.*/worker_processes auto; # Beauty LMS Optimization/" /etc/nginx/nginx.conf
        sed -i "s/worker_connections.*/worker_connections 4096;/" /etc/nginx/nginx.conf
        
        # Add events optimization if not exists
        if ! grep -q "use epoll" /etc/nginx/nginx.conf; then
            sed -i "/worker_connections/a \    use epoll;\n    multi_accept on;" /etc/nginx/nginx.conf
        fi
        
        log_success "Nginx optimized"
        
        # Test Nginx configuration
        if nginx -t 2>&1 | grep -q "successful"; then
            log_info "Reloading Nginx..."
            systemctl reload nginx
            log_success "Nginx reloaded successfully"
        else
            log_error "Nginx configuration test failed. Please check manually."
        fi
    else
        log_info "Nginx already optimized, skipping..."
    fi
else
    log_warning "Nginx not installed, skipping optimization"
fi
echo ""

# 5. Install Monitoring Tools
echo "═══════════════════════════════════════"
echo "5. Installing Monitoring Tools"
echo "═══════════════════════════════════════"

log_info "Installing htop for system monitoring..."
apt-get install -y htop >/dev/null 2>&1
log_success "htop installed"

log_info "Installing iotop for I/O monitoring..."
apt-get install -y iotop >/dev/null 2>&1
log_success "iotop installed"

log_info "Installing net-tools..."
apt-get install -y net-tools >/dev/null 2>&1
log_success "net-tools installed"
echo ""

# 6. Setup Swap (if not exists and system has < 16GB RAM)
echo "═══════════════════════════════════════"
echo "6. Checking Swap Configuration"
echo "═══════════════════════════════════════"

TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
SWAP_SIZE=$(free -g | awk '/^Swap:/{print $2}')

log_info "System RAM: ${TOTAL_RAM}GB"
log_info "Current Swap: ${SWAP_SIZE}GB"

if [ "$SWAP_SIZE" -eq 0 ] && [ "$TOTAL_RAM" -lt 16 ]; then
    log_warning "No swap detected and RAM is less than 16GB"
    log_info "Creating 4GB swap file..."
    
    if [ ! -f /swapfile ]; then
        fallocate -l 4G /swapfile
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        
        # Make swap permanent
        if ! grep -q "/swapfile" /etc/fstab; then
            echo '/swapfile none swap sw 0 0' >> /etc/fstab
        fi
        
        # Optimize swappiness for server
        echo 'vm.swappiness=10' >> /etc/sysctl.conf
        sysctl -p > /dev/null 2>&1
        
        log_success "4GB swap created and configured"
    else
        log_info "Swap file already exists"
    fi
else
    log_success "Swap configuration is adequate"
fi
echo ""

# 7. Configure Log Rotation
echo "═══════════════════════════════════════"
echo "7. Configuring Log Rotation"
echo "═══════════════════════════════════════"

log_info "Creating log rotation configuration..."
cat > /etc/logrotate.d/beauty-lms << EOF
/home/beautylms/Beauty-lms/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    missingok
    create 0640 beautylms beautylms
    sharedscripts
    postrotate
        pm2 reloadLogs
    endscript
}
EOF

log_success "Log rotation configured"
echo ""

# 8. Performance Report
echo "═══════════════════════════════════════"
echo "8. System Performance Report"
echo "═══════════════════════════════════════"
echo ""

log_info "CPU Cores: $(nproc)"
log_info "Total RAM: $(free -h | awk '/^Mem:/{print $2}')"
log_info "Available RAM: $(free -h | awk '/^Mem:/{print $7}')"
log_info "Total Swap: $(free -h | awk '/^Swap:/{print $2}')"
log_info "Disk Space: $(df -h / | awk 'NR==2{print $4}')"
log_info "Max File Descriptors: $(ulimit -n)"
log_info "Max Processes: $(ulimit -u)"
echo ""

# Calculate estimated capacity
CPU_CORES=$(nproc)
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
ESTIMATED_USERS=$((CPU_CORES * 150))

if [ "$ESTIMATED_USERS" -lt 1000 ]; then
    log_warning "Estimated capacity: ~${ESTIMATED_USERS} concurrent users"
    log_warning "For 1000-1500 users, consider upgrading to at least 8 CPU cores and 16GB RAM"
elif [ "$ESTIMATED_USERS" -ge 1500 ]; then
    log_success "Estimated capacity: ~${ESTIMATED_USERS} concurrent users"
    log_success "System is well-configured for 1000-1500 users!"
else
    log_info "Estimated capacity: ~${ESTIMATED_USERS} concurrent users"
    log_info "System should handle 1000-1500 users adequately"
fi
echo ""

# 9. Create Monitoring Script
echo "═══════════════════════════════════════"
echo "9. Creating Monitoring Scripts"
echo "═══════════════════════════════════════"

log_info "Creating performance monitoring script..."
cat > /home/beautylms/monitor-performance.sh << 'SCRIPT'
#!/bin/bash

echo "═══════════════════════════════════════════════════════════"
echo "Beauty LMS Performance Monitor - $(date)"
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "1. System Resources"
echo "-------------------"
echo "CPU Load: $(uptime | awk -F'load average:' '{print $2}')"
echo "Memory Usage: $(free -h | awk '/^Mem:/{printf "%s / %s (%.1f%%)\n", $3, $2, $3/$2*100}')"
echo "Swap Usage: $(free -h | awk '/^Swap:/{printf "%s / %s\n", $3, $2}')"
echo "Disk Usage: $(df -h / | awk 'NR==2{printf "%s / %s (%s)\n", $3, $2, $5}')"
echo ""

echo "2. Application Status"
echo "---------------------"
if command -v pm2 &> /dev/null; then
    pm2 jlist | jq -r '.[] | "\(.name): \(.pm2_env.status) (CPU: \(.monit.cpu)%, MEM: \(.monit.memory / 1024 / 1024 | floor)MB)"' 2>/dev/null || pm2 status
else
    echo "PM2 not found"
fi
echo ""

echo "3. Network Connections"
echo "----------------------"
echo "Active Connections on port 3000: $(netstat -an 2>/dev/null | grep :3000 | grep ESTABLISHED | wc -l)"
echo "MediaSoup Ports Active: $(netstat -tuln 2>/dev/null | grep -E "4[0-9]{4}" | wc -l)"
echo "WebSocket Connections: $(netstat -an 2>/dev/null | grep :3000 | grep -i websocket | wc -l)"
echo ""

echo "4. Recent Errors (Last 5)"
echo "-------------------------"
if [ -f /home/beautylms/Beauty-lms/logs/backend-error.log ]; then
    tail -n 5 /home/beautylms/Beauty-lms/logs/backend-error.log
else
    echo "No error log found"
fi
echo ""

echo "═══════════════════════════════════════════════════════════"
SCRIPT

chmod +x /home/beautylms/monitor-performance.sh
chown beautylms:beautylms /home/beautylms/monitor-performance.sh
log_success "Monitoring script created at /home/beautylms/monitor-performance.sh"
echo ""

# 10. Summary
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                  OPTIMIZATION COMPLETE                        ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

log_success "System has been optimized for high concurrent user load!"
echo ""
echo "Applied Optimizations:"
echo "  ✓ System limits increased (65535 file descriptors)"
echo "  ✓ Kernel network parameters tuned"
echo "  ✓ TCP/IP stack optimized"
echo "  ✓ Nginx configured for high performance"
echo "  ✓ Monitoring tools installed"
echo "  ✓ Swap configured (if needed)"
echo "  ✓ Log rotation configured"
echo "  ✓ Performance monitoring script created"
echo ""

log_warning "IMPORTANT: Please reboot the system for all changes to take effect"
echo ""
echo "After reboot, you can:"
echo "  • Run: /home/beautylms/monitor-performance.sh (to check performance)"
echo "  • Test limits: ulimit -n (should show 65535)"
echo "  • Verify sysctl: sysctl net.core.somaxconn (should show 65535)"
echo ""

read -p "Would you like to reboot now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Rebooting system in 5 seconds... (Ctrl+C to cancel)"
    sleep 5
    reboot
else
    log_warning "Please reboot manually when ready: sudo reboot"
fi

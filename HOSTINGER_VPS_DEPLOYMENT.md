# Beauty LMS - Hostinger VPS Deployment Guide (Ubuntu)

Complete production deployment guide for hosting Beauty LMS on Hostinger VPS with Ubuntu, optimized for **1000-1500 concurrent users** in a live course.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Server Requirements](#server-requirements)
3. [Initial Server Setup](#initial-server-setup)
4. [Install Dependencies](#install-dependencies)
5. [Deploy Application](#deploy-application)
6. [Configure Firewall](#configure-firewall)
7. [Setup SSL Certificate](#setup-ssl-certificate)
8. [Configure Nginx](#configure-nginx)
9. [Setup Process Manager (PM2)](#setup-process-manager-pm2)
10. [Configure Environment Variables](#configure-environment-variables)
11. [Start Application](#start-application)
12. [Monitoring & Maintenance](#monitoring--maintenance)
13. [Performance Optimization](#performance-optimization)
14. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before starting, ensure you have:

- ✅ Hostinger VPS with Ubuntu 20.04 or 22.04 LTS
- ✅ Root or sudo access to the VPS
- ✅ Domain name pointed to your VPS IP address
- ✅ Firebase project created with Firestore enabled
- ✅ Firebase service account key JSON file downloaded
- ✅ Basic knowledge of Linux command line

---

## Server Requirements

### Recommended VPS Specifications for 1000-1500 Users:

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **CPU** | 4 vCPU cores | 8+ vCPU cores |
| **RAM** | 8 GB | 16 GB or more |
| **Storage** | 50 GB SSD | 100 GB SSD |
| **Bandwidth** | 5 TB/month | 10 TB/month |
| **Network** | 1 Gbps | 1 Gbps |

**Hostinger VPS Plans:**
- Minimum: VPS 4 or VPS 8 plan
- Recommended: VPS 8 or KVM 4 plan

### Why These Specifications?

- **CPU**: MediaSoup creates one worker per CPU core. More cores = better video processing
- **RAM**: Each video connection uses ~5-10 MB. For 1500 users: 1500 × 10 MB ≈ 15 GB
- **Bandwidth**: Video conferencing is bandwidth-intensive (2-5 Mbps per user)
- **Storage**: For recording video sessions

---

## Initial Server Setup

### Step 1: Connect to Your VPS

```bash
# Connect via SSH (use details from Hostinger panel)
ssh root@your-server-ip
```

### Step 2: Update System

```bash
# Update package lists
sudo apt update

# Upgrade installed packages
sudo apt upgrade -y

# Install essential tools
sudo apt install -y curl wget git build-essential software-properties-common
```

### Step 3: Create Application User

For security, don't run the application as root:

```bash
# Create a dedicated user for the application
# Using --gecos "," to skip prompts for user information (Full Name, Room Number, etc.)
sudo adduser beautylms --disabled-password --gecos ","

# Add user to sudo group (optional, for administrative tasks)
sudo usermod -aG sudo beautylms

# Switch to the new user
sudo su - beautylms
```

### Step 4: Setup Directory Structure

```bash
# Create necessary directories
mkdir -p ~/Beauty-lms
mkdir -p ~/.credentials
mkdir -p ~/Beauty-lms/logs
mkdir -p ~/Beauty-lms/recordings/{active,completed,failed,temp,private}

# Set proper permissions
chmod 700 ~/.credentials
chmod 755 ~/Beauty-lms/recordings
```

---

## Install Dependencies

### Step 1: Install Node.js (v18 LTS)

```bash
# Install Node.js 18.x LTS (recommended for production)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installation
node --version  # Should show v18.x.x
npm --version   # Should show 9.x.x or higher
```

### Step 2: Install FFmpeg (for recording)

```bash
# Install FFmpeg with all required codecs
sudo apt install -y ffmpeg

# Verify installation
ffmpeg -version
```

### Step 3: Install PM2 (Process Manager)

```bash
# Install PM2 globally
sudo npm install -g pm2

# Setup PM2 startup script
pm2 startup systemd -u beautylms --hp /home/beautylms
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u beautylms --hp /home/beautylms
```

### Step 4: Install Nginx (Web Server)

```bash
# Install Nginx
sudo apt install -y nginx

# Verify Nginx is running
sudo systemctl status nginx
```

### Step 5: Install Certbot (for SSL)

```bash
# Install Certbot for Let's Encrypt SSL
sudo apt install -y certbot python3-certbot-nginx
```

---

## Deploy Application

### Step 1: Clone Repository

```bash
# Clone the Beauty LMS repository
cd ~/Beauty-lms
git clone https://github.com/krishna123-conf/Beautylms.git .

# If repository is private, you'll need to setup SSH keys or use HTTPS with credentials
```

### Step 2: Install Backend Dependencies

```bash
cd ~/Beauty-lms/backend
npm install --production

# This will install all required Node.js packages
# Should complete without errors
```

### Step 3: Install Frontend Dependencies (Optional - if hosting frontend)

```bash
cd ~/Beauty-lms/frontend
npm install
npm run build

# This creates an optimized production build in the 'build' folder
```

---

## Configure Firewall

### Setup UFW (Uncomplicated Firewall)

```bash
# Enable UFW
sudo ufw enable

# Allow SSH (IMPORTANT - do this first to avoid locking yourself out!)
sudo ufw allow 22/tcp

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow MediaSoup RTC ports (40000-49999)
# This range is critical for video conferencing
sudo ufw allow 40000:49999/udp
sudo ufw allow 40000:49999/tcp

# Check firewall status
sudo ufw status verbose
```

### Expected Output:
```
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
40000:49999/tcp            ALLOW       Anywhere
40000:49999/udp            ALLOW       Anywhere
```

---

## Setup SSL Certificate

### Step 1: Configure DNS

Before requesting SSL certificate, ensure:
- Your domain's A record points to your VPS IP address
- Wait for DNS propagation (can take up to 48 hours, usually 5-10 minutes)

Verify DNS:
```bash
nslookup yourdomain.com
# Should return your VPS IP address
```

### Step 2: Obtain SSL Certificate

```bash
# Replace yourdomain.com with your actual domain
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Follow the prompts:
# 1. Enter your email address
# 2. Agree to Terms of Service
# 3. Choose whether to redirect HTTP to HTTPS (recommended: Yes)
```

### Step 3: Setup Auto-Renewal

```bash
# Test renewal process
sudo certbot renew --dry-run

# Certbot automatically creates a cron job for renewal
# Verify it's scheduled:
sudo systemctl status certbot.timer
```

---

## Configure Nginx

### Step 1: Backup Default Configuration

```bash
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
```

### Step 2: Create Beauty LMS Nginx Configuration

```bash
# Copy the provided nginx.conf to Nginx sites-available
sudo cp ~/Beauty-lms/nginx.conf /etc/nginx/sites-available/beauty-lms

# Edit the configuration to match your domain and paths
sudo nano /etc/nginx/sites-available/beauty-lms
```

**Important: Update these values in the nginx.conf file:**
- Replace `yourdomain.com` with your actual domain (appears in multiple places)
- Update SSL certificate paths if different
- Verify all file paths match your setup

### Step 3: Enable Site and Test Configuration

```bash
# Remove default site
sudo rm /etc/nginx/sites-enabled/default

# Enable Beauty LMS site
sudo ln -s /etc/nginx/sites-available/beauty-lms /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t

# Should output:
# nginx: configuration file /etc/nginx/nginx.conf test is successful

# If test passes, reload Nginx
sudo systemctl reload nginx
```

### Step 4: Optimize Nginx for High Concurrent Connections

Edit the main Nginx configuration:
```bash
sudo nano /etc/nginx/nginx.conf
```

Add/update these settings in the `http` block:

```nginx
# Worker processes - set to number of CPU cores
worker_processes auto;

# Maximum connections per worker
events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
}

http {
    # ... existing configuration ...
    
    # Optimize for high concurrent connections
    keepalive_timeout 65;
    keepalive_requests 1000;
    
    # Buffer sizes
    client_body_buffer_size 128k;
    client_max_body_size 100m;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 16k;
    
    # Timeouts
    client_body_timeout 60s;
    client_header_timeout 60s;
    send_timeout 60s;
    
    # File upload settings
    client_body_temp_path /var/lib/nginx/body;
    
    # Enable sendfile for better performance
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
}
```

Restart Nginx:
```bash
sudo systemctl restart nginx
```

---

## Setup Process Manager (PM2)

### Step 1: Verify PM2 Ecosystem File

The repository includes an `ecosystem.config.js` file optimized for production:

```bash
cat ~/Beauty-lms/backend/ecosystem.config.js
```

### Step 2: Understand PM2 Configuration

The ecosystem configuration:
- **Cluster Mode**: Runs multiple instances (one per CPU core)
- **Auto-restart**: Automatically restarts on crashes
- **Memory Limit**: Restarts if memory exceeds 1GB
- **Load Balancing**: Distributes requests across all instances

### Step 3: Test PM2 Configuration

```bash
cd ~/Beauty-lms/backend

# Test that PM2 can read the config
pm2 start ecosystem.config.js --env production --dry-run
```

---

## Configure Environment Variables

### Step 1: Setup Firebase Credentials

```bash
# Upload your Firebase service account key to the server
# Option 1: Use SCP from your local machine
# scp serviceAccountKey.json beautylms@your-server-ip:~/.credentials/

# Option 2: Use nano to paste the content
nano ~/.credentials/serviceAccountKey.json
# Paste the content of your service account key, then Ctrl+X, Y, Enter

# Secure the file
chmod 600 ~/.credentials/serviceAccountKey.json
```

### Step 2: Get Your Server's Public IP

```bash
# Get your public IP address
curl -4 ifconfig.me
# Note this IP address - you'll need it for MEDIASOUP_ANNOUNCED_IP
```

### Step 3: Create Production Environment File

```bash
cd ~/Beauty-lms/backend

# Copy the example file
cp .env.production.example .env.production

# Edit the production environment file
nano .env.production
```

### Step 4: Configure Critical Environment Variables

**Update these values in `.env.production`:**

```bash
# Server Configuration
NODE_ENV=production
PORT=3000

# Firebase - Update with your project ID
FIREBASE_PROJECT_ID=your-firebase-project-id
GOOGLE_APPLICATION_CREDENTIALS=/home/beautylms/.credentials/serviceAccountKey.json

# MediaSoup - CRITICAL FOR VIDEO CONFERENCING
MEDIASOUP_LISTEN_IP=0.0.0.0
MEDIASOUP_ANNOUNCED_IP=YOUR_SERVER_PUBLIC_IP  # Replace with IP from curl ifconfig.me
MEDIASOUP_MIN_PORT=40000
MEDIASOUP_MAX_PORT=49999

# CORS - Update with your domain
CORS_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

# Security - Generate a strong secret
JWT_SECRET=$(openssl rand -base64 64)

# Recording Configuration
RECORDING_ENABLED=true
RECORDINGS_PATH=/home/beautylms/Beauty-lms/recordings
RECORDING_BASE_URL=https://yourdomain.com
RECORDING_SECRET=$(openssl rand -base64 32)
```

**To generate secure secrets:**
```bash
# Generate JWT secret
openssl rand -base64 64

# Generate recording secret
openssl rand -base64 32
```

### Step 5: Verify Environment File

```bash
# Check that all required variables are set
grep -v '^#' .env.production | grep -v '^$'

# Test loading environment variables
node -e "require('dotenv').config({path: '.env.production'}); console.log('PORT:', process.env.PORT);"
```

---

## Start Application

### Step 1: Start Backend with PM2

```bash
cd ~/Beauty-lms/backend

# Start the application in production mode
pm2 start ecosystem.config.js --env production

# Save PM2 process list
pm2 save

# Verify application is running
pm2 status
```

Expected output:
```
┌────┬─────────────────────────┬─────────────┬─────────┬─────────┬──────────┬────────┬──────┬───────────┬──────────┬──────────┬──────────┐
│ id │ name                    │ namespace   │ version │ mode    │ pid      │ uptime │ ↺    │ status    │ cpu      │ mem      │ user     │
├────┼─────────────────────────┼─────────────┼─────────┼─────────┼──────────┼────────┼──────┼───────────┼──────────┼──────────┼──────────┤
│ 0  │ beauty-lms-backend      │ default     │ 1.0.0   │ cluster │ 12345    │ 5s     │ 0    │ online    │ 0%       │ 50.0mb   │ beauty…  │
│ 1  │ beauty-lms-backend      │ default     │ 1.0.0   │ cluster │ 12346    │ 5s     │ 0    │ online    │ 0%       │ 50.0mb   │ beauty…  │
└────┴─────────────────────────┴─────────────┴─────────┴─────────┴──────────┴────────┴──────┴───────────┴──────────┴──────────┴──────────┘
```

### Step 2: View Application Logs

```bash
# View real-time logs
pm2 logs beauty-lms-backend

# View last 100 lines
pm2 logs beauty-lms-backend --lines 100

# View only error logs
pm2 logs beauty-lms-backend --err
```

### Step 3: Test Application

```bash
# Test health endpoint
curl http://localhost:3000/health

# Should return:
# {"status":"OK","message":"Beauty LMS Video Conferencing Backend is running","timestamp":"..."}

# Test from external access
curl https://yourdomain.com/health
```

### Step 4: Access Application

Open your browser and navigate to:
```
https://yourdomain.com
```

You should see the Beauty LMS application running!

---

## Monitoring & Maintenance

### PM2 Monitoring

```bash
# View real-time monitoring dashboard
pm2 monit

# View detailed process information
pm2 info beauty-lms-backend

# View process metrics
pm2 describe beauty-lms-backend
```

### Setup PM2 Web Dashboard (Optional)

```bash
# Install PM2 Plus for advanced monitoring
pm2 install pm2-logrotate

# Configure log rotation
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
pm2 set pm2-logrotate:compress true
```

### System Monitoring Commands

```bash
# Check system resources
htop  # or 'top' if htop not installed

# Check disk usage
df -h

# Check memory usage
free -h

# Check open files and connections
lsof -i :3000
netstat -tuln | grep 3000

# Monitor MediaSoup ports
netstat -tuln | grep -E "4[0-9]{4}"
```

### Log Monitoring

```bash
# Application logs
tail -f ~/Beauty-lms/logs/backend-out.log
tail -f ~/Beauty-lms/logs/backend-error.log

# Nginx logs
sudo tail -f /var/log/nginx/beauty-lms-access.log
sudo tail -f /var/log/nginx/beauty-lms-error.log

# System logs
sudo journalctl -u beauty-lms-backend -f
```

### Performance Monitoring Script

Create a monitoring script:

```bash
nano ~/monitor-beauty-lms.sh
```

Add this content:

```bash
#!/bin/bash

echo "==================================="
echo "Beauty LMS Performance Monitor"
echo "==================================="
echo ""

echo "1. PM2 Status:"
pm2 status

echo ""
echo "2. Memory Usage:"
free -h

echo ""
echo "3. CPU Load:"
uptime

echo ""
echo "4. Disk Usage:"
df -h /home/beautylms/Beauty-lms

echo ""
echo "5. Active Connections:"
netstat -an | grep :3000 | wc -l

echo ""
echo "6. MediaSoup Ports in Use:"
netstat -tuln | grep -E "4[0-9]{4}" | wc -l

echo ""
echo "7. Recent Errors (last 10):"
tail -n 10 ~/Beauty-lms/logs/backend-error.log
```

Make it executable:
```bash
chmod +x ~/monitor-beauty-lms.sh

# Run it
./monitor-beauty-lms.sh
```

---

## Performance Optimization

### For 1000-1500 Concurrent Users

### 1. System Limits

Increase system limits for high concurrent connections:

```bash
sudo nano /etc/security/limits.conf
```

Add these lines:
```
beautylms soft nofile 65535
beautylms hard nofile 65535
beautylms soft nproc 4096
beautylms hard nproc 4096
```

### 2. Kernel Network Tuning

Optimize kernel network parameters:

```bash
sudo nano /etc/sysctl.conf
```

Add these optimizations:
```bash
# Increase max connections
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 8192

# Increase buffer sizes for better network performance
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864

# Enable TCP Fast Open
net.ipv4.tcp_fastopen = 3

# Optimize TIME_WAIT socket handling
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15

# Increase port range
net.ipv4.ip_local_port_range = 10000 65535

# Enable TCP window scaling
net.ipv4.tcp_window_scaling = 1

# Optimize keepalive settings
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15
```

Apply changes:
```bash
sudo sysctl -p
```

### 3. Node.js Performance Tuning

Update PM2 ecosystem configuration for maximum performance:

```bash
nano ~/Beauty-lms/backend/ecosystem.config.js
```

Ensure these settings are optimal:
```javascript
module.exports = {
  apps: [{
    name: 'beauty-lms-backend',
    script: './server.js',
    instances: 'max',  // Use all CPU cores
    exec_mode: 'cluster',
    node_args: [
      '--max-old-space-size=4096',  // Increase heap size to 4GB
      '--max-http-header-size=16384'
    ],
    max_memory_restart: '1G',
    // ... other settings
  }]
};
```

Restart after changes:
```bash
pm2 restart beauty-lms-backend
```

### 4. MediaSoup Worker Optimization

The application automatically creates one worker per CPU core. For optimal performance:

- **4 CPU cores**: Can handle ~400-500 concurrent video streams
- **8 CPU cores**: Can handle ~800-1000 concurrent video streams
- **16 CPU cores**: Can handle ~1500-2000 concurrent video streams

If you need more capacity, consider:
- Upgrading to a higher VPS plan with more CPU cores
- Implementing horizontal scaling (multiple servers)

### 5. Database Optimization (Firebase)

**Firestore Indexes:**
Ensure you have indexes created for frequently queried fields:

1. Go to Firebase Console > Firestore > Indexes
2. Create composite indexes for:
   - `live_courses` collection: `status`, `startTime`
   - `live_courses` collection: `instructorId`, `status`
   - `users` collection: `role`, `createdAt`

**Connection Pooling:**
The application uses Firebase Admin SDK which handles connection pooling automatically.

### 6. Recording Optimization

For systems with many recordings:

```bash
# Setup automatic cleanup job
crontab -e

# Add this line to run cleanup daily at 2 AM
0 2 * * * cd /home/beautylms/Beauty-lms/backend && node -e "require('./utils/recordingManager').cleanupOldRecordings(30)"
```

### 7. Caching Strategy

Install Redis for caching (optional but recommended):

```bash
# Install Redis
sudo apt install -y redis-server

# Start Redis
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Verify Redis is running
redis-cli ping  # Should return PONG
```

Then update `.env.production`:
```bash
REDIS_HOST=localhost
REDIS_PORT=6379
ENABLE_REDIS_ADAPTER=true
```

---

## Troubleshooting

### Common Issues and Solutions

#### 0. User Creation Issues

**Symptoms:** Error when creating the beautylms user during initial setup

**Solutions:**

```bash
# If you get an error with the adduser command, try these alternatives:

# Method 1: Using adduser with proper GECOS format (recommended)
sudo adduser beautylms --disabled-password --gecos ","

# Method 2: If adduser is not available, use useradd
sudo useradd -r -s /bin/bash -d /home/beautylms -m beautylms
# Then set up the home directory
sudo mkdir -p /home/beautylms
sudo chown beautylms:beautylms /home/beautylms

# Verify user was created successfully
id beautylms
# Should show: uid, gid, and groups

# If user already exists and you need to modify it
sudo usermod -aG sudo beautylms  # Add to sudo group
sudo chsh -s /bin/bash beautylms  # Set shell to bash
```

**Note:** The `--gecos ","` parameter skips the interactive prompts for user information (Full Name, Room Number, Work Phone, Home Phone, Other). The comma represents empty values for all GECOS fields.

#### 1. Application Won't Start

**Symptoms:**
```bash
pm2 status
# Shows status: errored
```

**Solutions:**

```bash
# Check logs for errors
pm2 logs beauty-lms-backend --lines 50

# Common issues:

# A. Port already in use
sudo lsof -i :3000
# Kill the process or change PORT in .env.production

# B. Firebase credentials error
# Verify serviceAccountKey.json exists and is valid
cat ~/.credentials/serviceAccountKey.json | jq .
# Should output valid JSON

# C. Missing environment variables
grep -E "FIREBASE_PROJECT_ID|MEDIASOUP_ANNOUNCED_IP" .env.production
# Ensure they're set

# D. Permission issues
ls -la ~/.credentials/
# Should show serviceAccountKey.json owned by beautylms
```

#### 2. Video Connection Fails

**Symptoms:** Users can't see each other's video

**Solutions:**

```bash
# A. Check MEDIASOUP_ANNOUNCED_IP
grep MEDIASOUP_ANNOUNCED_IP .env.production
# Must be your server's PUBLIC IP, not 127.0.0.1

# B. Verify firewall allows RTC ports
sudo ufw status | grep 40000:49999
# Should show ALLOW

# C. Check if ports are accessible externally
# From another machine:
nc -zv -u YOUR_SERVER_IP 40000

# D. Verify MediaSoup workers are running
pm2 logs beauty-lms-backend | grep "MediaSoup worker"
# Should show workers created successfully
```

#### 3. SSL Certificate Issues

**Symptoms:** HTTPS not working, certificate errors

**Solutions:**

```bash
# Check certificate status
sudo certbot certificates

# Renew certificate manually
sudo certbot renew --force-renewal

# Check Nginx SSL configuration
sudo nginx -t

# Verify DNS is pointing to your server
nslookup yourdomain.com
```

#### 4. High Memory Usage

**Symptoms:** Server running out of memory

**Solutions:**

```bash
# Check memory usage
free -h
pm2 status  # Look at memory column

# Restart PM2 processes
pm2 restart beauty-lms-backend

# Reduce PM2 instances if needed
pm2 scale beauty-lms-backend 4  # Scale down to 4 instances

# Add swap space if needed
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
# Make it permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

#### 5. Nginx 502 Bad Gateway

**Symptoms:** Nginx shows 502 error

**Solutions:**

```bash
# Check if backend is running
pm2 status

# Check Nginx error logs
sudo tail -f /var/log/nginx/beauty-lms-error.log

# Test backend directly
curl http://localhost:3000/health

# Check Nginx configuration
sudo nginx -t

# Restart both services
pm2 restart beauty-lms-backend
sudo systemctl restart nginx
```

#### 6. Socket.IO Connection Issues

**Symptoms:** Real-time features not working

**Solutions:**

```bash
# Check WebSocket upgrade headers in Nginx logs
sudo tail -f /var/log/nginx/beauty-lms-access.log | grep socket.io

# Verify Socket.IO endpoint is accessible
curl https://yourdomain.com/socket.io/?transport=polling

# Check CORS settings
grep ALLOWED_ORIGINS .env.production
# Should include your frontend domain
```

### Performance Troubleshooting

#### System is Slow with High User Load

```bash
# 1. Check CPU usage
htop
# Look for processes using high CPU

# 2. Check if disk I/O is bottleneck
iostat -x 1 10

# 3. Check network connections
netstat -an | grep ESTABLISHED | wc -l

# 4. Monitor in real-time
pm2 monit

# 5. Check if swap is being used (bad sign)
free -h
# If swap is being used heavily, you need more RAM
```

#### Recommendations for scaling beyond 1500 users:

1. **Vertical Scaling:** Upgrade VPS to more CPU cores and RAM
2. **Horizontal Scaling:** Deploy multiple instances behind a load balancer
3. **Database Scaling:** Optimize Firebase queries and indexes
4. **CDN:** Use CDN for static assets and recordings
5. **Monitoring:** Setup proper monitoring with tools like Grafana + Prometheus

---

## Maintenance Checklist

### Daily Tasks
- [ ] Check application status: `pm2 status`
- [ ] Monitor disk space: `df -h`
- [ ] Check error logs: `tail -f ~/Beauty-lms/logs/backend-error.log`

### Weekly Tasks
- [ ] Review system performance: `./monitor-beauty-lms.sh`
- [ ] Check SSL certificate expiry: `sudo certbot certificates`
- [ ] Clean old recordings: Run cleanup script
- [ ] Review Nginx access logs for anomalies
- [ ] Update system packages: `sudo apt update && sudo apt upgrade`

### Monthly Tasks
- [ ] Backup Firebase data
- [ ] Review and optimize Firestore indexes
- [ ] Check for application updates
- [ ] Review and rotate logs
- [ ] Performance audit and optimization

---

## Security Checklist

- [ ] Firewall (UFW) is enabled and properly configured
- [ ] SSH is secured (disable password auth, use keys only)
- [ ] SSL certificate is valid and auto-renews
- [ ] Application runs as non-root user (beautylms)
- [ ] Firebase credentials are secured (600 permissions)
- [ ] Environment variables contain strong secrets
- [ ] Regular security updates applied
- [ ] Rate limiting configured in Nginx
- [ ] CORS properly configured
- [ ] Unnecessary ports are closed

---

## Backup Strategy

### Automated Backup Script

Create a backup script:

```bash
nano ~/backup-beauty-lms.sh
```

Add:

```bash
#!/bin/bash

BACKUP_DIR="/home/beautylms/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup environment files
cp ~/Beauty-lms/backend/.env.production $BACKUP_DIR/env_$DATE.bak

# Backup recordings (last 7 days)
find ~/Beauty-lms/recordings/completed -type f -mtime -7 -exec cp {} $BACKUP_DIR/ \;

# Backup PM2 config
pm2 save

# Backup Nginx config
sudo cp /etc/nginx/sites-available/beauty-lms $BACKUP_DIR/nginx_$DATE.conf

# Remove backups older than 30 days
find $BACKUP_DIR -type f -mtime +30 -delete

echo "Backup completed: $DATE"
```

Make executable and schedule:
```bash
chmod +x ~/backup-beauty-lms.sh

# Schedule daily backups at 3 AM
crontab -e
# Add: 0 3 * * * /home/beautylms/backup-beauty-lms.sh >> /home/beautylms/backup.log 2>&1
```

---

## Support and Resources

### Official Documentation
- Beauty LMS GitHub: https://github.com/krishna123-conf/Beautylms
- MediaSoup Documentation: https://mediasoup.org/documentation/
- Firebase Documentation: https://firebase.google.com/docs
- PM2 Documentation: https://pm2.keymetrics.io/docs/
- Nginx Documentation: https://nginx.org/en/docs/

### Getting Help
- Check application logs: `pm2 logs beauty-lms-backend`
- Review this guide's troubleshooting section
- Open an issue on GitHub
- Check Hostinger support for VPS-specific issues

### Testing Your Deployment

Run the verification script:
```bash
cd ~/Beauty-lms/scripts
chmod +x verify_deployment.sh
./verify_deployment.sh yourdomain.com
```

---

## Conclusion

You now have a production-ready Beauty LMS deployment on Hostinger VPS optimized for 1000-1500 concurrent users! 

### Key Points to Remember:

1. **Monitor Regularly**: Use PM2 and system monitoring tools
2. **Keep Updated**: Regularly update system packages and application code
3. **Backup Often**: Automated backups save you from disasters
4. **Scale Appropriately**: Start with recommended specs, scale up as needed
5. **Security First**: Keep SSL updated, firewall enabled, credentials secure

### Next Steps:

1. Test with a small group of users first
2. Gradually increase load while monitoring performance
3. Optimize based on actual usage patterns
4. Setup proper monitoring and alerting
5. Plan for scaling if user base grows beyond 1500

**Good luck with your Beauty LMS deployment!** 🚀

---

*Last Updated: 2024*
*Version: 1.0.0*

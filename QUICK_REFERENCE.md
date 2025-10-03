# Beauty LMS Quick Reference Guide

Quick command reference for managing Beauty LMS in production.

## 📚 Complete Documentation

- **[Hostinger VPS Deployment](HOSTINGER_VPS_DEPLOYMENT.md)** - Full deployment guide
- **[Production Checklist](PRODUCTION_READINESS_CHECKLIST.md)** - Pre-launch checklist
- **[Monitoring Guide](MONITORING_GUIDE.md)** - Monitoring and troubleshooting
- **[Security Guide](SECURITY_GUIDE.md)** - Security hardening

---

## 🚀 Quick Start Commands

### Deploy Application
```bash
cd ~/Beautylms/scripts
./production_deploy.sh
```

### Optimize System
```bash
sudo ./scripts/optimize_for_production.sh
```

---

## 🔧 PM2 Commands

### Application Management
```bash
# Start application
pm2 start ecosystem.config.js --env production

# Stop application
pm2 stop beauty-lms-backend

# Restart application
pm2 restart beauty-lms-backend

# Reload (zero-downtime)
pm2 reload beauty-lms-backend

# Delete from PM2
pm2 delete beauty-lms-backend

# View status
pm2 status

# Save process list
pm2 save

# Resurrect saved processes
pm2 resurrect
```

### Monitoring
```bash
# Real-time monitoring dashboard
pm2 monit

# View logs
pm2 logs beauty-lms-backend

# View only errors
pm2 logs beauty-lms-backend --err

# View last 100 lines
pm2 logs beauty-lms-backend --lines 100

# Clear logs
pm2 flush

# Process details
pm2 describe beauty-lms-backend
```

### Scaling
```bash
# Scale to 4 instances
pm2 scale beauty-lms-backend 4

# Scale to max (all CPU cores)
pm2 scale beauty-lms-backend max
```

---

## 🌐 Nginx Commands

### Service Management
```bash
# Test configuration
sudo nginx -t

# Reload configuration
sudo systemctl reload nginx

# Restart Nginx
sudo systemctl restart nginx

# Stop Nginx
sudo systemctl stop nginx

# Start Nginx
sudo systemctl start nginx

# Check status
sudo systemctl status nginx
```

### Logs
```bash
# Access logs
sudo tail -f /var/log/nginx/beauty-lms-access.log

# Error logs
sudo tail -f /var/log/nginx/beauty-lms-error.log

# All Nginx logs
sudo tail -f /var/log/nginx/*.log
```

---

## 🔒 SSL Certificate Commands

### Certbot
```bash
# List certificates
sudo certbot certificates

# Renew all certificates
sudo certbot renew

# Force renewal
sudo certbot renew --force-renewal

# Test renewal
sudo certbot renew --dry-run

# Revoke certificate
sudo certbot revoke --cert-name yourdomain.com
```

---

## 📊 System Monitoring

### System Resources
```bash
# CPU and memory
htop

# Disk usage
df -h

# Memory usage
free -h

# System load
uptime

# Process list
ps aux --sort=-%mem | head -20
```

### Network
```bash
# Active connections
netstat -an | grep :3000 | wc -l

# All listening ports
sudo netstat -tuln

# Connections by state
netstat -ant | awk '{print $6}' | sort | uniq -c

# MediaSoup ports in use
netstat -tuln | grep -E "4[0-9]{4}" | wc -l

# Network traffic
sudo iftop
```

### Application Performance
```bash
# Custom performance monitor
~/monitor-performance.sh

# Test API response time
curl -w "\nTime: %{time_total}s\n" -o /dev/null -s https://yourdomain.com/health

# Check application health
curl https://yourdomain.com/health
```

---

## 🔥 Firewall Commands

### UFW Management
```bash
# Check status
sudo ufw status verbose

# Enable firewall
sudo ufw enable

# Disable firewall
sudo ufw disable

# Allow port
sudo ufw allow 443/tcp

# Deny IP
sudo ufw deny from 1.2.3.4

# Delete rule
sudo ufw delete allow 80/tcp

# Reset firewall
sudo ufw --force reset
```

### Fail2Ban
```bash
# Check status
sudo fail2ban-client status

# Status of specific jail
sudo fail2ban-client status sshd

# Unban IP
sudo fail2ban-client set sshd unbanip 1.2.3.4

# Check banned IPs
sudo fail2ban-client status sshd
```

---

## 📝 Log Commands

### View Logs
```bash
# Application logs
tail -f ~/Beautylms/logs/backend-out.log
tail -f ~/Beautylms/logs/backend-error.log

# System logs
sudo journalctl -u beauty-lms-backend -f

# Nginx logs
sudo tail -f /var/log/nginx/beauty-lms-access.log
sudo tail -f /var/log/nginx/beauty-lms-error.log

# System authentication logs
sudo tail -f /var/log/auth.log
```

### Search Logs
```bash
# Search for errors
grep -i "error" ~/Beautylms/logs/backend-error.log | tail -20

# Search for specific IP
grep "1.2.3.4" /var/log/nginx/beauty-lms-access.log

# Search for failed logins
sudo grep "Failed password" /var/log/auth.log | tail -20

# Count errors
grep -c "error" ~/Beautylms/logs/backend-error.log
```

---

## 🔄 Backup & Recovery

### Backup Commands
```bash
# Backup configuration
tar -czf ~/backups/config-$(date +%Y%m%d).tar.gz \
  ~/Beautylms/backend/.env.production \
  ~/Beautylms/backend/ecosystem.config.js \
  /etc/nginx/sites-available/beauty-lms

# Backup recordings (last 7 days)
find ~/Beautylms/recordings/completed -type f -mtime -7 \
  -exec cp {} ~/backups/recordings/ \;

# Backup entire application
tar -czf ~/backups/beauty-lms-$(date +%Y%m%d).tar.gz \
  ~/Beautylms
```

### Restore Commands
```bash
# Restore configuration
tar -xzf ~/backups/config-YYYYMMDD.tar.gz -C /

# Restore application
tar -xzf ~/backups/beauty-lms-YYYYMMDD.tar.gz -C ~/

# Restart after restore
pm2 restart beauty-lms-backend
sudo systemctl reload nginx
```

---

## 🛠️ Troubleshooting Commands

### Application Issues
```bash
# Check if app is running
pm2 status

# View recent errors
pm2 logs beauty-lms-backend --err --lines 50

# Check port usage
sudo lsof -i :3000

# Kill process on port
sudo kill -9 $(sudo lsof -t -i:3000)

# Test configuration
cd ~/Beautylms/backend
node -e "require('dotenv').config({path: '.env.production'}); console.log('OK');"
```

### Connection Issues
```bash
# Test health endpoint
curl http://localhost:3000/health

# Test external access
curl https://yourdomain.com/health

# Check DNS
nslookup yourdomain.com

# Check SSL
echo | openssl s_client -servername yourdomain.com -connect yourdomain.com:443

# Test WebSocket
curl -i -N -H "Connection: Upgrade" -H "Upgrade: websocket" \
  https://yourdomain.com/socket.io/
```

### MediaSoup Issues
```bash
# Check announced IP
grep MEDIASOUP_ANNOUNCED_IP ~/Beautylms/backend/.env.production

# Check current IP
curl -4 ifconfig.me

# Test RTC port
nc -zv -u YOUR_SERVER_IP 40000

# Check worker logs
pm2 logs beauty-lms-backend | grep -i "mediasoup"
```

---

## 🔐 Security Commands

### System Security
```bash
# Check failed login attempts
sudo grep "Failed password" /var/log/auth.log | tail -20

# Check current users
who

# Check login history
last

# Check open ports
sudo netstat -tuln | grep LISTEN

# Check for rootkits (install rkhunter first)
sudo rkhunter --check
```

### File Permissions
```bash
# Check file permissions
ls -la ~/Beautylms/backend/.env.production
ls -la ~/.credentials/serviceAccountKey.json

# Fix permissions
chmod 600 ~/Beautylms/backend/.env.production
chmod 600 ~/.credentials/serviceAccountKey.json
```

---

## 📈 Performance Optimization

### System Optimization
```bash
# Check system limits
ulimit -n  # Should show 65535
ulimit -u  # Should show 4096

# Check kernel parameters
sysctl net.core.somaxconn  # Should show 65535
sysctl net.ipv4.tcp_max_syn_backlog  # Should show 8192

# Reload sysctl
sudo sysctl -p
```

### Clear Caches
```bash
# Clear system cache
sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches

# Clear PM2 logs
pm2 flush

# Rotate Nginx logs
sudo logrotate -f /etc/logrotate.d/nginx
```

---

## 🔄 Update Commands

### System Updates
```bash
# Update package list
sudo apt update

# Upgrade packages
sudo apt upgrade -y

# Dist upgrade
sudo apt dist-upgrade -y

# Remove unused packages
sudo apt autoremove -y

# Clean package cache
sudo apt clean
```

### Application Updates
```bash
# Pull latest code
cd ~/Beautylms
git pull origin main

# Install dependencies
cd backend
npm install --production

# Restart application
pm2 restart beauty-lms-backend
```

---

## 📊 Performance Benchmarks

### Quick Performance Tests
```bash
# API response time
curl -w "@-" -o /dev/null -s https://yourdomain.com/health <<< "Time: %{time_total}s"

# Connection test
ab -n 100 -c 10 https://yourdomain.com/health

# Load test (requires artillery)
artillery quick --count 100 --num 10 https://yourdomain.com/health
```

---

## 🚨 Emergency Commands

### Application Won't Start
```bash
# 1. Check logs
pm2 logs beauty-lms-backend --lines 100

# 2. Kill any process using port
sudo kill -9 $(sudo lsof -t -i:3000)

# 3. Start fresh
pm2 delete beauty-lms-backend
pm2 start ecosystem.config.js --env production
```

### High CPU/Memory
```bash
# 1. Check processes
htop

# 2. Scale down
pm2 scale beauty-lms-backend 4

# 3. Restart
pm2 restart beauty-lms-backend

# 4. Clear cache
pm2 flush
sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
```

### Server Unresponsive
```bash
# 1. Reboot (last resort)
sudo reboot

# 2. After reboot, check services
sudo systemctl status nginx
pm2 status

# 3. Verify application
curl http://localhost:3000/health
```

---

## 📞 Quick Contact Info

### Important Paths
- **Application**: `/home/beauty/Beautylms`
- **Logs**: `/home/beauty/Beautylms/logs`
- **Nginx Config**: `/etc/nginx/sites-available/beauty-lms`
- **Environment**: `/home/beauty/Beautylms/backend/.env.production`
- **Firebase Key**: `/home/beauty/.credentials/serviceAccountKey.json`

### Important URLs
- **Health Check**: `https://yourdomain.com/health`
- **API Docs**: `https://yourdomain.com/api`
- **Recordings**: `https://yourdomain.com/recordings/completed/`

---

## 🎯 Daily Checklist

```bash
# Morning routine (run all commands)
pm2 status                                    # Check app status
df -h                                         # Check disk space
free -h                                       # Check memory
~/monitor-performance.sh                      # Performance report
sudo fail2ban-client status                   # Security status
```

---

**Keep this guide handy for quick reference!**

*Last Updated: 2024*

# Beauty LMS Production Readiness Checklist

Complete checklist to ensure your Beauty LMS deployment is ready for **1000-1500 concurrent users**.

## 📋 Pre-Deployment Checklist

### Server Requirements
- [ ] VPS with minimum 8 vCPU cores (recommended)
- [ ] Minimum 16 GB RAM
- [ ] 100 GB SSD storage
- [ ] Ubuntu 20.04 or 22.04 LTS installed
- [ ] Root or sudo access available
- [ ] Domain name configured and DNS propagated

### Software Prerequisites
- [ ] Node.js v18 LTS installed
- [ ] npm v9+ installed
- [ ] PM2 process manager installed
- [ ] Nginx web server installed
- [ ] FFmpeg installed (for recording)
- [ ] Certbot installed (for SSL)
- [ ] Git installed

### Firebase Setup
- [ ] Firebase project created
- [ ] Firestore Database enabled
- [ ] Firebase Authentication enabled
- [ ] Service account key downloaded
- [ ] Required Firestore indexes created

### Network Configuration
- [ ] Domain A record points to VPS IP
- [ ] DNS propagation completed
- [ ] Firewall configured (UFW)
- [ ] Ports opened: 22, 80, 443, 40000-49999
- [ ] SSL certificate obtained

## 🔧 Configuration Checklist

### Environment Variables (`.env.production`)
- [ ] `NODE_ENV=production`
- [ ] `PORT=3000`
- [ ] `FIREBASE_PROJECT_ID` set correctly
- [ ] `GOOGLE_APPLICATION_CREDENTIALS` path correct
- [ ] `MEDIASOUP_ANNOUNCED_IP` set to server public IP
- [ ] `MEDIASOUP_MIN_PORT=40000`
- [ ] `MEDIASOUP_MAX_PORT=49999`
- [ ] `CORS_ORIGINS` set to your domain(s)
- [ ] `JWT_SECRET` generated and set
- [ ] `RECORDING_SECRET` generated and set

### File Permissions
- [ ] Application owned by `beauty` user
- [ ] Firebase credentials file has 600 permissions
- [ ] Logs directory exists and is writable
- [ ] Recordings directory exists and is writable
- [ ] Scripts are executable (chmod +x)

### Nginx Configuration
- [ ] Nginx configuration copied to `/etc/nginx/sites-available/`
- [ ] Domain name updated in config
- [ ] SSL certificate paths correct
- [ ] Site enabled in `/etc/nginx/sites-enabled/`
- [ ] Configuration tested (`nginx -t`)
- [ ] Nginx restarted

### PM2 Configuration
- [ ] `ecosystem.config.js` configured
- [ ] PM2 startup script configured
- [ ] Application started with PM2
- [ ] PM2 process list saved

## 🚀 System Optimization Checklist

### Kernel Optimization
- [ ] System limits increased (`/etc/security/limits.conf`)
- [ ] Network parameters tuned (`/etc/sysctl.conf`)
- [ ] File descriptor limit: 65535
- [ ] Max processes: 4096
- [ ] TCP/IP stack optimized
- [ ] BBR congestion control enabled (if supported)

### Nginx Optimization
- [ ] Worker processes set to `auto`
- [ ] Worker connections: 4096
- [ ] Keepalive configured
- [ ] Buffer sizes optimized
- [ ] Gzip compression enabled
- [ ] Rate limiting configured

### Application Optimization
- [ ] PM2 cluster mode enabled
- [ ] Node.js heap size configured
- [ ] MediaSoup workers created per CPU core
- [ ] Socket.IO optimized for high connections
- [ ] Graceful shutdown handlers implemented

### Swap Configuration (if RAM < 16GB)
- [ ] Swap file created (4GB minimum)
- [ ] Swap enabled and persistent
- [ ] Swappiness configured (vm.swappiness=10)

## 🧪 Testing Checklist

### Basic Functionality
- [ ] Health endpoint responds: `curl https://yourdomain.com/health`
- [ ] API endpoints accessible
- [ ] WebSocket connections working
- [ ] Frontend loads correctly (if applicable)
- [ ] SSL certificate valid

### Video Conferencing
- [ ] Single user can join meeting
- [ ] Two users can see/hear each other
- [ ] Audio controls work (mute/unmute)
- [ ] Video controls work (camera on/off)
- [ ] Multiple participants can join
- [ ] Screen sharing works (if implemented)

### Recording Functionality
- [ ] Recording starts when course starts
- [ ] Recording stops when course ends
- [ ] Recording files saved to correct directory
- [ ] Recordings playback correctly
- [ ] Recording cleanup works

### Performance Testing
- [ ] Server handles 10 concurrent connections
- [ ] Server handles 50 concurrent connections
- [ ] Server handles 100 concurrent connections
- [ ] CPU usage acceptable under load
- [ ] Memory usage acceptable under load
- [ ] No memory leaks detected
- [ ] Network bandwidth sufficient

### Monitoring
- [ ] PM2 monitoring dashboard accessible
- [ ] Application logs being written
- [ ] Nginx logs being written
- [ ] Error logs reviewed
- [ ] Performance monitoring script works

## 📊 Capacity Testing

### Load Testing Targets for 1000-1500 Users

#### CPU Capacity
- **Target**: 8+ CPU cores
- **Test**: Check worker count matches CPU cores
- **Command**: `pm2 status` should show multiple instances
- **Pass Criteria**: Workers = CPU cores

#### Memory Capacity
- **Target**: < 80% memory usage under full load
- **Test**: Monitor with `free -h` during load
- **Pass Criteria**: Available memory > 3GB at 1500 users

#### Network Capacity
- **Target**: Handle 1500 concurrent WebSocket connections
- **Test**: `netstat -an | grep :3000 | wc -l`
- **Pass Criteria**: Port can handle target connections

#### MediaSoup Ports
- **Target**: 3000+ ports available (1500 users × 2)
- **Test**: `netstat -tuln | grep -E "4[0-9]{4}" | wc -l`
- **Pass Criteria**: Sufficient ports in range 40000-49999

### Performance Benchmarks

For 1500 concurrent users:

| Metric | Target | Command |
|--------|--------|---------|
| CPU Usage | < 80% | `htop` |
| Memory Usage | < 12GB | `free -h` |
| Active Connections | ~1500 | `netstat -an \| grep :3000 \| wc -l` |
| Response Time (API) | < 200ms | `curl -w "@%{time_total}\n" https://yourdomain.com/health` |
| WebSocket Latency | < 100ms | Test in application |

## 🔒 Security Checklist

### Server Security
- [ ] SSH password authentication disabled
- [ ] SSH key-based authentication only
- [ ] Fail2ban installed and configured
- [ ] Automatic security updates enabled
- [ ] Root login disabled
- [ ] Unnecessary services disabled

### Application Security
- [ ] Strong JWT secret generated
- [ ] Firebase credentials secured
- [ ] HTTPS enforced (HTTP redirects to HTTPS)
- [ ] CORS properly configured
- [ ] Rate limiting enabled
- [ ] Security headers configured
- [ ] No secrets in code repository

### Network Security
- [ ] Firewall (UFW) enabled
- [ ] Only required ports open
- [ ] DDoS protection configured (Cloudflare/similar)
- [ ] Regular security audits scheduled

## 📝 Monitoring & Maintenance Checklist

### Daily Monitoring
- [ ] Check application status: `pm2 status`
- [ ] Review error logs
- [ ] Check disk space: `df -h`
- [ ] Monitor CPU/Memory: `htop`
- [ ] Verify SSL certificate validity

### Weekly Tasks
- [ ] Review access logs for anomalies
- [ ] Check for failed login attempts
- [ ] Review performance metrics
- [ ] Clean old recordings
- [ ] Update system packages: `sudo apt update && sudo apt upgrade`

### Monthly Tasks
- [ ] Full backup of configuration files
- [ ] Review and optimize database indexes
- [ ] Performance audit
- [ ] Security audit
- [ ] Log rotation and archival
- [ ] Capacity planning review

### Automated Monitoring (Recommended)
- [ ] Setup uptime monitoring (UptimeRobot, Pingdom)
- [ ] Configure server monitoring (Netdata, New Relic)
- [ ] Setup alert notifications (email, Slack, SMS)
- [ ] Configure log aggregation (ELK stack, Loggly)
- [ ] Setup performance monitoring (Grafana + Prometheus)

## 🔄 Backup & Recovery Checklist

### What to Backup
- [ ] `.env.production` file
- [ ] Firebase service account key
- [ ] PM2 ecosystem configuration
- [ ] Nginx configuration
- [ ] SSL certificates
- [ ] Application recordings (optional, if needed)
- [ ] Application logs (last 30 days)

### Backup Schedule
- [ ] Daily: Configuration files
- [ ] Weekly: Full system backup
- [ ] Monthly: Long-term archive

### Recovery Plan
- [ ] Documented recovery procedures
- [ ] Tested restore process
- [ ] Recovery time objective (RTO) defined
- [ ] Recovery point objective (RPO) defined

## 📱 Client Testing Checklist

### Browser Compatibility
- [ ] Chrome (latest version)
- [ ] Firefox (latest version)
- [ ] Safari (latest version)
- [ ] Edge (latest version)
- [ ] Mobile Safari (iOS)
- [ ] Mobile Chrome (Android)

### Device Testing
- [ ] Desktop Windows
- [ ] Desktop macOS
- [ ] Desktop Linux
- [ ] Mobile iOS (iPhone)
- [ ] Mobile Android
- [ ] Tablet (iPad/Android)

### Network Conditions
- [ ] Good connection (50+ Mbps)
- [ ] Moderate connection (10 Mbps)
- [ ] Poor connection (2 Mbps)
- [ ] Unstable connection (packet loss)

## 🎯 Production Launch Checklist

### Pre-Launch (1 week before)
- [ ] All checklist items above completed
- [ ] Load testing completed successfully
- [ ] Team trained on system administration
- [ ] Support documentation prepared
- [ ] Monitoring and alerting configured
- [ ] Backup and recovery tested
- [ ] Emergency contact list prepared

### Launch Day
- [ ] Final system check
- [ ] Monitor application logs continuously
- [ ] Monitor system resources continuously
- [ ] Team on standby for issues
- [ ] Communication channels open
- [ ] Escalation procedures ready

### Post-Launch (first week)
- [ ] Daily performance reviews
- [ ] Monitor user feedback
- [ ] Track error rates
- [ ] Optimize based on actual usage
- [ ] Document any issues and resolutions
- [ ] Schedule debrief meeting

## 🚨 Troubleshooting Quick Reference

### Application Won't Start
1. Check PM2 logs: `pm2 logs beauty-lms-backend`
2. Verify environment variables: `cat backend/.env.production`
3. Check Firebase credentials exist
4. Verify port is not in use: `lsof -i :3000`

### High CPU Usage
1. Check number of PM2 instances: `pm2 status`
2. Scale down if needed: `pm2 scale beauty-lms-backend 4`
3. Check for memory leaks: `pm2 monit`
4. Review MediaSoup worker count

### High Memory Usage
1. Check current usage: `free -h`
2. Restart PM2: `pm2 restart beauty-lms-backend`
3. Check for memory leaks in logs
4. Consider upgrading VPS plan

### Video Not Working
1. Verify `MEDIASOUP_ANNOUNCED_IP` is public IP
2. Check firewall allows ports 40000-49999
3. Test port connectivity externally
4. Check MediaSoup worker logs

### SSL Certificate Issues
1. Check certificate status: `sudo certbot certificates`
2. Renew if needed: `sudo certbot renew`
3. Restart Nginx: `sudo systemctl restart nginx`
4. Verify DNS points to correct IP

## ✅ Final Verification

Run the comprehensive verification script:

```bash
cd ~/Beautylms/scripts
./verify_deployment.sh yourdomain.com
```

Expected result: All tests should pass ✅

---

## 🎓 Estimated Capacity

Based on your configuration:

| Configuration | Estimated Capacity |
|--------------|-------------------|
| 4 CPU cores, 8GB RAM | ~400-600 users |
| 8 CPU cores, 16GB RAM | **1000-1500 users** ✅ |
| 16 CPU cores, 32GB RAM | ~2000-3000 users |

**Your Target**: 1000-1500 concurrent users
**Recommended**: 8 CPU cores, 16GB RAM, 100GB SSD

---

## 📞 Support Resources

- **Documentation**: `/home/beauty/Beautylms/HOSTINGER_VPS_DEPLOYMENT.md`
- **Monitor Script**: `/home/beauty/monitor-performance.sh`
- **Logs Location**: `/home/beauty/Beautylms/logs/`
- **PM2 Logs**: `pm2 logs beauty-lms-backend`
- **Nginx Logs**: `/var/log/nginx/beauty-lms-*.log`

---

**Production Status**: ✅ Ready when all items checked

*Last Updated: 2024*
*Target: 1000-1500 Concurrent Users*

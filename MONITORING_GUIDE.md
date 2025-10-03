# Beauty LMS Monitoring & Troubleshooting Guide

Complete guide for monitoring and maintaining Beauty LMS in production for 1000-1500 concurrent users.

## 📊 Monitoring Overview

### Key Metrics to Monitor

| Metric | Healthy Range | Warning Range | Critical Range |
|--------|---------------|---------------|----------------|
| CPU Usage | < 60% | 60-80% | > 80% |
| Memory Usage | < 70% | 70-85% | > 85% |
| Disk Usage | < 70% | 70-90% | > 90% |
| Active Connections | < 1200 | 1200-1500 | > 1500 |
| Response Time | < 200ms | 200-500ms | > 500ms |
| Error Rate | < 0.1% | 0.1-1% | > 1% |

---

## 🔍 Real-Time Monitoring

### 1. PM2 Monitoring Dashboard

Access the built-in PM2 monitoring dashboard:

```bash
pm2 monit
```

This shows:
- **CPU usage** per process
- **Memory usage** per process
- **Logs** in real-time
- **Custom metrics**

### 2. System Resource Monitor

Use `htop` for comprehensive system monitoring:

```bash
htop
```

Key indicators:
- **Load Average**: Should be < number of CPU cores
- **Memory**: Check for swap usage (should be minimal)
- **CPU bars**: Watch for sustained high usage
- **Process list**: Identify resource-heavy processes

### 3. Network Connection Monitor

Monitor active connections:

```bash
# Real-time connection monitoring
watch -n 2 'netstat -an | grep :3000 | grep ESTABLISHED | wc -l'

# WebSocket connections
watch -n 2 'ss -s'

# MediaSoup ports in use
watch -n 5 'netstat -tuln | grep -E "4[0-9]{4}" | wc -l'
```

### 4. Custom Performance Monitor

Use the included monitoring script:

```bash
# Run once
/home/beautylms/monitor-performance.sh

# Run every 30 seconds
watch -n 30 /home/beautylms/monitor-performance.sh

# Log to file
watch -n 60 '/home/beautylms/monitor-performance.sh >> /home/beautylms/performance.log'
```

---

## 📝 Log Management

### Application Logs

**PM2 Logs:**
```bash
# View all logs
pm2 logs beauty-lms-backend

# View only error logs
pm2 logs beauty-lms-backend --err

# View only output logs
pm2 logs beauty-lms-backend --out

# View last 100 lines
pm2 logs beauty-lms-backend --lines 100

# Clear logs
pm2 flush
```

**Log Files:**
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

### Log Analysis

**Find errors:**
```bash
# Recent errors in application
grep -i "error" ~/Beauty-lms/logs/backend-error.log | tail -20

# Nginx 5xx errors
grep " 5[0-9][0-9] " /var/log/nginx/beauty-lms-error.log | tail -20

# Failed connections
grep -i "connection refused\|timeout" ~/Beauty-lms/logs/backend-error.log
```

**Analyze traffic patterns:**
```bash
# Top 10 IPs accessing your server
awk '{print $1}' /var/log/nginx/beauty-lms-access.log | sort | uniq -c | sort -rn | head -10

# Request rate per minute
awk '{print $4}' /var/log/nginx/beauty-lms-access.log | cut -d: -f1-2 | sort | uniq -c | tail -20

# Most requested endpoints
awk '{print $7}' /var/log/nginx/beauty-lms-access.log | sort | uniq -c | sort -rn | head -10
```

---

## 🚨 Alert Configuration

### Setup Email Alerts

Install `mailutils`:
```bash
sudo apt install -y mailutils
```

Create alert script (`~/alert-check.sh`):
```bash
#!/bin/bash

EMAIL="admin@yourdomain.com"
SERVER="Beauty LMS Production"

# Check CPU usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
    echo "High CPU usage: $CPU_USAGE%" | mail -s "$SERVER: CPU Alert" $EMAIL
fi

# Check memory usage
MEM_USAGE=$(free | grep Mem | awk '{print ($3/$2) * 100.0}')
if (( $(echo "$MEM_USAGE > 85" | bc -l) )); then
    echo "High memory usage: $MEM_USAGE%" | mail -s "$SERVER: Memory Alert" $EMAIL
fi

# Check disk usage
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | cut -d'%' -f1)
if [ $DISK_USAGE -gt 90 ]; then
    echo "High disk usage: $DISK_USAGE%" | mail -s "$SERVER: Disk Alert" $EMAIL
fi

# Check if application is running
if ! pm2 list | grep -q "online"; then
    echo "Application is not running!" | mail -s "$SERVER: CRITICAL - App Down" $EMAIL
fi
```

Make executable and schedule:
```bash
chmod +x ~/alert-check.sh

# Run every 5 minutes
crontab -e
# Add: */5 * * * * /home/beautylms/alert-check.sh
```

### Setup Uptime Monitoring

Use external services for uptime monitoring:

1. **UptimeRobot** (https://uptimerobot.com) - Free tier available
   - Monitor: `https://yourdomain.com/health`
   - Check interval: 5 minutes
   - Alert: Email/SMS/Slack

2. **Pingdom** (https://www.pingdom.com)
   - Monitor: Website and API endpoints
   - Performance tracking
   - Downtime alerts

3. **Healthchecks.io** (https://healthchecks.io)
   - Cron job monitoring
   - Dead man's switch
   - Integration with cron jobs

---

## 📈 Performance Metrics

### Application Performance

**Response Time Monitoring:**
```bash
# Test API response time
curl -w "\nTime Total: %{time_total}s\n" -o /dev/null -s https://yourdomain.com/health

# Continuous monitoring
while true; do 
    curl -w "Time: %{time_total}s\n" -o /dev/null -s https://yourdomain.com/api/live_courses
    sleep 5
done
```

**WebSocket Performance:**
```bash
# Monitor WebSocket connections
watch -n 2 'netstat -an | grep :3000 | grep -c ESTABLISHED'

# Check for connection errors
grep -i "websocket\|socket.io" ~/Beauty-lms/logs/backend-error.log | tail -20
```

**Database Performance (Firebase):**
- Monitor in Firebase Console > Performance
- Check query execution times
- Review index usage

### Video Conferencing Performance

**MediaSoup Metrics:**
```bash
# Check worker status
pm2 logs beauty-lms-backend | grep "MediaSoup worker"

# Monitor RTC port usage
netstat -tuln | grep -E "4[0-9]{4}" | wc -l

# Check for MediaSoup errors
grep -i "mediasoup" ~/Beauty-lms/logs/backend-error.log | tail -20
```

**Video Quality Indicators:**
- Check client-side reports for:
  - Packet loss
  - Jitter
  - Round-trip time (RTT)
  - Bitrate adaptation

---

## 🔧 Common Issues & Solutions

### Issue 1: High CPU Usage

**Symptoms:**
- CPU usage consistently > 80%
- Application slow
- Video lag

**Diagnosis:**
```bash
# Check which process is using CPU
top -bn1 | head -20

# Check PM2 instances
pm2 status

# Check MediaSoup workers
pm2 logs beauty-lms-backend | grep -i "worker"
```

**Solutions:**
1. **Scale down PM2 instances if over-provisioned:**
   ```bash
   pm2 scale beauty-lms-backend 4
   ```

2. **Upgrade VPS to more CPU cores**

3. **Optimize MediaSoup workers:**
   - Check if too many workers are running
   - Verify port range is sufficient

4. **Check for runaway processes:**
   ```bash
   ps aux | sort -nk +3 | tail -10
   ```

### Issue 2: High Memory Usage

**Symptoms:**
- Memory usage > 85%
- Swap being used heavily
- System slowdown

**Diagnosis:**
```bash
# Check memory usage
free -h

# Check which process is using memory
ps aux | sort -nk +4 | tail -10

# Check for memory leaks
pm2 monit
```

**Solutions:**
1. **Restart application:**
   ```bash
   pm2 restart beauty-lms-backend
   ```

2. **Check for memory leaks:**
   ```bash
   # Monitor over time
   while true; do
       pm2 jlist | jq -r '.[].monit.memory'
       sleep 60
   done
   ```

3. **Reduce PM2 instances:**
   ```bash
   pm2 scale beauty-lms-backend 4
   ```

4. **Upgrade RAM** if consistently high

### Issue 3: Application Not Starting

**Symptoms:**
- PM2 shows status: "errored"
- Can't access application

**Diagnosis:**
```bash
# Check detailed error
pm2 logs beauty-lms-backend --lines 50 --err

# Check if port is in use
sudo lsof -i :3000

# Test environment configuration
cd ~/Beauty-lms/backend
node -e "require('dotenv').config({path: '.env.production'}); console.log(process.env);"
```

**Solutions:**
1. **Fix environment variables:**
   ```bash
   nano ~/Beauty-lms/backend/.env.production
   ```

2. **Check Firebase credentials:**
   ```bash
   ls -la ~/.credentials/serviceAccountKey.json
   cat ~/.credentials/serviceAccountKey.json | jq .
   ```

3. **Kill process using port:**
   ```bash
   sudo kill -9 $(sudo lsof -t -i:3000)
   pm2 start ecosystem.config.js --env production
   ```

4. **Check Node.js version:**
   ```bash
   node --version  # Should be v18.x
   ```

### Issue 4: WebSocket Connection Failures

**Symptoms:**
- Real-time features not working
- Chat messages not sending
- Video not connecting

**Diagnosis:**
```bash
# Check Socket.IO endpoint
curl -v https://yourdomain.com/socket.io/?transport=polling

# Check Nginx WebSocket headers
sudo tail -f /var/log/nginx/beauty-lms-access.log | grep socket.io

# Check firewall
sudo ufw status | grep 443
```

**Solutions:**
1. **Verify Nginx WebSocket configuration:**
   ```bash
   sudo nginx -t
   grep -A 10 "socket.io" /etc/nginx/sites-available/beauty-lms
   ```

2. **Check CORS settings:**
   ```bash
   grep ALLOWED_ORIGINS ~/Beauty-lms/backend/.env.production
   ```

3. **Restart services:**
   ```bash
   pm2 restart beauty-lms-backend
   sudo systemctl restart nginx
   ```

### Issue 5: Video Connection Issues

**Symptoms:**
- Users can't see/hear each other
- Video freezing
- Connection drops

**Diagnosis:**
```bash
# Check MediaSoup announced IP
grep MEDIASOUP_ANNOUNCED_IP ~/Beauty-lms/backend/.env.production

# Check if it matches server IP
curl -4 ifconfig.me

# Check RTC ports
sudo ufw status | grep 40000:49999

# Check MediaSoup logs
pm2 logs beauty-lms-backend | grep -i "mediasoup\|transport\|producer\|consumer"
```

**Solutions:**
1. **Fix announced IP:**
   ```bash
   # Get correct IP
   PUBLIC_IP=$(curl -4 ifconfig.me)
   
   # Update .env.production
   sed -i "s/MEDIASOUP_ANNOUNCED_IP=.*/MEDIASOUP_ANNOUNCED_IP=$PUBLIC_IP/" ~/Beauty-lms/backend/.env.production
   
   # Restart
   pm2 restart beauty-lms-backend
   ```

2. **Verify firewall rules:**
   ```bash
   sudo ufw allow 40000:49999/tcp
   sudo ufw allow 40000:49999/udp
   ```

3. **Test port connectivity from outside:**
   ```bash
   # From another machine
   nc -zv -u YOUR_SERVER_IP 40000
   ```

### Issue 6: SSL Certificate Errors

**Symptoms:**
- HTTPS not working
- Browser security warnings
- Certificate expired

**Diagnosis:**
```bash
# Check certificate status
sudo certbot certificates

# Check certificate expiry
echo | openssl s_client -servername yourdomain.com -connect yourdomain.com:443 2>/dev/null | openssl x509 -noout -dates

# Check Nginx SSL config
sudo nginx -t
```

**Solutions:**
1. **Renew certificate:**
   ```bash
   sudo certbot renew --force-renewal
   sudo systemctl reload nginx
   ```

2. **Fix certificate paths in Nginx:**
   ```bash
   sudo nano /etc/nginx/sites-available/beauty-lms
   # Update ssl_certificate paths
   sudo nginx -t
   sudo systemctl reload nginx
   ```

3. **Test automatic renewal:**
   ```bash
   sudo certbot renew --dry-run
   ```

---

## 📊 Performance Optimization

### Database Query Optimization

**Firebase/Firestore:**
1. Create composite indexes for common queries
2. Use pagination for large result sets
3. Cache frequently accessed data
4. Avoid N+1 queries

**Check slow queries:**
- Monitor in Firebase Console
- Review query logs
- Optimize based on usage patterns

### Caching Strategy

**Setup Redis caching (optional but recommended):**

```bash
# Install Redis
sudo apt install -y redis-server

# Start Redis
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Test Redis
redis-cli ping  # Should return PONG
```

Update `.env.production`:
```bash
REDIS_HOST=localhost
REDIS_PORT=6379
ENABLE_REDIS_ADAPTER=true
```

**Cache Configuration:**
- Cache course data: 5 minutes
- Cache user data: 10 minutes
- Cache static data: 1 hour

### CDN Integration

For better performance with many users:

1. **Setup Cloudflare** (recommended):
   - Add your domain to Cloudflare
   - Enable caching for static assets
   - Enable auto-minification
   - Enable Brotli compression

2. **Configure caching rules:**
   - Cache recordings: 7 days
   - Cache static assets: 30 days
   - Don't cache API calls

---

## 🔄 Maintenance Tasks

### Daily Maintenance

```bash
#!/bin/bash
# daily-maintenance.sh

echo "=== Daily Maintenance - $(date) ==="

# Check application status
pm2 status

# Check disk space
df -h /

# Check recent errors
tail -20 ~/Beauty-lms/logs/backend-error.log

# Check memory usage
free -h

# Clean old logs (older than 7 days)
find ~/Beauty-lms/logs -name "*.log" -mtime +7 -delete

echo "=== Maintenance Complete ==="
```

### Weekly Maintenance

```bash
#!/bin/bash
# weekly-maintenance.sh

echo "=== Weekly Maintenance - $(date) ==="

# Update system packages
sudo apt update && sudo apt upgrade -y

# Clean old recordings (older than 30 days)
find ~/Beauty-lms/recordings/completed -type f -mtime +30 -delete

# Rotate logs
pm2 reloadLogs

# Clear PM2 logs older than 7 days
pm2 flush

# Check SSL certificate
sudo certbot certificates

# Review Nginx logs for anomalies
sudo tail -100 /var/log/nginx/beauty-lms-error.log

# Backup configuration files
tar -czf ~/backups/config-$(date +%Y%m%d).tar.gz \
  ~/Beauty-lms/backend/.env.production \
  ~/Beauty-lms/backend/ecosystem.config.js \
  /etc/nginx/sites-available/beauty-lms

echo "=== Weekly Maintenance Complete ==="
```

### Monthly Maintenance

- Full system backup
- Security audit
- Performance review
- Capacity planning
- Update dependencies
- Review and optimize database indexes
- Test disaster recovery procedures

---

## 📱 Mobile App for Monitoring

**Recommended Apps:**

1. **PM2 Mobile App**
   - Monitor PM2 processes from phone
   - Restart applications remotely
   - View logs

2. **Termux** (Android)
   - SSH into server
   - Run commands remotely

3. **ServerCat** (iOS)
   - Server monitoring
   - SSH client
   - Performance graphs

---

## 🎯 Performance Benchmarks

### Expected Performance (1500 concurrent users)

| Metric | Expected Value |
|--------|---------------|
| CPU Usage | 60-70% |
| Memory Usage | 10-12 GB |
| Network I/O | 500-1000 Mbps |
| Disk I/O | < 100 MB/s |
| API Response Time | < 200ms |
| WebSocket Latency | < 100ms |
| Video Quality | 720p @ 30fps |
| Packet Loss | < 1% |

### Load Testing

Use these tools for load testing:

1. **Artillery** (API load testing):
   ```bash
   npm install -g artillery
   artillery quick --count 100 --num 10 https://yourdomain.com/health
   ```

2. **k6** (WebSocket testing):
   ```bash
   # Install k6
   sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
   echo "deb https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
   sudo apt-get update
   sudo apt-get install k6
   
   # Run test
   k6 run loadtest.js
   ```

3. **Apache Bench** (simple HTTP testing):
   ```bash
   ab -n 1000 -c 100 https://yourdomain.com/health
   ```

---

## 📞 Emergency Procedures

### Application Crash

1. Check logs immediately
2. Restart application: `pm2 restart beauty-lms-backend`
3. Monitor for stability
4. If crashes persist, rollback to previous version

### Database Issues

1. Check Firebase Console for outages
2. Verify credentials still valid
3. Check network connectivity to Firebase
4. Review recent Firestore changes

### DDoS Attack

1. Enable Cloudflare if not already
2. Activate "Under Attack" mode
3. Review Nginx access logs for attack patterns
4. Increase rate limiting temporarily
5. Block offending IPs:
   ```bash
   sudo ufw deny from ATTACKING_IP
   ```

### Server Unresponsive

1. Try to SSH into server
2. If SSH fails, use VPS console from Hostinger panel
3. Check system load: `uptime`
4. Kill resource-intensive processes if needed
5. Restart services or reboot if necessary

---

## 📚 Resources

- **PM2 Documentation**: https://pm2.keymetrics.io/docs/
- **Nginx Documentation**: https://nginx.org/en/docs/
- **MediaSoup Documentation**: https://mediasoup.org/documentation/
- **Firebase Monitoring**: https://firebase.google.com/docs/firestore/monitor

---

**Last Updated**: 2024
**Target Capacity**: 1000-1500 Concurrent Users

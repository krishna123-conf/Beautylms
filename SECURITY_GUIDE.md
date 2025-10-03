# Beauty LMS Security Hardening Guide

Comprehensive security guide for protecting your Beauty LMS production deployment on Hostinger VPS.

## 🔒 Security Overview

This guide covers security measures for protecting against:
- **Unauthorized Access**
- **DDoS Attacks**
- **Data Breaches**
- **Code Injection**
- **Man-in-the-Middle Attacks**
- **Brute Force Attacks**

---

## 🛡️ Server Security

### 1. SSH Hardening

**Disable Password Authentication:**

```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config
```

Update these settings:
```bash
PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
Port 2222  # Change from default 22
AllowUsers beautylms  # Only allow specific user
MaxAuthTries 3
MaxSessions 2
```

Restart SSH:
```bash
sudo systemctl restart sshd
```

**Setup SSH Keys (if not already done):**

On your local machine:
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy to server
ssh-copy-id beautylms@your-server-ip
```

Update firewall for new SSH port:
```bash
sudo ufw allow 2222/tcp
sudo ufw delete allow 22/tcp
```

### 2. Firewall Configuration

**Enhanced UFW Rules:**

```bash
# Reset firewall (if needed)
sudo ufw --force reset

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (use your custom port)
sudo ufw allow 2222/tcp

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow MediaSoup RTC ports
sudo ufw allow 40000:49999/tcp
sudo ufw allow 40000:49999/udp

# Enable firewall
sudo ufw enable

# Verify rules
sudo ufw status verbose
```

**Rate Limiting for SSH:**
```bash
sudo ufw limit 2222/tcp
```

### 3. Install Fail2Ban

Protect against brute-force attacks:

```bash
# Install Fail2Ban
sudo apt install -y fail2ban

# Create local configuration
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

**Configure Fail2Ban:**
```bash
sudo nano /etc/fail2ban/jail.local
```

Add/update these sections:
```ini
[sshd]
enabled = true
port = 2222
maxretry = 3
bantime = 3600
findtime = 600

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
port = http,https
logpath = /var/log/nginx/beauty-lms-error.log

[nginx-limit-req]
enabled = true
filter = nginx-limit-req
port = http,https
logpath = /var/log/nginx/beauty-lms-error.log
maxretry = 5
bantime = 600

[nginx-botsearch]
enabled = true
port = http,https
filter = nginx-botsearch
logpath = /var/log/nginx/beauty-lms-access.log
maxretry = 2
bantime = 86400
```

Start Fail2Ban:
```bash
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# Check status
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

### 4. Automatic Security Updates

Enable unattended upgrades:

```bash
# Install
sudo apt install -y unattended-upgrades

# Configure
sudo dpkg-reconfigure -plow unattended-upgrades

# Verify configuration
cat /etc/apt/apt.conf.d/50unattended-upgrades
```

---

## 🔐 Application Security

### 1. Environment Variables Security

**Secure Credentials:**

```bash
# Secure .env.production file
chmod 600 ~/Beautylms/backend/.env.production
chown beautylms:beautylms ~/Beautylms/backend/.env.production

# Secure Firebase credentials
chmod 600 ~/.credentials/serviceAccountKey.json
chown beautylms:beautylms ~/.credentials/serviceAccountKey.json
```

**Verify no secrets in code:**
```bash
# Search for potential secrets in code
cd ~/Beautylms
grep -r "password\|secret\|key\|token" --include="*.js" backend/ | grep -v "process.env" | grep -v "// "
```

### 2. Strong Secrets Generation

**Generate Secure Secrets:**

```bash
# JWT Secret (64 bytes)
openssl rand -base64 64

# Recording Secret (32 bytes)
openssl rand -base64 32

# Session Secret (32 bytes)
openssl rand -hex 32

# API Key (16 bytes)
openssl rand -hex 16
```

Update `.env.production` with generated secrets.

### 3. Input Validation & Sanitization

The backend already includes basic validation, but ensure:

1. **Validate all user inputs**
2. **Sanitize data before database operations**
3. **Use parameterized queries**
4. **Validate file uploads**
5. **Limit request sizes**

### 4. Rate Limiting

**Application-Level Rate Limiting:**

Install express-rate-limit:
```bash
cd ~/Beautylms/backend
npm install express-rate-limit
```

Add to `server.js`:
```javascript
const rateLimit = require('express-rate-limit');

// General API rate limiter
const apiLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP, please try again later'
});

// Apply to all API routes
app.use('/api/', apiLimiter);

// Stricter limiter for authentication endpoints
const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 5,
    skipSuccessfulRequests: true
});

// Apply to auth routes
app.use('/api/auth/', authLimiter);
```

### 5. CORS Configuration

**Strict CORS Policy:**

Update `.env.production`:
```bash
# Only allow your domains
CORS_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

**Verify in code** (`backend/server.js`):
```javascript
const corsOptions = {
    origin: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    credentials: true,
    optionsSuccessStatus: 200
};
```

### 6. Content Security Policy

Add CSP headers in Nginx:

```bash
sudo nano /etc/nginx/sites-available/beauty-lms
```

Add in the `server` block:
```nginx
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' wss: https:; media-src 'self' blob:; object-src 'none'; frame-ancestors 'none'; base-uri 'self'; form-action 'self';" always;
```

---

## 🌐 Network Security

### 1. HTTPS Enforcement

**Force HTTPS Redirect:**

Already configured in `nginx.conf`, verify:
```bash
grep -A 5 "listen 80" /etc/nginx/sites-available/beauty-lms
```

Should redirect all HTTP to HTTPS.

### 2. SSL/TLS Configuration

**Enhanced SSL Settings:**

```bash
sudo nano /etc/nginx/sites-available/beauty-lms
```

Update SSL configuration:
```nginx
# Use only strong protocols
ssl_protocols TLSv1.2 TLSv1.3;

# Strong cipher suites
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305';

# Prefer server ciphers
ssl_prefer_server_ciphers off;

# Enable OCSP Stapling
ssl_stapling on;
ssl_stapling_verify on;

# Increase session cache
ssl_session_cache shared:SSL:50m;
ssl_session_timeout 1d;

# Disable session tickets
ssl_session_tickets off;
```

**Test SSL Configuration:**
```bash
# Using SSL Labs
# Visit: https://www.ssllabs.com/ssltest/analyze.html?d=yourdomain.com

# Using testssl.sh
git clone --depth 1 https://github.com/drwetter/testssl.sh.git
cd testssl.sh
./testssl.sh https://yourdomain.com
```

Target: **A+ rating** on SSL Labs

### 3. Security Headers

**Add Security Headers in Nginx:**

```nginx
# Prevent clickjacking
add_header X-Frame-Options "SAMEORIGIN" always;

# Prevent MIME type sniffing
add_header X-Content-Type-Options "nosniff" always;

# Enable XSS protection
add_header X-XSS-Protection "1; mode=block" always;

# HSTS (HTTP Strict Transport Security)
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

# Referrer Policy
add_header Referrer-Policy "no-referrer-when-downgrade" always;

# Permissions Policy
add_header Permissions-Policy "camera=('self'), microphone=('self'), geolocation=()" always;
```

Restart Nginx:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

**Verify Headers:**
```bash
curl -I https://yourdomain.com | grep -E "X-Frame-Options|Strict-Transport-Security|X-Content-Type-Options"
```

---

## 🔑 Firebase Security

### 1. Firestore Security Rules

**Update Firestore Rules in Firebase Console:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isInstructor() {
      return isAuthenticated() && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'instructor';
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId) || isInstructor();
    }
    
    // Courses collection
    match /live_courses/{courseId} {
      allow read: if isAuthenticated();
      allow create: if isInstructor();
      allow update: if isInstructor() || 
                      resource.data.instructorId == request.auth.uid;
      allow delete: if isInstructor();
    }
    
    // Recordings collection
    match /recordings/{recordingId} {
      allow read: if isAuthenticated();
      allow write: if isInstructor();
    }
    
    // Default deny all
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### 2. Firebase Authentication

**Configure Auth Settings:**

1. Enable only required sign-in methods
2. Set up authorized domains
3. Configure password policies:
   - Minimum 8 characters
   - Require uppercase, lowercase, numbers
4. Enable email verification
5. Set up account recovery

### 3. Firebase Admin SDK Security

**Secure Service Account:**

```bash
# Verify permissions
cat ~/.credentials/serviceAccountKey.json | jq '.project_id, .client_email'

# Check file permissions
ls -la ~/.credentials/serviceAccountKey.json
# Should show: -rw------- (600)
```

**Rotate Service Account Keys Regularly:**

1. Generate new key in Firebase Console
2. Update key file on server
3. Update `.env.production`
4. Restart application
5. Delete old key from Firebase

---

## 🚫 DDoS Protection

### 1. Nginx Rate Limiting

Already configured in `nginx.conf`, verify:

```nginx
# Rate limiting zones
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=30r/s;
limit_req_zone $binary_remote_addr zone=websocket_limit:10m rate=10r/s;
limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
```

### 2. Connection Limits

**System-wide connection limits:**

```bash
sudo nano /etc/sysctl.conf
```

Add:
```bash
# SYN flood protection
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_max_syn_backlog = 4096

# Connection tracking
net.netfilter.nf_conntrack_max = 262144
net.netfilter.nf_conntrack_tcp_timeout_established = 600
```

Apply:
```bash
sudo sysctl -p
```

### 3. Cloudflare Integration (Recommended)

**Setup Cloudflare:**

1. Add domain to Cloudflare
2. Update nameservers at domain registrar
3. Enable these features:
   - **DDoS Protection**: Automatic
   - **Bot Fight Mode**: Enabled
   - **Rate Limiting**: Configure rules
   - **Firewall Rules**: Block suspicious traffic
   - **IP Geolocation**: Block unwanted countries

**Cloudflare Settings:**

- **SSL/TLS Mode**: Full (strict)
- **Always Use HTTPS**: On
- **Auto Minify**: JS, CSS, HTML
- **Brotli Compression**: On
- **HTTP/2**: On
- **HTTP/3 (with QUIC)**: On

**Get Real Client IP with Cloudflare:**

Update Nginx:
```nginx
# Add to http block
set_real_ip_from 103.21.244.0/22;
set_real_ip_from 103.22.200.0/22;
set_real_ip_from 103.31.4.0/22;
# ... (add all Cloudflare IPs)
real_ip_header CF-Connecting-IP;
```

---

## 🔍 Security Monitoring

### 1. Intrusion Detection

**Install AIDE (Advanced Intrusion Detection Environment):**

```bash
sudo apt install -y aide

# Initialize database
sudo aideinit

# Move database
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Run check
sudo aide --check

# Schedule daily checks
sudo crontab -e
# Add: 0 3 * * * /usr/bin/aide --check | mail -s "AIDE Report" admin@yourdomain.com
```

### 2. Log Monitoring

**Setup Logwatch:**

```bash
sudo apt install -y logwatch

# Configure
sudo nano /etc/logwatch/conf/logwatch.conf
```

Update:
```
Output = mail
Format = html
MailTo = admin@yourdomain.com
Detail = High
```

Run manually:
```bash
sudo logwatch --output mail --format html --mailto admin@yourdomain.com
```

### 3. Security Scanning

**Install and run security scanner:**

```bash
# Install Lynis
sudo apt install -y lynis

# Run security audit
sudo lynis audit system

# Review report
cat /var/log/lynis.log
```

**Schedule regular scans:**
```bash
sudo crontab -e
# Add: 0 2 * * 1 /usr/bin/lynis audit system --cronjob
```

---

## 🛠️ Security Hardening Checklist

### Server Level
- [ ] SSH password authentication disabled
- [ ] Root login disabled
- [ ] SSH port changed from default
- [ ] Firewall (UFW) enabled and configured
- [ ] Fail2Ban installed and configured
- [ ] Automatic security updates enabled
- [ ] Unnecessary services disabled
- [ ] System fully updated

### Application Level
- [ ] Strong secrets generated and configured
- [ ] Environment files secured (600 permissions)
- [ ] CORS properly configured
- [ ] Rate limiting implemented
- [ ] Input validation in place
- [ ] Error messages don't expose sensitive info
- [ ] Dependencies up to date (no known vulnerabilities)
- [ ] Application runs as non-root user

### Network Level
- [ ] HTTPS enforced
- [ ] SSL/TLS properly configured (A+ rating)
- [ ] Security headers configured
- [ ] DDoS protection enabled
- [ ] Rate limiting configured
- [ ] Cloudflare or similar CDN configured

### Database Level
- [ ] Firebase security rules configured
- [ ] Service account key secured
- [ ] Firestore indexes optimized
- [ ] Access logging enabled
- [ ] Regular backups configured

### Monitoring
- [ ] Log monitoring configured
- [ ] Security alerts configured
- [ ] Intrusion detection installed
- [ ] Regular security scans scheduled
- [ ] Incident response plan documented

---

## 🚨 Incident Response Plan

### 1. Suspected Breach

**Immediate Actions:**

1. **Isolate the system:**
   ```bash
   # Block all incoming traffic except your IP
   sudo ufw default deny incoming
   sudo ufw allow from YOUR_IP
   ```

2. **Stop the application:**
   ```bash
   pm2 stop beauty-lms-backend
   ```

3. **Preserve evidence:**
   ```bash
   # Copy logs
   sudo cp -r /var/log ~/incident-$(date +%Y%m%d)/
   sudo cp -r ~/Beautylms/logs ~/incident-$(date +%Y%m%d)/
   ```

4. **Review access logs:**
   ```bash
   sudo tail -1000 /var/log/auth.log
   sudo tail -1000 /var/log/nginx/beauty-lms-access.log
   ```

5. **Check for unauthorized access:**
   ```bash
   # Check logged-in users
   who
   w
   last
   
   # Check cron jobs
   crontab -l
   sudo crontab -l
   
   # Check for unauthorized SSH keys
   cat ~/.ssh/authorized_keys
   ```

### 2. DDoS Attack

**Mitigation Steps:**

1. **Enable Cloudflare "Under Attack" mode** (if using Cloudflare)

2. **Increase rate limiting:**
   ```bash
   sudo nano /etc/nginx/sites-available/beauty-lms
   # Reduce rate limits temporarily
   ```

3. **Block attacking IPs:**
   ```bash
   # Find top attacking IPs
   sudo tail -10000 /var/log/nginx/beauty-lms-access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -20
   
   # Block IPs
   sudo ufw deny from ATTACKING_IP
   ```

4. **Monitor in real-time:**
   ```bash
   sudo tail -f /var/log/nginx/beauty-lms-access.log | grep -v "YOUR_IP"
   ```

### 3. Data Breach

**Response Steps:**

1. **Notify affected users immediately**
2. **Change all secrets and credentials**
3. **Rotate Firebase service account keys**
4. **Force password resets for all users**
5. **Document the breach**
6. **Report to authorities if required**

---

## 📋 Security Audit Checklist

### Monthly Security Audit

```bash
#!/bin/bash
# security-audit.sh

echo "=== Security Audit - $(date) ===" > ~/security-audit.log

echo -e "\n1. System Updates:" >> ~/security-audit.log
apt list --upgradable >> ~/security-audit.log

echo -e "\n2. Failed Login Attempts:" >> ~/security-audit.log
sudo grep "Failed password" /var/log/auth.log | tail -20 >> ~/security-audit.log

echo -e "\n3. Fail2Ban Status:" >> ~/security-audit.log
sudo fail2ban-client status >> ~/security-audit.log

echo -e "\n4. Open Ports:" >> ~/security-audit.log
sudo netstat -tuln >> ~/security-audit.log

echo -e "\n5. Firewall Status:" >> ~/security-audit.log
sudo ufw status verbose >> ~/security-audit.log

echo -e "\n6. SSL Certificate Expiry:" >> ~/security-audit.log
sudo certbot certificates >> ~/security-audit.log

echo -e "\n7. Large Files (potential uploads):" >> ~/security-audit.log
find ~/Beautylms -type f -size +100M >> ~/security-audit.log

echo -e "\n8. Running Processes:" >> ~/security-audit.log
ps aux --sort=-%mem | head -20 >> ~/security-audit.log

echo "Audit complete. Check ~/security-audit.log"
```

Make executable and schedule:
```bash
chmod +x ~/security-audit.sh
crontab -e
# Add: 0 2 1 * * /home/beautylms/security-audit.sh
```

---

## 📚 Additional Resources

- **OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **CIS Benchmarks**: https://www.cisecurity.org/cis-benchmarks/
- **Mozilla Observatory**: https://observatory.mozilla.org/
- **SecurityHeaders.com**: https://securityheaders.com/
- **SSL Labs**: https://www.ssllabs.com/ssltest/

---

## 🔄 Security Maintenance Schedule

### Daily
- Monitor application logs for errors
- Check Fail2Ban status
- Review access patterns

### Weekly
- Review system updates
- Check SSL certificate status
- Analyze security logs
- Test backup restoration

### Monthly
- Full security audit
- Update dependencies
- Review and rotate secrets
- Test incident response procedures

### Quarterly
- Penetration testing
- Review security policies
- Update security documentation
- Train team on security practices

---

**Last Updated**: 2024
**Security Level**: Production-Ready for 1000-1500 Users
**Compliance**: General security best practices

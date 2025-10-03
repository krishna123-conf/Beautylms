module.exports = {
  apps: [{
    name: 'beauty-lms-backend',
    script: './server.js',
    instances: 'max', // Use all available CPU cores for clustering
    exec_mode: 'cluster', // Enable cluster mode for scalability
    
    // Environment configuration
    env_production: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    
    // Performance and scaling settings for 1000-1500 concurrent users
    max_memory_restart: '1G', // Restart if memory exceeds 1GB
    min_uptime: '10s', // Min uptime before considering app as stable
    max_restarts: 10, // Max restarts within 1 minute before giving up
    
    // Logging configuration
    error_file: '/home/beautylms/Beauty-lms/logs/backend-error.log',
    out_file: '/home/beautylms/Beauty-lms/logs/backend-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    
    // Auto restart settings
    autorestart: true,
    watch: false, // Disable watch in production
    
    // Graceful shutdown
    kill_timeout: 5000,
    listen_timeout: 3000,
    
    // Additional production settings
    vizion: false, // Disable version control checks for better performance
    instance_var: 'INSTANCE_ID',
    
    // Advanced features
    time: true, // Enable timing for API calls
    
    // Environment variables specific to this instance
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
};

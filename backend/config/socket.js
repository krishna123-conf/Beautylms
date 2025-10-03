const { Server } = require('socket.io');

/**
 * Initialize Socket.IO server
 * Optimized for 1000-1500 concurrent users
 */
const initializeSocket = (server) => {
    const io = new Server(server, {
        cors: {
            origin: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : '*',
            methods: ['GET', 'POST'],
            credentials: true
        },
        transports: ['websocket', 'polling'],
        allowEIO3: true,
        
        // Performance optimizations for high concurrent connections
        pingTimeout: 60000,
        pingInterval: 25000,
        upgradeTimeout: 30000,
        maxHttpBufferSize: 1e6, // 1MB
        
        // Connection settings optimized for 1000-1500 users
        perMessageDeflate: {
            threshold: 1024,
            zlibDeflateOptions: {
                chunkSize: 1024,
                memLevel: 7,
                level: 3
            },
            zlibInflateOptions: {
                chunkSize: 10 * 1024
            },
            clientNoContextTakeover: true,
            serverNoContextTakeover: true,
            serverMaxWindowBits: 10,
            concurrencyLimit: 10
        },
        
        // HTTP long-polling options
        httpCompression: true,
        
        // Additional performance settings
        connectTimeout: 45000,
        serveClient: false, // Don't serve client library
        cookie: false // Disable cookies for better performance
    });

    console.log('✅ Socket.IO server initialized (optimized for high concurrent users)');
    return io;
};

module.exports = {
    initializeSocket
};
import express from 'express';
import { createServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';
import dgram from 'dgram';
import os from 'os';
import { randomUUID } from 'crypto';

// Configuration (can be overridden by env vars)
const CHAT_PORT = parseInt(process.env.CHAT_PORT || '4000', 10);
const DISCOVERY_PORT = parseInt(process.env.DISCOVERY_PORT || '45454', 10);
const SERVER_NAME = 'MN Holidays LAN Chat';

// ============================================================================
// UTILITIES
// ============================================================================

/**
 * Get local IPv4 address (required for UDP broadcast response).
 * Prefers non-loopback interfaces, skips Tailscale/VPN.
 */
function getLocalIPv4() {
  const interfaces = os.networkInterfaces();
  
  // Try to find Ethernet or WiFi interface first (skip Tailscale)
  for (const name of Object.keys(interfaces)) {
    // Skip Tailscale and other VPN interfaces
    if (name.toLowerCase().includes('tailscale') || 
        name.toLowerCase().includes('vpn') ||
        name.toLowerCase().includes('docker')) {
      continue;
    }
    
    for (const iface of interfaces[name]) {
      // Prefer IPv4, skip loopback
      if (iface.family === 'IPv4' && !iface.internal) {
        return iface.address;
      }
    }
  }
  
  // Fallback to localhost if no suitable interface found
  return '127.0.0.1';
}

/**
 * Generate a unique socket ID (in-memory only, for this session).
 */
function generateSocketId() {
  return randomUUID();
}

// ============================================================================
// STATE MANAGEMENT (in-memory)
// ============================================================================

// Presence: Map of userId -> { id, name, socketId, channels: Set }
const presence = new Map();

// Messages: Map of channelId -> [{ _id, channelId, senderId, senderName, text, createdAt }]
const messages = new Map();

// Socket registry: Map of socketId -> socket instance
const sockets = new Map();

// ============================================================================
// EXPRESS + HTTP SERVER
// ============================================================================

const app = express();
const httpServer = createServer(app);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    ok: true,
    app: SERVER_NAME,
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// ============================================================================
// SOCKET.IO SERVER
// ============================================================================

const io = new SocketIOServer(httpServer, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
  transports: ['websocket', 'polling'],
});

/**
 * Helper: Broadcast presence to all connected clients.
 */
function broadcastPresence(io) {
  const presenceArray = Array.from(presence.values()).map((p) => ({
    id: p.id,
    name: p.name,
  }));
  io.emit('presence', presenceArray);
}

/**
 * Helper: Get all messages for a channel (returns last 100 for performance).
 */
function getChannelMessages(channelId) {
  const channelMessages = messages.get(channelId) || [];
  return channelMessages.slice(-100); // Last 100 messages only
}

// Socket.IO connection handler
io.on('connection', (socket) => {
  console.log(`[Socket.IO] Client connected: ${socket.id}`);
  sockets.set(socket.id, socket);

  // -------------------------------------------------------------------------
  // EVENT: "hello" - Client introduction & presence registration
  // -------------------------------------------------------------------------
  socket.on('hello', (payload) => {
    try {
      const { name } = payload;
      if (!name || typeof name !== 'string' || name.trim() === '') {
        console.warn(`[hello] Invalid name from ${socket.id}: skipping`);
        return;
      }

      const userId = generateSocketId();
      presence.set(userId, {
        id: userId,
        name: name.trim(),
        socketId: socket.id,
        channels: new Set(),
      });

      console.log(`[hello] ${name} (${userId}) joined. Total presence: ${presence.size}`);

      // Broadcast updated presence to all clients
      broadcastPresence(io);

      // Send presence back to this client
      socket.emit('presence', Array.from(presence.values()).map((p) => ({ id: p.id, name: p.name })));
    } catch (err) {
      console.error('[hello] Error:', err.message);
    }
  });

  // -------------------------------------------------------------------------
  // EVENT: "join" - Client joins a channel (room)
  // -------------------------------------------------------------------------
  socket.on('join', (payload) => {
    try {
      const { channelId } = payload;
      if (!channelId || typeof channelId !== 'string') {
        console.warn(`[join] Invalid channelId from ${socket.id}: ${channelId}`);
        return;
      }

      socket.join(channelId);
      console.log(`[join] ${socket.id} joined channel: ${channelId}`);

      // Send existing channel messages to this socket (last 100)
      const channelMessages = getChannelMessages(channelId);
      socket.emit('message:history', {
        channelId,
        messages: channelMessages,
      });

      // Notify channel that user joined
      io.to(channelId).emit('user:joined', {
        channelId,
        message: `User connected to channel`,
      });
    } catch (err) {
      console.error('[join] Error:', err.message);
    }
  });

  // -------------------------------------------------------------------------
  // EVENT: "message:create" - Client sends a message
  // -------------------------------------------------------------------------
  socket.on('message:create', (payload) => {
    try {
      const { channelId, text } = payload;
      if (!channelId || !text || typeof text !== 'string' || text.trim() === '') {
        console.warn(`[message:create] Invalid payload from ${socket.id}`);
        return;
      }

      // Find sender name from presence
      let senderName = 'Anonymous';
      let senderId = null;
      for (const [userId, user] of presence.entries()) {
        if (user.socketId === socket.id) {
          senderId = userId;
          senderName = user.name;
          break;
        }
      }

      const messageId = randomUUID();
      const newMessage = {
        _id: messageId,
        channelId,
        senderId,
        senderName,
        text: text.trim(),
        createdAt: new Date().toISOString(),
      };

      // Store message in channel
      if (!messages.has(channelId)) {
        messages.set(channelId, []);
      }
      messages.get(channelId).push(newMessage);
      console.log(`[message:create] ${senderName} -> ${channelId}: "${text.substring(0, 50)}..."`);

      // Emit to all clients in this channel
      io.to(channelId).emit('message:new', newMessage);
    } catch (err) {
      console.error('[message:create] Error:', err.message);
    }
  });

  // -------------------------------------------------------------------------
  // EVENT: "typing" - User is typing indicator
  // -------------------------------------------------------------------------
  socket.on('typing', (payload) => {
    try {
      const { channelId, isTyping } = payload;
      if (!channelId) {
        return;
      }

      // Find user name
      let userName = 'Someone';
      for (const [, user] of presence.entries()) {
        if (user.socketId === socket.id) {
          userName = user.name;
          break;
        }
      }

      // Broadcast to channel (except sender)
      socket.broadcast.to(channelId).emit('typing', {
        userId: socket.id,
        userName,
        isTyping,
      });
    } catch (err) {
      console.error('[typing] Error:', err.message);
    }
  });

  // -------------------------------------------------------------------------
  // EVENT: "disconnect" - Client disconnects
  // -------------------------------------------------------------------------
  socket.on('disconnect', () => {
    console.log(`[Socket.IO] Client disconnected: ${socket.id}`);
    sockets.delete(socket.id);

    // Remove from presence
    for (const [userId, user] of presence.entries()) {
      if (user.socketId === socket.id) {
        presence.delete(userId);
        console.log(`[disconnect] ${user.name} removed from presence`);
        break;
      }
    }

    // Broadcast updated presence
    broadcastPresence(io);
  });

  // -------------------------------------------------------------------------
  // ERROR HANDLING
  // -------------------------------------------------------------------------
  socket.on('error', (err) => {
    console.error(`[Socket.IO Error] ${socket.id}:`, err);
  });
});

// ============================================================================
// UDP DISCOVERY SERVER
// ============================================================================

const discoverySocket = dgram.createSocket('udp4');

discoverySocket.on('message', (msg, rinfo) => {
  try {
    const message = msg.toString('utf-8').trim();

    // Check for discovery request
    if (message === 'MNCHAT_DISCOVER') {
      const localIP = getLocalIPv4();
      const response = JSON.stringify({
        host: localIP,
        port: CHAT_PORT,
        name: SERVER_NAME,
      });

      console.log(`[UDP Discovery] Received MNCHAT_DISCOVER from ${rinfo.address}:${rinfo.port}, replying with ${localIP}:${CHAT_PORT}`);

      discoverySocket.send(response, 0, response.length, rinfo.port, rinfo.address, (err) => {
        if (err) {
          console.error('[UDP Discovery] Send error:', err.message);
        }
      });
    }
  } catch (err) {
    console.error('[UDP Discovery] Error processing message:', err.message);
  }
});

discoverySocket.on('error', (err) => {
  console.error('[UDP Discovery Error]:', err.message);
  discoverySocket.close();
});

discoverySocket.on('listening', () => {
  const addr = discoverySocket.address();
  console.log(`[UDP Discovery] Server listening on ${addr.address}:${addr.port}`);
  discoverySocket.setBroadcast(true);
});

// ============================================================================
// GRACEFUL SHUTDOWN
// ============================================================================

process.on('SIGINT', () => {
  console.log('\n[Server] SIGINT received. Shutting down gracefully...');
  io.close();
  httpServer.close(() => {
    console.log('[Server] HTTP server closed');
  });
  discoverySocket.close(() => {
    console.log('[Server] UDP discovery server closed');
  });
  process.exit(0);
});

// ============================================================================
// START SERVERS
// ============================================================================

httpServer.listen(CHAT_PORT, '0.0.0.0', () => {
  console.log(`[Server] Chat server listening on 0.0.0.0:${CHAT_PORT}`);
});

discoverySocket.bind(DISCOVERY_PORT, '0.0.0.0', () => {
  console.log(`[Server] Discovery server bound to 0.0.0.0:${DISCOVERY_PORT}`);
});

// ============================================================================
// STARTUP LOG
// ============================================================================

console.log(`
╔════════════════════════════════════════════╗
║   M&N Holidays LAN Chat Server v1.0.0      ║
║   Offline Office Network Chat              ║
╚════════════════════════════════════════════╝
Port (Chat): ${CHAT_PORT} (TCP, Socket.IO)
Port (Discovery): ${DISCOVERY_PORT} (UDP broadcast)
Local IP: ${getLocalIPv4()}

Configuration:
  - CHAT_PORT (env): ${CHAT_PORT}
  - DISCOVERY_PORT (env): ${DISCOVERY_PORT}
  - In-memory storage (no persistence)
  - WebSocket transport enabled

Getting Started:
  1. Ensure firewall allows TCP ${CHAT_PORT} and UDP ${DISCOVERY_PORT}
  2. Run Flutter client on same Wi-Fi/LAN subnet
  3. Client will auto-discover this server via UDP
  
`);

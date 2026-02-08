# M&N Holidays LAN Chat Server

A lightweight, offline-first chat server designed for office LANs with auto-discovery via UDP broadcast. Built with Node.js, Express, and Socket.IO.

## Features

- **Auto-Discovery**: UDP broadcast mechanism (port 45454) allows clients to find the server automatically on the same Wi-Fi/LAN subnet
- **Real-time Chat**: Socket.IO WebSocket communication with fallback to polling
- **Channels**: Support for multiple chat channels (e.g., "ops", "general")
- **Presence**: Live user list showing who is online
- **Typing Indicator**: See when someone is typing
- **Message History**: Client can receive previous messages upon joining a channel
- **In-Memory Storage**: No database required; suitable for office use
- **Windows/macOS/Linux Friendly**: Cross-platform Node.js implementation

## Requirements

- **Node.js** v14 or later
- **npm** (comes with Node.js)
- **Network**: Office Wi-Fi/LAN (no internet required)

## Installation

1. **Navigate to the server directory:**
   ```bash
   cd server
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

## Running the Server

```bash
node index.js
```

You should see output like:
```
╔════════════════════════════════════════════╗
║   M&N Holidays LAN Chat Server v1.0.0      ║
║   Offline Office Network Chat              ║
╚════════════════════════════════════════════╝
Port (Chat): 4000 (TCP, Socket.IO)
Port (Discovery): 45454 (UDP broadcast)
Local IP: 192.168.1.100

[UDP Discovery] Server listening on 0.0.0.0:45454
[Server] Chat server listening on 0.0.0.0:4000
```

### Environment Variables (Optional)

- `CHAT_PORT` (default: 4000) – TCP port for Socket.IO chat
- `DISCOVERY_PORT` (default: 45454) – UDP port for server discovery

Example:
```bash
CHAT_PORT=5000 DISCOVERY_PORT=50000 node index.js
```

## API Endpoints

### Health Check
```
GET http://<server-ip>:4000/health
```

Response:
```json
{
  "ok": true,
  "app": "MN Holidays LAN Chat",
  "timestamp": "2026-02-08T10:30:45.123Z",
  "uptime": 123.456
}
```

## Socket.IO Events

### Client → Server

#### `hello`
Register user presence.
```js
socket.emit('hello', { name: 'Agent-01' });
```

#### `join`
Join a chat channel/room.
```js
socket.emit('join', { channelId: 'ops' });
```

#### `message:create`
Send a message to a channel.
```js
socket.emit('message:create', { channelId: 'ops', text: 'Hello team!' });
```

#### `typing`
Broadcast that user is typing.
```js
socket.emit('typing', { channelId: 'ops', isTyping: true });
```

### Server → Client

#### `presence`
Broadcast of all online users.
```js
socket.on('presence', (users) => {
  // users: [{ id, name }, ...]
});
```

#### `message:new`
New message from server.
```js
socket.on('message:new', (msg) => {
  // msg: { _id, channelId, senderId, senderName, text, createdAt }
});
```

#### `message:history`
Message history when joining a channel.
```js
socket.on('message:history', (data) => {
  // data: { channelId, messages: [...] }
});
```

#### `typing`
Someone is typing.
```js
socket.on('typing', (data) => {
  // data: { userId, userName, isTyping }
});
```

## Testing Discovery with netcat (Windows)

If you want to test UDP discovery without running the Flutter client:

### Windows (PowerShell)

1. **Install netcat for Windows** (if not already installed):
   ```powershell
   # Using chocolatey:
   choco install netcat
   
   # Or manually download from: https://eternallybored.org/misc/netcat/
   ```

2. **Test discovery:**
   ```powershell
   echo "MNCHAT_DISCOVER" | nc -u -w 1 192.168.1.100 45454
   ```
   Replace `192.168.1.100` with your server's IP.

   Expected response:
   ```json
   {"host":"192.168.1.100","port":4000,"name":"MN Holidays LAN Chat"}
   ```

### macOS / Linux

```bash
echo "MNCHAT_DISCOVER" | nc -u -w 1 192.168.1.100 45454
```

## Windows Firewall Configuration

To allow the chat server on Windows with Firewall enabled:

### Using Windows Defender Firewall UI

1. **Open Windows Defender Firewall** → "Allow an app through firewall"
2. **Create inbound rule for TCP port 4000:**
   - Click "Allow another app" → "Browse" → select `node.exe`
   - Click "Add"
   - Edit rule: ensure both "Private" and "Public" are checked
   - Protocol: TCP, Port: 4000
3. **Create inbound rule for UDP port 45454:**
   - Go to "Advanced Settings" → "Inbound Rules" → "New Rule"
   - Rule type: Port
   - Protocol: UDP
   - Specific port: 45454
   - Action: Allow
   - Apply to: Private, Public, Domain

### Using PowerShell (Admin)

```powershell
# Allow TCP 4000 (Chat)
netsh advfirewall firewall add rule name="MN Chat Server TCP" `
  dir=in action=allow protocol=tcp localport=4000 profile=any

# Allow UDP 45454 (Discovery)
netsh advfirewall firewall add rule name="MN Chat Discovery UDP" `
  dir=in action=allow protocol=udp localport=45454 profile=any
```

### Testing Firewall

From a client machine on the same LAN:
```powershell
Test-NetConnection -ComputerName <server-ip> -Port 4000
```

## Architecture

### Presence Management
- Each connected client is tracked in an in-memory map
- On `hello`, a user is added to presence
- On disconnect or timeout, user is removed
- Presence is broadcast to all clients

### Messages
- Stored in-memory per channel (last 100 messages)
- No persistence between server restarts
- Messages are JSON objects with sender info and timestamp

### UDP Discovery
- Server listens on `0.0.0.0:45454`
- Client sends broadcast: `MNCHAT_DISCOVER`
- Server replies with JSON containing host, port, and friendly name
- Client connects to Socket.IO server after discovery

## Troubleshooting

### "Port already in use"
Another process is using port 4000 or 45454. Change them:
```bash
CHAT_PORT=5000 DISCOVERY_PORT=50000 node index.js
```

### "No clients connecting"
- Ensure client and server are on **same Wi-Fi/LAN** (same subnet)
- Check firewall rules on server (both inbound TCP and UDP)
- Verify server IP is reachable: `ping <server-ip>`
- Check DNS/mDNS not interfering with local discovery

### "Messages not arriving"
- Verify client has called `join` for the channel before sending messages
- Check if server console shows `[message:create]` logs
- Ensure Socket.IO is connected (check browser DevTools if any)

## Production Notes

- **Security**: This server is designed for **office LAN only**; no authentication or encryption
- **Scalability**: In-memory storage works for small teams; use a database for larger deployments
- **Persistence**: Messages are lost on server restart; add MongoDB/PostgreSQL if needed
- **Admin tools**: Consider adding a simple dashboard for debugging (future v2)

## License

MIT

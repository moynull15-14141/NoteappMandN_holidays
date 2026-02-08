# M&N Holidays LAN Chat System - Complete Setup Guide

## Project Overview

A production-ready office LAN chat system with:
- **Backend**: Node.js Express server with Socket.IO (v4) + UDP auto-discovery
- **Frontend**: Flutter desktop app (Windows/macOS/Linux) with integrated chat tab
- **Network**: Offline-first, works completely on office Wi-Fi/LAN
- **Architecture**: Monorepo with separate `server/` and `client/` directories

## Complete File Tree

```
NoteappMandN_holidays-main/
├── server/
│   ├── package.json                    # Node.js dependencies
│   ├── index.js                        # Express + Socket.IO + UDP server
│   └── README.md                       # Server setup & troubleshooting
│
├── client/
│   ├── pubspec.yaml                    # Flutter dependencies (UPDATED)
│   ├── lib/
│   │   ├── main.dart                   # App entry (UPDATED: added chat route)
│   │   ├── chat/
│   │   │   ├── lan_discovery.dart      # UDP discovery service
│   │   │   ├── socket_service.dart     # Socket.IO client
│   │   │   └── chat_screen.dart        # Chat UI with messages
│   │   ├── presentation/
│   │   │   └── screens/
│   │   │       ├── home_screen.dart    # (UPDATED: added Chat tab to nav)
│   │   │       └── invoice_screen.dart # (Existing: untouched)
│   │   ├── core/                       # (Existing: untouched)
│   │   └── data/                       # (Existing: untouched)
│   └── README.md                       # Flutter client setup
│
└── [All existing Flutter app files preserved]
    ├── android/
    ├── ios/
    ├── linux/
    ├── macos/
    ├── windows/
    └── ...
```

## Quick Start (5 minutes)

### Step 1: Start the Server

```bash
cd server
npm install
node index.js
```

Expected output:
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

### Step 2: Run Flutter Client (Windows)

```bash
# Get dependencies
flutter pub get

# Run on Windows
flutter run -d windows
```

### Step 3: Open Chat Tab

1. App opens with Navigation Rail (desktop) or BottomNavigationBar (mobile)
2. Click **"Chat"** tab (rightmost icon)
3. Auto-discovery happens automatically within 3 seconds
4. You're connected! Start typing.

### Step 4: Multi-User Test (Optional)

- Start server on **PC-A** (192.168.1.100)
- Run client on **PC-A** → connects automatically
- Run client on **PC-B** (same Wi-Fi) → both see each other online
- Type message on **PC-A** → appears instantly on **PC-B**

## Architecture Overview

### Backend (Node.js)

**Three main services:**

1. **Express HTTP Server** (port 4000)
   - `/health` endpoint for monitoring
   - Hosts Socket.IO WebSocket server

2. **Socket.IO Server** (port 4000, same as Express)
   - **Presence**: Tracks online users
   - **Channels**: Users join rooms (e.g., "ops")
   - **Messages**: In-memory store (last 100 per channel)
   - **Typing**: Real-time typing indicator

3. **UDP Discovery Service** (port 45454)
   - Listens for broadcast `MNCHAT_DISCOVER`
   - Replies with `{host, port, name}` JSON
   - Enables zero-config client connection

**Event Flow:**
```
Client → UDP Broadcast "MNCHAT_DISCOVER"
         ↓
Server  → UDP Reply {host: 192.168.1.100, port: 4000, ...}
         ↓
Client  → Connect Socket.IO → Emit "hello" {name}
         ↓
Server  → Broadcast "presence" [list of users]
         ↓
Client  → Show online count, ready to chat
```

### Frontend (Flutter)

**Three new modules in `lib/chat/`:**

1. **`lan_discovery.dart`**
   - `LANDiscovery.discover()` → broadcast UDP, wait for reply
   - Timeout 3 seconds, returns `DiscoveredServer?`

2. **`socket_service.dart`**
   - `SocketService` class for connection management
   - Callbacks: `onPresenceUpdated`, `onMessageReceived`, `onTypingUpdated`, etc.
   - Methods: `connect()`, `sendMessage()`, `emitTyping()`, `disconnect()`

3. **`chat_screen.dart`**
   - Full UI: message list, input box, send button
   - Shows: presence count, typing indicator, online status
   - Init: auto-discovers, connects, loads history
   - Error handling: retry on discovery timeout

**Navigation Integration:**
- Added "Chat" to NavigationRail (desktop) and BottomNavigationBar (mobile)
- Case 4 in home_screen.dart `_buildContent()` returns `ChatScreen()`
- Route `/chat` in main.dart

## Deployment Checklist

### Prerequisites
- [ ] Visual Studio Code with Flutter/Dart extensions
- [ ] Node.js 14+ installed
- [ ] Flutter 3.3.0+ installed
- [ ] Network: server and client on same Wi-Fi subnet
- [ ] Admin access to Windows Firewall (if needed)

### Backend Setup
- [ ] `cd server && npm install`
- [ ] Verify `npm list` shows `express@4.18.2` and `socket.io@4.7.2`
- [ ] Test: `node index.js` → should log port info
- [ ] Note: Press `Ctrl+C` to stop server

### Frontend Setup
- [ ] `flutter pub get` in root directory
- [ ] Verify: `flutter doctor -v` shows no errors
- [ ] Verify: socket_io_client and intl in pubspec.yaml
- [ ] Test build: `flutter build windows --release` (optional, for packaging)

### Windows Firewall (Firewall Enabled)

**Option A: PowerShell (Admin)**
```powershell
netsh advfirewall firewall add rule name="MN Chat Discovery" `
  dir=in action=allow protocol=udp localport=45454 profile=any

netsh advfirewall firewall add rule name="MN Chat Server" `
  dir=in action=allow protocol=tcp localport=4000 profile=any
```

**Option B: Windows Defender Firewall UI**
1. Open Settings → Privacy & Security → Windows Defender Firewall
2. Click "Allow an app through firewall"
3. Add inbound rules for:
   - `node.exe` (TCP/UDP any port)
   - Or specific ports: TCP 4000, UDP 45454

### Testing Checklist
- [ ] Server running: `node server/index.js` (Terminal 1)
- [ ] Client running: `flutter run -d windows` (Terminal 2, same PC)
- [ ] Click Chat tab → "Discovering chat server..." should complete in 3s
- [ ] Presence shows "1 user online"
- [ ] Type message → appears in chat with timestamp
- [ ] (Optional) Run second client on different PC → both see messages

## Ports & Network Configuration

| Service | Protocol | Port | Description |
|---------|----------|------|-------------|
| Chat Server | TCP | 4000 | Socket.IO WebSocket |
| Discovery | UDP | 45454 | Broadcast & reply |

### Network Requirements
- **Same subnet**: Both server and client must be on same Wi-Fi/LAN
- **Broadcast enabled**: Wi-Fi must allow UDP broadcasts (most office Wi-Fi does)
- **Firewall**: Must allow inbound TCP 4000 and UDP 45454

### Testing Network Connectivity

**From client machine:**
```powershell
# Test if server IP is reachable
ping 192.168.1.100

# Test if TCP 4000 is open
Test-NetConnection -ComputerName 192.168.1.100 -Port 4000

# Test if UDP 45454 is reachable (manual test)
# Use netcat or write a simple UDP client
```

## API Reference

### Socket.IO Events

#### Client → Server

```dart
// Introduce user
socket.emit('hello', { name: 'Agent-01' });

// Join channel
socket.emit('join', { channelId: 'ops' });

// Send message
socket.emit('message:create', {
  channelId: 'ops',
  text: 'Hello team!'
});

// Typing indicator
socket.emit('typing', {
  channelId: 'ops',
  isTyping: true  // or false
});
```

#### Server → Client

```dart
// Broadcast of all online users
socket.on('presence', (users) => {
  // users: [{ id, name }, ...]
});

// New message received
socket.on('message:new', (msg) => {
  // msg: { _id, channelId, senderId, senderName, text, createdAt }
});

// Message history when joining channel
socket.on('message:history', (data) => {
  // data: { channelId, messages: [...] }
});

// User typing
socket.on('typing', (data) => {
  // data: { userId, userName, isTyping }
});
```

## Environment Variables

### Server

```bash
# Optional: customize ports
NODE_ENV=production
CHAT_PORT=4000              # default: 4000
DISCOVERY_PORT=45454        # default: 45454
```

Example:
```bash
CHAT_PORT=5000 DISCOVERY_PORT=50000 node index.js
```

## Troubleshooting

### "No LAN chat server found"
- **Server not running?** Start with `node server/index.js`
- **Wrong subnet?** Ensure both on same Wi-Fi (ping test: `ping <server-ip>`)
- **Firewall blocking?** Allow UDP 45454 inbound
- **Timeout too short?** Edit `lan_discovery.dart` line ~70 to increase `timeoutSeconds`

### Messages not appearing
- **Socket not connected?** Check app bar status indicator (green = connected)
- **Wrong channel?** Both must join same channel (default: "ops")
- **Server crashed?** Check console logs

### "Connection refused" error
- **TCP 4000 blocked?** Check firewall rules, ensure `netsh` rules applied
- **Server on different port?** Set `CHAT_PORT` env var

### Discovery works but connection hangs
- **WebSocket fallback?** Socket.IO tries WebSocket first, then polling
- **Proxy interference?** Office proxy might block WebSocket; polling is fallback
- **Browser DevTools?** If testing in browser, check Network tab

## Production Deployment Notes

### For Office Networks

1. **Install on main PC/server:**
   ```bash
   node server/index.js &  # Run in background
   ```
   Or use PM2 for process management:
   ```bash
   npm install -g pm2
   pm2 start index.js --name "mn-chat"
   pm2 startup
   pm2 save
   ```

2. **Client App:**
   - Distribute Flutter `.exe` (Windows) or `.dmg` (macOS)
   - Build: `flutter build windows --release`
   - Output: `build/windows/runner/Release/`

3. **Firewall (Organization IT):**
   - Request TCP 4000 and UDP 45454 allowed
   - Or: Run server on isolated office PC with direct client access

### Scalability

**Current Limits (v1):**
- ~50+ concurrent users
- 100 messages/channel in memory
- Single channel ("ops")

**For larger deployments:**
- Add database (MongoDB/PostgreSQL) for message persistence
- Implement multiple channels UI
- Add user authentication
- Use Redis for presence/state distribution
- Deploy on cloud (AWS, GCP) if internet connection needed

## Support & Maintenance

### Logs

**Server Console Output:**
```
[Socket.IO] Client connected: <socket-id>
[hello] <name> joined. Total presence: N
[join] <socket-id> joined channel: ops
[message:create] <name> -> ops: "message text..."
[UDP Discovery] Received MNCHAT_DISCOVER from IP:PORT
[Socket.IO] Client disconnected: <socket-id>
```

**Flutter Console Output:**
```
[LANDiscovery] Sending MNCHAT_DISCOVER broadcast...
[LANDiscovery] Server discovered: DiscoveredServer(...)
[SocketService] Connecting to http://...
[SocketService] Connected to Socket.IO server
[SocketService] Message received: ...
```

### Common Maintenance Tasks

**Restart Server:**
```bash
# Kill current process
Ctrl+C

# Restart
node index.js
```

**Check Server Health:**
```bash
curl http://localhost:4000/health
# Expected: {"ok":true,"app":"MN Holidays LAN Chat",...}
```

**Clear In-Memory Storage:**
- Server restart clears all messages and presence
- No persistent data to clean up

## Version History

- **v1.0.0** (Feb 2026): Initial release
  - Core chat functionality
  - UDP auto-discovery
  - Socket.IO WebSocket
  - Flutter desktop integration
  - In-memory storage

## License

MIT - Free for office use, commercial support available.

---

**Need help?** See `server/README.md` for backend details, `client/README.md` for frontend details.

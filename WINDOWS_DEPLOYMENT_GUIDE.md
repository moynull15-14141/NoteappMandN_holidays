# Windows Deployment Guide for M&N Holidays LAN Chat

## Windows-Specific Setup (Quick Reference)

### Prerequisites
- Windows 10/11 (Build 19041 or later recommended)
- Node.js 14+ LTS (https://nodejs.org/)
- Flutter 3.3.0+ (https://flutter.dev/docs/get-started/install/windows)
- Visual Studio 2019+ Build Tools (for C++ dependencies in Flutter)

### Installation Steps

#### 1. Install Node.js and npm

**Option A: Download Installer**
- Visit https://nodejs.org/ → Download LTS version
- Run installer, follow defaults
- Verify: Open PowerShell, run:
  ```powershell
  node --version
  npm --version
  ```

**Option B: Using Chocolatey (if installed)**
```powershell
choco install nodejs-lts
```

#### 2. Verify Flutter Installation

```powershell
flutter doctor
```

Should show:
- ✓ Flutter (Channel stable)
- ✓ Windows toolchain
- ✓ Visual Studio
- ✓ Android Studio (optional for this project)

If issues, run:
```powershell
flutter pub get
```

#### 3. Start Chat Server

**Terminal 1 (PowerShell or CMD):**

```powershell
cd "D:\NoteappMandN_holidays-main\server"
npm install
node index.js
```

**Expected Output:**
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

**Note Server IP**: You'll need this for firewall rules.

**Keep this terminal open** (or run in background with PM2).

#### 4. Run Flutter Client

**Terminal 2 (PowerShell or CMD):**

```powershell
cd "D:\NoteappMandN_holidays-main"
flutter pub get
flutter run -d windows
```

The Flutter app will launch. Click the **"Chat"** tab to test.

### Windows Firewall Configuration

#### ⚠️ IMPORTANT: Do This If You Get "Connection Refused"

**Option 1: Using PowerShell (Recommended for Automation)**

Open PowerShell **as Administrator** and run:

```powershell
# Rule 1: Allow UDP Discovery (Port 45454)
netsh advfirewall firewall add rule `
  name="MN Chat Discovery (UDP)" `
  dir=in `
  action=allow `
  protocol=udp `
  localport=45454 `
  profile=any `
  remoteip=LocalSubnet

# Rule 2: Allow TCP Chat Server (Port 4000)
netsh advfirewall firewall add rule `
  name="MN Chat Server (TCP)" `
  dir=in `
  action=allow `
  protocol=tcp `
  localport=4000 `
  profile=any `
  remoteip=LocalSubnet

# Verify rules were added
netsh advfirewall firewall show rule name="MN Chat*"
```

**To remove rules later:**
```powershell
netsh advfirewall firewall delete rule name="MN Chat Discovery (UDP)"
netsh advfirewall firewall delete rule name="MN Chat Server (TCP)"
```

#### Option 2: Using Windows Defender Firewall UI (Manual)

1. **Open Windows Defender Firewall:**
   - Press `Win + R`, type `wf.msc`, press Enter
   - Or: Settings → System → Firewall & network protection → Advanced settings

2. **Create Inbound Rule for TCP 4000:**
   - Left panel → Click **"Inbound Rules"**
   - Right panel → Click **"New Rule..."**
   - **Rule Type**: Select "Port" → Next
   - **Protocol and Ports**: 
     - Protocol: TCP
     - Specific local ports: `4000`
     - Next
   - **Action**: "Allow the connection" → Next
   - **Profile**: Check all (Domain, Private, Public) → Next
   - **Name**: `MN Chat Server TCP`
   - **Description**: `Allow M&N Holidays LAN Chat on port 4000`
   - Click Finish

3. **Create Inbound Rule for UDP 45454:**
   - Repeat same steps, but:
     - Protocol: UDP
     - Port: `45454`
     - Name: `MN Chat Discovery UDP`

**Verify rules:**
- In Inbound Rules list, search for "MN Chat"
- Both rules should be listed with Action: "Allow"
- Status: Enabled (green checkmark)

#### Option 3: Using Command Line (One-Liner)

```cmd
REM Run as Administrator
netsh advfirewall firewall add rule name="MN Chat" dir=in action=allow protocol=tcp localport=4000 & netsh advfirewall firewall add rule name="MN Chat UDP" dir=in action=allow protocol=udp localport=45454
```

### Testing Network Connectivity

Before troubleshooting, verify network settings:

```powershell
# Get your PC's IP address
ipconfig /all

# Look for IPv4 Address (e.g., 192.168.1.100)
```

**Test if server's TCP port is accessible:**
```powershell
# From a different PC on same network
Test-NetConnection -ComputerName 192.168.1.100 -Port 4000

# Expected output (after ~1 second):
# TcpTestSucceeded : True
```

**Test UDP discovery manually:**
```powershell
# Send test UDP packet (requires netcat)
# First, install netcat or use PowerShell directly:

@"
import socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
sock.sendto(b'MNCHAT_DISCOVER', ('255.255.255.255', 45454))
data, addr = sock.recvfrom(1024)
print(f'Received: {data.decode()} from {addr}')
"@ | python -
```

### Running Multiple Clients

**Test from different PCs on same Wi-Fi:**

1. **PC-A (Server PC):**
   - Terminal 1: `node server/index.js` (running)
   - Terminal 2: `flutter run -d windows` (client)
   - Open Chat tab → "1 user online"

2. **PC-B (Client PC):**
   - Same Wi-Fi as PC-A
   - `flutter run -d windows`
   - Open Chat tab → "2 users online"
   - Both see each other's messages in real-time

### Troubleshooting on Windows

#### Problem: "Connection refused" or "No connection"

**Step 1: Verify firewall rules**
```powershell
netsh advfirewall firewall show rule name="MN Chat" status=enabled
```
Should show 2 rules (TCP + UDP). If empty:
- Add rules using PowerShell commands above
- Restart Flutter app

**Step 2: Verify server is running**
```powershell
netstat -ano | findstr ":4000"
# Should show: TCP 0.0.0.0:4000 LISTENING
```
If not:
- Terminal running `node index.js`? Check it's still running
- Restart: Ctrl+C, then `node index.js`

**Step 3: Verify both devices are on same subnet**
```powershell
ipconfig /all
# Server IP: 192.168.1.100
# Client IP: 192.168.1.101
# Subnet mask: 255.255.255.0 (means both on 192.168.1.x)
```
If client IP is different (e.g., 192.168.0.x):
- Connect to same Wi-Fi network
- Restart both devices' network adapters

#### Problem: "No LAN chat server found"

**Step 1: Check if server is reachable**
```powershell
ping <server-ip>
```

**Step 2: Increase discovery timeout**
- Edit `lib/chat/lan_discovery.dart` line ~65:
  ```dart
  static const int timeoutSeconds = 5;  // was 3
  ```
- Rebuild: `flutter pub get && flutter run -d windows`

**Step 3: Disable Windows Firewall temporarily** (for testing only)
```powershell
# Disable ALL firewall (warning: security risk)
netsh advfirewall set allprofiles state off

# Re-enable
netsh advfirewall set allprofiles state on
```

#### Problem: "flutter run" fails to start

**Step 1: Clean Flutter build**
```powershell
flutter clean
flutter pub get
flutter run -d windows
```

**Step 2: Verify Visual Studio Build Tools**
```powershell
flutter doctor -v
```
Look for errors. If C++ build tools missing:
- Download Visual Studio Build Tools: https://visualstudio.microsoft.com/downloads/
- Install "Desktop development with C++"

**Step 3: Update Flutter**
```powershell
flutter upgrade
```

### Performance Tips for Windows

1. **Run server in background with PM2:**
   ```powershell
   npm install -g pm2
   cd D:\NoteappMandN_holidays-main\server
   pm2 start index.js --name "mn-chat"
   pm2 startup
   pm2 save
   
   # Check status anytime
   pm2 status
   ```

2. **Increase message history**
   - Edit `server/index.js` line ~85:
     ```javascript
     return channelMessages.slice(-100);  // increase from 100
     ```

3. **Monitor server performance**
   - Keep server terminal visible
   - Watch for error messages
   - Check message frequency and user count in logs

### Production Build for Distribution

**Build standalone .exe installer:**

```powershell
# Build release version (optimized)
flutter build windows --release

# Output: D:\NoteappMandN_holidays-main\build\windows\runner\Release\noteapp.exe
```

**Create installer with MSIX (optional):**
```powershell
flutter pub add msix
flutter pub run msix:create

# Output: build\windows\runner\Release\NoteApp.msix
```

Users can then:
- Double-click `noteapp.exe` to run (portable)
- Or install `NoteApp.msix` from Microsoft Store path

### Windows Firewall Rules Summary

| Rule Name | Direction | Protocol | Port | Action |
|-----------|-----------|----------|------|--------|
| MN Chat Server TCP | Inbound | TCP | 4000 | Allow |
| MN Chat Discovery UDP | Inbound | UDP | 45454 | Allow |
| Outbound (default) | Outbound | TCP/UDP | Any | Allow |

### Administrative Deployment (for IT)

If deploying across multiple office PCs:

1. **Create Group Policy** (Windows Domain):
   - GPO → Computer Config → Windows Defender Firewall → Inbound Rules
   - Add rules for ports 4000 (TCP) and 45454 (UDP)
   - Deploy to organizational unit

2. **Package server:**
   - `server/` folder → compress to `.zip`
   - Doc: "Extract to `C:\MNChat\server\`, run `npm install` then `node index.js`"

3. **Package client:**
   - Build: `flutter build windows --release`
   - Distribute: `build/windows/runner/Release/noteapp.exe`
   - Doc: "Double-click to run; Chat tab will auto-connect"

### Support & Logs

**Enable detailed logging (development):**

Server: Already logs all events to console.

Client (Flutter): Already logs to console during `flutter run`.

**Capture logs to file:**
```powershell
# Server logs
node server/index.js > server.log 2>&1

# Flutter logs
flutter run -d windows > flutter.log 2>&1
```

---

**Ready to deploy?** Run through the Quick Start again:
1. Terminal 1: `node server/index.js` in `server/` folder
2. Terminal 2: `flutter run -d windows` in root folder
3. Click Chat tab → Connected! 🎉

**Questions?** See [SETUP_LAN_CHAT.md](SETUP_LAN_CHAT.md) or [server/README.md](server/README.md).

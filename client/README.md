# M&N Holidays Chat Client for Flutter Desktop

A real-time LAN chat client for Flutter desktop apps with auto-discovery and offline-first design. Integrates seamlessly with existing Digital Diary/Invoice Manager UI.

## Features

- **Auto-Discovery**: Finds LAN chat server automatically via UDP broadcast (no manual configuration)
- **Real-time Chat**: WebSocket-based messaging via Socket.IO (v4)
- **Presence Awareness**: See who's online in real-time
- **Typing Indicators**: Know when someone is composing a message
- **Offline Support**: Works completely on office Wi-Fi/LAN (no internet required)
- **Cross-Platform**: Windows, macOS, Linux
- **Integrated UI**: Chat tab added to existing app navigation

## Requirements

- **Flutter** 3.3.0 or later
- **Dart** 3.0 or later
- **Network**: Same office Wi-Fi/LAN as chat server

## Installation

### 1. Add Dependencies

The Flutter app's `pubspec.yaml` includes:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  riverpod: ^2.4.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.0.15
  pdf: ^3.10.1
  share_plus: ^7.2.0
  socket_io_client: ^2.0.1
  intl: ^0.19.0
```

### 2. Install Packages

```bash
cd client
flutter pub get
```

## Running the Client

### Windows

```bash
flutter run -d windows
```

### macOS

```bash
flutter run -d macos
```

### Linux

```bash
flutter run -d linux
```

## Usage

1. **Ensure server is running** on your office LAN:
   ```bash
   cd server
   node index.js
   ```

2. **Start the Flutter app**:
   ```bash
   flutter run -d windows
   ```

3. **Click the "Chat" tab** in the navigation rail

4. App will **auto-discover** the server within 3 seconds

5. **Start chatting!** Messages are live across all connected users

## File Structure

```
client/
├── pubspec.yaml                    # Dependencies
├── lib/
│   ├── main.dart                   # App entry point, routing
│   ├── chat/
│   │   ├── lan_discovery.dart      # UDP discovery service
│   │   ├── socket_service.dart     # Socket.IO client service
│   │   └── chat_screen.dart        # Chat UI
│   ├── core/                       # Existing core utilities
│   ├── data/                       # Existing data models
│   └── presentation/
│       └── screens/
│           ├── home_screen.dart    # Updated with Chat tab
│           └── invoice_screen.dart # Existing invoice UI
└── README.md
```

## Architecture

### `lan_discovery.dart`

Implements UDP broadcast discovery:
- Sends `MNCHAT_DISCOVER` to `255.255.255.255:45454`
- Waits up to 3 seconds for server response
- Returns `DiscoveredServer` with host, port, name

```dart
final server = await LANDiscovery.discover();
// DiscoveredServer(host: 192.168.1.100, port: 4000, name: 'M&N Holidays LAN Chat')
```

### `socket_service.dart`

Manages Socket.IO connection and events:
- Connects after discovery
- Emits `hello` with user name
- Joins default channel "ops"
- Handles: `presence`, `message:new`, `typing`, `message:history`

### `chat_screen.dart`

Full chat UI:
- Auto-discovers and connects on init
- Displays message list with timestamps
- Shows typing indicator
- Presence counter
- Message input with send button
- Error handling with retry

## Troubleshooting

### "No LAN chat server found"
- Verify server is running: `node server/index.js`
- Ensure both devices on **same Wi-Fi subnet**
- Check firewall allows UDP 45454 and TCP 4000
- Increase timeout in `lan_discovery.dart` if network is slow

### Messages not appearing
- Ensure you clicked "Chat" tab to trigger connection
- Check server console for `[message:create]` logs
- Verify client joined correct channel (default: "ops")

### Typing indicator not working
- Ensure Socket.IO is connected (green dot on app bar)
- Check if server received `typing` event in logs

## Windows Firewall Configuration

If running on Windows with Firewall enabled:

### Using PowerShell (Admin)

```powershell
# Allow UDP 45454 (Discovery)
netsh advfirewall firewall add rule name="MN Chat Discovery" `
  dir=in action=allow protocol=udp localport=45454 profile=any

# Allow TCP 4000 (Chat)
netsh advfirewall firewall add rule name="MN Chat Server" `
  dir=in action=allow protocol=tcp localport=4000 profile=any
```

### Using Windows Defender Firewall UI

1. Open **Windows Defender Firewall** → "Advanced Settings"
2. **Inbound Rules** → **New Rule**
3. **Port** → **UDP/TCP** → specific ports: 45454 and 4000
4. **Action**: Allow
5. **Profile**: Check all (Domain, Private, Public)

## Integration with Existing App

The chat is integrated into the app's navigation:

### `home_screen.dart` (Updated)

```dart
// NavigationRail now includes Chat destination
switch (_selectedIndex) {
  case 0:
    return InvoiceScreen(); // Invoice
  case 1:
    // Existing View/Diary screen
  case 2:
    return ChatScreen();    // NEW: Chat
}
```

### `main.dart` (Updated)

```dart
// New route for chat
'/chat': (context) => ChatScreen(),
```

## Performance & Limits

- **Message Storage**: Last 100 messages per channel (in-memory)
- **Presence**: Supports ~50+ concurrent users
- **Typing Indicator**: Updates broadcast to all users in channel
- **Message Delivery**: ~50ms latency on LAN (depends on network)

## Security Notes

- **LAN-only**: No authentication; suitable for office use only
- **No persistence**: Messages lost on server restart
- **No encryption**: LAN assumed trusted network
- **Default channel**: All clients join "ops" (single conversation)

## Future Enhancements (v2)

- Multi-channel support with UI selector
- User authentication and permissions
- Message persistence (MongoDB/PostgreSQL)
- Message reactions and threading
- Voice/video calling
- File sharing
- Rich text formatting

## License

MIT

## Support

For issues or questions, refer to the server README.md for debugging network connectivity.

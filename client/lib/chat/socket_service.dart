import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Model for user presence
class User {
  final String id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name)';
}

/// Model for chat message
class ChatMessage {
  final String id;
  final String channelId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.channelId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] as String? ?? '',
      channelId: json['channelId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? 'Unknown',
      text: json['text'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  String toString() => 'ChatMessage($id, $senderName: $text)';
}

/// Model for typing indicator
class TypingIndicator {
  final String userId;
  final String userName;
  final bool isTyping;

  TypingIndicator({
    required this.userId,
    required this.userName,
    required this.isTyping,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    return TypingIndicator(
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Someone',
      isTyping: json['isTyping'] as bool? ?? false,
    );
  }

  @override
  String toString() => 'TypingIndicator($userName, isTyping: $isTyping)';
}

/// Socket.IO chat service
///
/// Handles connection, presence, messages, and typing indicators
class SocketService {
  late IO.Socket _socket;

  // Callbacks
  Function(List<User>)? onPresenceUpdated;
  Function(ChatMessage)? onMessageReceived;
  Function(TypingIndicator)? onTypingUpdated;
  Function(List<ChatMessage>)? onMessageHistory;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(String)? onError;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  /// Get socket ID for current connection
  String? get socketId => _socket.id;

  String? _userName;
  String? _channelId;

  /// Connect to Socket.IO server
  ///
  /// Parameters:
  ///   - [host]: Server IP/hostname
  ///   - [port]: Server port (default 4000)
  ///   - [userName]: User's display name
  ///   - [channelId]: Channel to join (default "ops")
  Future<void> connect({
    required String host,
    required int port,
    required String userName,
    String channelId = 'ops',
  }) async {
    try {
      _userName = userName;
      _channelId = channelId;

      final url = 'http://$host:$port';
      print('[SocketService] Connecting to $url...');

      _socket = IO.io(
        url,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .build(),
      );

      // Set up event handlers
      _setupEventHandlers();

      // Connect
      _socket.connect();

      // Wait for connection confirmation (max 5 seconds)
      await Future.delayed(Duration(seconds: 5));
      if (!_isConnected) {
        throw Exception('Connection timeout');
      }

      print('[SocketService] Connected to Socket.IO server');
    } catch (e) {
      print('[SocketService] Connection error: $e');
      onError?.call('Failed to connect: $e');
      rethrow;
    }
  }

  /// Set up Socket.IO event handlers
  void _setupEventHandlers() {
    // Connection events
    _socket.onConnect((_) {
      print('[SocketService] Socket.IO connected');
      _isConnected = true;

      // Introduce user
      _socket.emit('hello', {'name': _userName});

      // Join channel
      if (_channelId != null) {
        _socket.emit('join', {'channelId': _channelId});
      }

      onConnected?.call();
    });

    _socket.onDisconnect((_) {
      print('[SocketService] Socket.IO disconnected');
      _isConnected = false;
      onDisconnected?.call();
    });

    // Presence event
    _socket.on('presence', (data) {
      try {
        final List<dynamic> presenceList = data as List<dynamic>? ?? [];
        final users = presenceList
            .map((item) => User.fromJson(item as Map<String, dynamic>))
            .toList();
        print('[SocketService] Presence updated: ${users.length} users online');
        onPresenceUpdated?.call(users);
      } catch (e) {
        print('[SocketService] Error parsing presence: $e');
      }
    });

    // Message history event
    _socket.on('message:history', (data) {
      try {
        final Map<String, dynamic> historyData =
            data as Map<String, dynamic>? ?? {};
        final List<dynamic> messagesList =
            historyData['messages'] as List<dynamic>? ?? [];
        final messages = messagesList
            .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
            .toList();
        print(
          '[SocketService] Message history loaded: ${messages.length} messages',
        );
        onMessageHistory?.call(messages);
      } catch (e) {
        print('[SocketService] Error parsing message history: $e');
      }
    });

    // New message event
    _socket.on('message:new', (data) {
      try {
        final Map<String, dynamic> messageData =
            data as Map<String, dynamic>? ?? {};
        final message = ChatMessage.fromJson(messageData);
        print('[SocketService] Message received: $message');
        onMessageReceived?.call(message);
      } catch (e) {
        print('[SocketService] Error parsing message: $e');
      }
    });

    // Typing indicator event
    _socket.on('typing', (data) {
      try {
        final Map<String, dynamic> typingData =
            data as Map<String, dynamic>? ?? {};
        final indicator = TypingIndicator.fromJson(typingData);
        onTypingUpdated?.call(indicator);
      } catch (e) {
        print('[SocketService] Error parsing typing indicator: $e');
      }
    });

    // Error event
    _socket.onError((_) {
      print('[SocketService] Socket.IO error');
      onError?.call('Connection error');
    });
  }

  /// Send a message to current channel
  void sendMessage(String text) {
    if (!_isConnected || _channelId == null) {
      print('[SocketService] Cannot send: not connected or no channel');
      return;
    }
    _socket.emit('message:create', {'channelId': _channelId, 'text': text});
  }

  /// Emit typing indicator
  void emitTyping(bool isTyping) {
    if (!_isConnected || _channelId == null) return;
    _socket.emit('typing', {'channelId': _channelId, 'isTyping': isTyping});
  }

  /// Disconnect from server
  void disconnect() {
    if (_isConnected) {
      print('[SocketService] Disconnecting...');
      _socket.disconnect();
      _isConnected = false;
    }
  }

  /// Close and clean up
  void dispose() {
    disconnect();
  }
}

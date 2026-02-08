import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lan_discovery.dart';
import 'socket_service.dart';

/// Chat screen with message list, typing indicator, and input
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late SocketService _socketService;
  late TextEditingController _messageController;

  // State
  List<User> _presenceList = [];
  List<ChatMessage> _messages = [];
  Map<String, bool> _typingUsers = {}; // userId -> isTyping
  bool _isLoading = true;
  bool _isConnected = false;
  String? _errorMessage;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _socketService = SocketService();
    _setupSocketCallbacks();
    _initializeConnection();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _socketService.dispose();
    super.dispose();
  }

  /// Set up Socket.IO event callbacks
  void _setupSocketCallbacks() {
    _socketService.onPresenceUpdated = (users) {
      if (!mounted) return;
      setState(() {
        _presenceList = users;
      });
    };

    _socketService.onMessageReceived = (message) {
      if (!mounted) return;
      setState(() {
        _messages.add(message);
      });
      // Scroll to bottom
      _scrollToBottom();
    };

    _socketService.onMessageHistory = (messages) {
      if (!mounted) return;
      setState(() {
        _messages = messages;
      });
      _scrollToBottom();
    };

    _socketService.onTypingUpdated = (indicator) {
      if (!mounted) return;
      setState(() {
        if (indicator.isTyping) {
          _typingUsers[indicator.userId] = true;
        } else {
          _typingUsers.remove(indicator.userId);
        }
      });
    };

    _socketService.onConnected = () {
      if (!mounted) return;
      setState(() {
        _isConnected = true;
        _isLoading = false;
        _errorMessage = null;
      });
      _showSnackbar('Connected to chat server', isError: false);
    };

    _socketService.onDisconnected = () {
      if (!mounted) return;
      setState(() {
        _isConnected = false;
      });
      _showSnackbar('Disconnected from server', isError: true);
    };

    _socketService.onError = (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error;
        _isLoading = false;
      });
      _showSnackbar(error, isError: true);
    };
  }

  /// Initialize connection: discover server, then connect
  void _initializeConnection() async {
    try {
      // Discover server
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final server = await LANDiscovery.discover();

      if (!mounted) return;

      if (server == null) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'No LAN chat server found. Ensure server is running on same Wi-Fi.';
        });
        _showSnackbar(_errorMessage!, isError: true);
        return;
      }

      // Load or generate unique persistent username
      try {
        final chatBox = Hive.box('chat');
        String? savedUsername = chatBox.get('username');

        if (savedUsername != null && savedUsername.isNotEmpty) {
          // Username already exists, reuse it
          _userName = savedUsername;
          print('[ChatScreen] ✓ Reusing existing username: $_userName');
        } else {
          // Generate new unique username (only once per device)
          _userName =
              'User-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

          // Save to Hive for permanent storage
          await chatBox.put('username', _userName);
          print('[ChatScreen] ✓ Generated and saved new username: $_userName');
        }
      } catch (e) {
        // Fallback if Hive access fails
        _userName =
            'User-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
        print('[ChatScreen] ⚠ Fallback username: $_userName, Error: $e');
      }

      // Connect to Socket.IO
      await _socketService.connect(
        host: server.host,
        port: server.port,
        userName: _userName,
        channelId: 'ops',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Connection failed: $e';
      });
      _showSnackbar('Error: $e', isError: true);
    }
  }

  /// Scroll message list to bottom
  Future<void> _scrollToBottom() async {
    await Future.delayed(Duration(milliseconds: 100));
    // ScrollController would be needed for smooth scroll
  }

  /// Show snackbar message
  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Send message
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || !_isConnected) return;

    _socketService.sendMessage(text);
    _messageController.clear();
    _socketService.emitTyping(false);
  }

  /// Handle text input changes (typing indicator)
  void _onMessageChanged(String value) {
    if (value.isNotEmpty &&
        !_typingUsers.containsKey(_socketService.socketId ?? '')) {
      _socketService.emitTyping(true);
    } else if (value.isEmpty) {
      _socketService.emitTyping(false);
    }
  }

  /// Build typing indicator text
  String _buildTypingText() {
    if (_typingUsers.isEmpty) return '';
    // In a full implementation, get actual user names from _typingUsers
    return 'Someone is typing...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo[700],
        actions: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isConnected
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    _isConnected ? 'Online' : 'Offline',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Presence bar
          if (_isConnected)
            Container(
              color: Colors.indigo[50],
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.people, size: 18, color: Colors.indigo[700]),
                  SizedBox(width: 8),
                  Text(
                    '${_presenceList.length} user${_presenceList.length != 1 ? 's' : ''} online',
                    style: TextStyle(fontSize: 12, color: Colors.indigo[700]),
                  ),
                ],
              ),
            ),

          // Loading state
          if (_isLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.indigo[700]),
                    SizedBox(height: 16),
                    Text(
                      'Discovering chat server...',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

          // Error state
          if (_errorMessage != null && !_isLoading)
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[700],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Connection Error',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _initializeConnection,
                        icon: Icon(Icons.refresh),
                        label: Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Chat messages
          if (_isConnected && !_isLoading)
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet. Start chatting!',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return _buildMessageTile(msg);
                      },
                    ),
            ),

          // Typing indicator
          if (_isConnected && _buildTypingText().isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _buildTypingText(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // Message input
          if (_isConnected)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: _onMessageChanged,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _sendMessage,
                    icon: Icon(Icons.send, size: 18),
                    label: Text('Send'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Build message tile
  Widget _buildMessageTile(ChatMessage message) {
    final isMe = message.senderName == _userName;
    final time = DateFormat('HH:mm').format(message.createdAt);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.indigo[200],
                child: Text(
                  message.senderName[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[700],
                  ),
                ),
              ),
            ),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: isMe ? Colors.indigo[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  SizedBox(height: 4),
                  Text(message.text, style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          if (isMe)
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.indigo[700],
                child: Text(
                  _userName[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

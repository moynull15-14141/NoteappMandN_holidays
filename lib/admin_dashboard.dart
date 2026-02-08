import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../chat/lan_discovery.dart';
import '../chat/server_launcher.dart';

/// Server Admin Dashboard
/// Shows server status, online users, and server information
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with WidgetsBindingObserver {
  late ServerLauncher _serverLauncher;
  Timer? _statusCheckTimer;

  bool _isConnected = false;
  String? _serverIp;
  int _serverPort = 4000;
  String _lastUpdate = '';
  bool _isCheckingServer = false;
  bool _isServerRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _serverLauncher = ServerLauncher();
    _checkServerStatus();
    _discoverServer();

    // Start periodic check every 10 seconds for server discovery
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted && _isServerRunning) {
        _discoverServer();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When returning to this page, rediscover server
    if (state == AppLifecycleState.resumed) {
      _discoverServer();
    }
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _checkServerStatus() {
    if (!mounted) return;
    setState(() {
      _isServerRunning = _serverLauncher.isRunning;
    });
  }

  void _discoverServer() async {
    if (!mounted) return;
    try {
      if (!mounted) return;
      setState(() => _isCheckingServer = true);

      final server = await LANDiscovery.discover();

      if (!mounted) return;

      if (server != null) {
        if (!mounted) return;
        setState(() {
          _serverIp = server.host;
          _serverPort = server.port;
          _lastUpdate = DateFormat('HH:mm:ss').format(DateTime.now());
          _isServerRunning = true;
          _isConnected = true; // Server is discoverable = connected
          _isCheckingServer = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isServerRunning = false;
          _isConnected = false;
          _isCheckingServer = false;
        });
        _showError('Server not found on LAN');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Discovery error: $e');
      setState(() {
        _isCheckingServer = false;
        _isConnected = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Admin Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.indigo[800],
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.greenAccent : Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isConnected ? '● Online' : '● Offline',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _discoverServer();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Server Status Card
                _buildServerStatusCard(),
                const SizedBox(height: 16),

                // Server Info Card
                _buildServerInfoCard(),
                const SizedBox(height: 16),

                // Quick Actions
                _buildQuickActionsSection(),
                const SizedBox(height: 16),

                // Online Users Card
                _buildOnlineUsersCard(),
                const SizedBox(height: 16),

                // Statistics Card
                _buildStatisticsCard(),
                const SizedBox(height: 16),

                // Server Info Details
                _buildServerDetailsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServerStatusCard() {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: _isConnected
                ? [Colors.green[400]!, Colors.green[600]!]
                : [Colors.red[400]!, Colors.red[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Server Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isConnected ? Colors.white : Colors.yellow[200],
                      boxShadow: [
                        BoxShadow(
                          color: _isConnected ? Colors.white : Colors.yellow,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _isConnected ? '🟢 ONLINE' : '🔴 OFFLINE',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              if (_lastUpdate.isNotEmpty)
                Text(
                  'Last updated: $_lastUpdate',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Server Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Server IP',
              _serverIp ?? 'Not connected',
              Icons.computer,
            ),
            const Divider(),
            _buildInfoRow('Port (TCP)', '$_serverPort', Icons.router),
            const Divider(),
            _buildInfoRow(
              'Discovery Port (UDP)',
              '45454',
              Icons.broadcast_on_home,
            ),
            const Divider(),
            _buildInfoRow(
              'Status',
              _isConnected ? 'Connected' : 'Disconnected',
              Icons.info_outline,
              statusColor: _isConnected ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: statusColor ?? Colors.indigo[700]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startServer() async {
    try {
      setState(() => _isCheckingServer = true);
      final success = await _serverLauncher.startServer();

      if (!mounted) return;

      if (success) {
        setState(() {
          _isServerRunning = true;
          _isCheckingServer = false;
        });
        _showSuccess('Server started! Waiting for it to be ready...');
        // Wait longer for server to start and bind to port
        await Future.delayed(const Duration(seconds: 3));
        _discoverServer();
      } else {
        setState(() => _isCheckingServer = false);
        _showError(_serverLauncher.lastError ?? 'Failed to start server');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCheckingServer = false);
      _showError('Error starting server: $e');
    }
  }

  void _stopServer() async {
    try {
      setState(() => _isCheckingServer = true);
      final success = await _serverLauncher.stopServer();

      if (!mounted) return;

      if (success) {
        setState(() {
          _isServerRunning = false;
          _isConnected = false;
          _isCheckingServer = false;
        });
        _showSuccess('Server stopped successfully');
      } else {
        setState(() => _isCheckingServer = false);
        _showError(_serverLauncher.lastError ?? 'Failed to stop server');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCheckingServer = false);
      _showError('Error stopping server: $e');
    }
  }

  Widget _buildQuickActionsSection() {
    return Column(
      children: [
        // Server Control Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isServerRunning || _isCheckingServer
                    ? null
                    : _startServer,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Server'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: !_isServerRunning || _isCheckingServer
                    ? null
                    : _stopServer,
                icon: const Icon(Icons.stop),
                label: const Text('Stop Server'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Connection Actions
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isCheckingServer
                    ? null
                    : () {
                        _discoverServer();
                        _showSuccess('Reconnecting...');
                      },
                icon: const Icon(Icons.refresh),
                label: const Text('Reconnect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isConnected
                    ? null
                    : () {
                        _discoverServer();
                        _showSuccess('Retrying...');
                      },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOnlineUsersCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Online Users',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Use Chat tab to see real-time users online',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    'Users Online',
                    '-',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBox(
                    'Server Status',
                    _isConnected ? 'Active' : 'Down',
                    Icons.cloud_done,
                    _isConnected ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildServerDetailsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Server Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _isConnected
                  ? 'Connected to M&N Holidays LAN Chat Server'
                  : 'Server is not connected. Check if server is running.',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'To start the server manually:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const SelectableText(
                      'cd server\nnpm install\nnode index.js',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

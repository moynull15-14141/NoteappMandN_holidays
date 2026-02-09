import 'dart:io';
import 'package:flutter/foundation.dart';

/// Manages the local LAN Chat Server process
/// Allows starting and stopping the Node.js server from the Flutter app
class ServerLauncher {
  static final ServerLauncher _instance = ServerLauncher._internal();

  Process? _serverProcess;
  int? _serverPid; // Track PID for detached processes
  bool _isRunning = false;
  String? _lastError;

  factory ServerLauncher() {
    return _instance;
  }

  ServerLauncher._internal();

  bool get isRunning => _isRunning;
  String? get lastError => _lastError;

  /// Check if server is actually running (by connecting to health endpoint)
  Future<bool> checkServerHealth() async {
    try {
      final socket = await Socket.connect(
        '127.0.0.1',
        4000,
        timeout: const Duration(seconds: 1),
      );
      socket.close();
      _isRunning = true;
      return true;
    } catch (e) {
      _isRunning = false;
      return false;
    }
  }

  /// Starts the Node.js chat server
  /// Returns true if started successfully, false otherwise
  Future<bool> startServer() async {
    try {
      if (_isRunning || await checkServerHealth()) {
        _lastError = 'Server is already running';
        return false;
      }

      // Get the server directory path
      final serverDir = _getServerDirectory();
      if (serverDir == null) {
        _lastError =
            'Server files not found.\n\n'
            'Make sure server folder is in the same directory as the app.\n'
            'Expected structure:\n'
            '  noteapp.exe\n'
            '  server/\n'
            '    index.js\n'
            '    node_modules/\n\n'
            'If you are using the portable package, extract it completely.';
        return false;
      }

      // Find Node.js executable
      final nodePath = _getNodePath();
      if (nodePath == null) {
        _lastError =
            'Node.js is not installed.\n\n'
            'Please install Node.js from: https://nodejs.org/\n'
            'Version 16 or higher recommended.';
        return false;
      }

      // Check if server directory has node_modules
      final nodeModulesDir = Directory('$serverDir\\node_modules');
      if (!nodeModulesDir.existsSync()) {
        _lastError =
            'Server dependencies not installed.\n\n'
            'Run this in PowerShell from the server folder:\n'
            'npm install\n\n'
            'Then try again.';
        return false;
      }

      // Start the server using Windows native background process
      // This is more reliable than ProcessStartMode.detached
      final batchFile = await ServerLauncher._createServerBatchFile(
        nodePath,
        serverDir,
      );
      if (batchFile == null) {
        _lastError = 'Failed to create server launcher batch file';
        return false;
      }

      // Start the batch file in the background using detached process
      _serverProcess = await Process.start(
        batchFile,
        [],
        mode: ProcessStartMode.detached,
        runInShell: true,
      );

      if (_serverProcess == null) {
        _lastError = 'Failed to start server process';
        return false;
      }

      // Store PID for later reference (detached mode)
      _serverPid = _serverProcess!.pid;

      // Wait for server to fully start and bind to port
      await Future.delayed(const Duration(seconds: 2));

      // Verify server is actually running
      if (await checkServerHealth()) {
        _isRunning = true;
        _lastError = null;
        debugPrint(
          '[Server] Started successfully on port 4000 (Detached Process PID: $_serverPid)',
        );
        return true;
      } else {
        _isRunning = false;
        _lastError =
            'Server process started but failed to respond on port 4000';
        return false;
      }
    } catch (e) {
      _isRunning = false;
      _lastError = 'Error starting server: $e';
      debugPrint(_lastError);
      return false;
    }
  }

  /// Stops the Node.js chat server
  /// Returns true if stopped successfully, false otherwise
  Future<bool> stopServer() async {
    try {
      // Kill the Node.js process running on port 4000
      // Even if app doesn't think it's running, kill the process if it exists
      try {
        final result = await Process.run('taskkill', ['/IM', 'node.exe', '/F']);

        _isRunning = false;
        _serverProcess = null;
        _serverPid = null;
        _lastError = null;

        debugPrint(
          '[Server] Stopped successfully (exit code: ${result.exitCode})',
        );

        // Verify server is actually stopped
        await Future.delayed(const Duration(milliseconds: 500));
        final stillRunning = await checkServerHealth();
        if (stillRunning) {
          _lastError = 'Server still running after stop command';
          return false;
        }

        return true;
      } catch (e) {
        _lastError = 'Error stopping server: $e';
        return false;
      }
    } catch (e) {
      _lastError = 'Error stopping server: $e';
      debugPrint(_lastError);
      return false;
    }
  }

  /// Gets the server directory path - checks multiple locations
  static String? _getServerDirectory() {
    try {
      // Priority 1: Direct ./server (development mode - running from project root)
      var serverDir = Directory('server');
      if (serverDir.existsSync() && File('server\\index.js').existsSync()) {
        debugPrint('[Server] Found at: ${serverDir.path}');
        return serverDir.path;
      }

      // Priority 2: ../server (if running from subdirectory like build/)
      serverDir = Directory('..\\server');
      if (serverDir.existsSync() && File('..\\server\\index.js').existsSync()) {
        final fullPath = Directory.current.parent.path + '\\server';
        debugPrint('[Server] Found at: $fullPath');
        return fullPath;
      }

      // Priority 3: Get executable directory from Platform (portable package)
      try {
        final exePath = Platform.resolvedExecutable;
        final exeDir = File(exePath).parent.path;
        serverDir = Directory('$exeDir\\server');
        if (serverDir.existsSync() &&
            File('$exeDir\\server\\index.js').existsSync()) {
          debugPrint(
            '[Server] Found at: ${serverDir.path} (from exe location)',
          );
          return serverDir.path;
        }
      } catch (e) {
        debugPrint('[Server] Error checking exe location: $e');
      }

      // Priority 4: One level up from current directory
      final parentPath = Directory.current.parent.path;
      serverDir = Directory('$parentPath\\server');
      if (serverDir.existsSync() &&
          File('$parentPath\\server\\index.js').existsSync()) {
        debugPrint('[Server] Found at: ${serverDir.path}');
        return serverDir.path;
      }

      debugPrint('[Server] Not found in any location');
      return null;
    } catch (e) {
      debugPrint('Error getting server directory: $e');
      return null;
    }
  }

  /// Gets server status information
  Map<String, dynamic> getServerStatus() {
    return {
      'isRunning': _isRunning,
      'lastError': _lastError,
      'port': 4000,
      'discoveryPort': 45454,
    };
  }

  /// Gets the path to Node.js executable
  static String? _getNodePath() {
    try {
      // Try common installation paths
      const paths = [
        'C:\\Program Files\\nodejs\\node.exe',
        'C:\\Program Files (x86)\\nodejs\\node.exe',
        'C:\\node-v20.14.0-win-x64\\node.exe',
        'C:\\node-v20.11.0-win-x64\\node.exe',
        'C:\\node-v20.10.0-win-x64\\node.exe',
      ];

      for (final path in paths) {
        final file = File(path);
        if (file.existsSync()) {
          return path;
        }
      }

      // Try to find in PATH using 'where' command
      try {
        final result = Process.runSync('where', ['node'], runInShell: true);
        if (result.exitCode == 0) {
          final output = (result.stdout as String).trim();
          if (output.isNotEmpty) {
            return output.split('\n').first;
          }
        }
      } catch (e) {
        debugPrint('Error checking PATH: $e');
      }

      return null;
    } catch (e) {
      debugPrint('Error getting Node.js path: $e');
      return null;
    }
  }

  /// Creates a batch file to run the server in the background
  static Future<String?> _createServerBatchFile(
    String nodePath,
    String serverDir,
  ) async {
    try {
      final tempDir = Directory.systemTemp;
      final batchFile = File('${tempDir.path}\\mn_chat_server_start.bat');

      // Create batch file that runs Node.js server
      // Using START /MIN to minimize window, allowing background execution
      final batchContent =
          '''@echo off
setlocal enabledelayedexpansion
cd /d "$serverDir"
echo [MN Chat] Starting Node.js Server on port 4000...
start /MIN cmd /c "$nodePath" index.js
exit /b 0
''';

      await batchFile.writeAsString(batchContent);
      debugPrint('[Server] Batch file created at ${batchFile.path}');
      return batchFile.path;
    } catch (e) {
      debugPrint('Error creating batch file: $e');
      return null;
    }
  }
}

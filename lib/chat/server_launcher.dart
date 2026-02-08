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

  /// Starts the Node.js chat server
  /// Returns true if started successfully, false otherwise
  Future<bool> startServer() async {
    try {
      if (_isRunning) {
        _lastError = 'Server is already running';
        return false;
      }

      // Get the server directory path
      final serverDir = _getServerDirectory();
      if (serverDir == null) {
        _lastError =
            'Server files not found. Make sure /server directory exists.';
        return false;
      }

      // Find Node.js executable
      final nodePath = _getNodePath();
      if (nodePath == null) {
        _lastError =
            'Node.js is not installed. Please install from https://nodejs.org/';
        return false;
      }

      // Check if server directory has node_modules
      final nodeModulesDir = Directory('$serverDir\\node_modules');
      if (!nodeModulesDir.existsSync()) {
        _lastError =
            'Dependencies not installed. Run "npm install" in /server directory first.';
        return false;
      }

      // Start the server using Windows native background process
      // This is more reliable than ProcessStartMode.detached
      final batchFile = await ServerLauncher._createServerBatchFile(
        nodePath,
        serverDir,
      );
      if (batchFile == null) {
        _lastError = 'Failed to create batch file for server';
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

      _isRunning = true;
      _lastError = null;

      debugPrint(
        '[Server] Started successfully on port 4000 (Detached Process PID: $_serverPid)',
      );
      return true;
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
      if (!_isRunning) {
        _lastError = 'Server is not running';
        return false;
      }

      // Kill the Node.js process running on port 4000
      // Since we're running a detached process, we kill by process name
      try {
        final result = await Process.run('taskkill', ['/IM', 'node.exe', '/F']);

        _isRunning = false;
        _serverProcess = null;
        _serverPid = null;
        _lastError = null;

        debugPrint(
          '[Server] Stopped successfully (exit code: ${result.exitCode})',
        );
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

  /// Gets the server directory path
  static String? _getServerDirectory() {
    try {
      // Get current working directory
      final currentDir = Directory.current;

      // Try to find /server directory
      final serverDir = Directory('${currentDir.path}\\server');
      if (serverDir.existsSync()) {
        return serverDir.path;
      }

      // Try parent directory (in case app is running from subdirectory)
      final parentServerDir = Directory('${currentDir.parent.path}\\server');
      if (parentServerDir.existsSync()) {
        return parentServerDir.path;
      }

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

import 'dart:io';
import 'dart:async';
import 'dart:convert';

/// Model for discovered server information
class DiscoveredServer {
  final String host;
  final int port;
  final String name;

  DiscoveredServer({
    required this.host,
    required this.port,
    required this.name,
  });

  /// Parse JSON response from UDP discovery
  factory DiscoveredServer.fromJson(Map<String, dynamic> json) {
    return DiscoveredServer(
      host: json['host'] as String? ?? 'localhost',
      port: json['port'] as int? ?? 4000,
      name: json['name'] as String? ?? 'M&N Holidays LAN Chat',
    );
  }

  @override
  String toString() =>
      'DiscoveredServer(host: $host, port: $port, name: $name)';
}

/// UDP-based LAN server discovery
///
/// Broadcasts "MNCHAT_DISCOVER" to 255.255.255.255:45454
/// Waits for response with JSON: { host, port, name }
class LANDiscovery {
  static const String discoveryMessage = 'MNCHAT_DISCOVER';
  static const int discoveryPort = 45454;
  static const int timeoutSeconds = 3;

  /// Perform LAN discovery via UDP broadcast
  ///
  /// Returns [DiscoveredServer] if found, null if timeout
  /// Throws [SocketException] on network errors
  static Future<DiscoveredServer?> discover() async {
    RawDatagramSocket? socket;
    try {
      // Create UDP socket
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;

      // Prepare discovery message
      final message = utf8.encode(discoveryMessage);
      final broadcastAddress = InternetAddress('255.255.255.255');

      // Send broadcast
      print('[LANDiscovery] Sending MNCHAT_DISCOVER broadcast...');
      socket.send(message, broadcastAddress, discoveryPort);

      // Wait for response with timeout
      final completer = Completer<DiscoveredServer?>();
      late StreamSubscription subscription;

      final timeoutTimer = Timer(Duration(seconds: timeoutSeconds), () {
        if (!completer.isCompleted) {
          subscription.cancel();
          completer.complete(null);
          print(
            '[LANDiscovery] Discovery timeout after $timeoutSeconds seconds',
          );
        }
      });

      subscription = socket.asBroadcastStream().listen(
        (RawSocketEvent event) {
          if (event == RawSocketEvent.read && !completer.isCompleted) {
            try {
              final datagram = socket!.receive();
              if (datagram == null) return;

              final response = utf8.decode(datagram.data);
              final json = jsonDecode(response) as Map<String, dynamic>;
              final server = DiscoveredServer.fromJson(json);

              timeoutTimer.cancel();
              subscription.cancel();
              completer.complete(server);

              print('[LANDiscovery] Server discovered: $server');
            } catch (e) {
              print('[LANDiscovery] Error parsing response: $e');
            }
          }
        },
        onError: (error) {
          if (!completer.isCompleted) {
            timeoutTimer.cancel();
            completer.completeError(error);
          }
        },
      );

      return await completer.future;
    } catch (e) {
      print('[LANDiscovery] Fatal error: $e');
      rethrow;
    } finally {
      socket?.close();
    }
  }
}

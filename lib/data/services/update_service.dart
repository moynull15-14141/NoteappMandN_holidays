import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform, ProcessException;

/// Custom, thread-safe update checking service for Flutter Windows apps.
/// Avoids platform channel threading issues by using HTTP directly.
class UpdateService {
  static const String feedURL =
      'https://raw.githubusercontent.com/moynull15-14141/NoteappMandN_holidays/main/appcast.xml';

  /// Check for app updates (thread-safe, runs on background isolate)
  static Future<UpdateInfo?> checkForUpdates({
    required String currentVersion,
  }) async {
    try {
      // Only check for updates on desktop platforms
      if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
        debugPrint('Update check skipped: Not on desktop platform');
        return null;
      }

      debugPrint('Checking for updates from: $feedURL');

      // Fetch the appcast XML file
      final response = await http
          .get(Uri.parse(feedURL))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Update check timed out after 10 seconds');
            },
          );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch appcast: ${response.statusCode}');
      }

      // Parse the XML response
      final document = xml.XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      if (items.isEmpty) {
        debugPrint('No update items found in appcast');
        return null;
      }

      // Get the latest version from the first item
      final latestItem = items.first;
      final versionElement = latestItem.findElements('version').firstOrNull;
      final descriptionElement = latestItem
          .findElements('description')
          .firstOrNull;
      final pubDateElement = latestItem.findElements('pubDate').firstOrNull;

      if (versionElement == null) {
        debugPrint('No version found in appcast item');
        return null;
      }

      final latestVersion = versionElement.innerText.trim();

      // Compare versions
      if (_isNewerVersion(latestVersion, currentVersion)) {
        return UpdateInfo(
          version: latestVersion,
          description: descriptionElement?.innerText ?? 'New version available',
          pubDate: pubDateElement?.innerText ?? '',
        );
      }

      debugPrint(
        'No new update available. Current: $currentVersion, Latest: $latestVersion',
      );
      return null;
    } on TimeoutException catch (e) {
      debugPrint('Update check timeout: $e');
      return null;
    } on ProcessException catch (e) {
      debugPrint('Platform error during update check: $e');
      return null;
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return null;
    }
  }

  /// Compare version strings (simple semantic versioning)
  /// Returns true if newVersion > currentVersion
  static bool _isNewerVersion(String newVersion, String currentVersion) {
    try {
      final newParts = newVersion
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      final currentParts = currentVersion
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

      // Pad with zeros if lengths differ
      while (newParts.length < currentParts.length) {
        newParts.add(0);
      }
      while (currentParts.length < newParts.length) {
        currentParts.add(0);
      }

      // Compare major.minor.patch
      for (int i = 0; i < newParts.length; i++) {
        if (newParts[i] > currentParts[i]) return true;
        if (newParts[i] < currentParts[i]) return false;
      }

      return false;
    } catch (e) {
      debugPrint('Error comparing versions: $e');
      return false;
    }
  }
}

/// Model to hold update information
class UpdateInfo {
  final String version;
  final String description;
  final String pubDate;

  UpdateInfo({
    required this.version,
    required this.description,
    required this.pubDate,
  });

  @override
  String toString() =>
      'UpdateInfo(version: $version, description: $description)';
}

/// Custom timeout exception
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

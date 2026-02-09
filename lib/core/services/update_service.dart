import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for checking and managing app updates
class UpdateService {
  static const String _GITHUB_REPO = 'moynull15-14141/NoteappMandN_holidays';
  static const String _GITHUB_API_URL =
      'https://api.github.com/repos/$_GITHUB_REPO/releases/latest';
  static const String _CURRENT_VERSION =
      '1.0.2'; // Update this with your version

  /// Check if a new version is available on GitHub
  static Future<Map<String, dynamic>?> checkForUpdates() async {
    try {
      debugPrint('[UpdateService] Checking for updates...');

      final response = await http
          .get(
            Uri.parse(_GITHUB_API_URL),
            headers: {'Accept': 'application/vnd.github.v3+json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final latestVersion = data['tag_name'] as String? ?? '';
        final changelog = data['body'] as String? ?? 'No changelog available';
        final downloadUrl = _findWindowsDownloadUrl(data);

        debugPrint('[UpdateService] Latest version: $latestVersion');
        debugPrint('[UpdateService] Current version: $_CURRENT_VERSION');

        final hasUpdate = _isNewerVersion(latestVersion, _CURRENT_VERSION);

        if (hasUpdate && downloadUrl != null) {
          return {
            'hasUpdate': true,
            'currentVersion': _CURRENT_VERSION,
            'latestVersion': latestVersion,
            'changelog': changelog,
            'downloadUrl': downloadUrl,
          };
        }

        return {
          'hasUpdate': false,
          'currentVersion': _CURRENT_VERSION,
          'latestVersion': latestVersion,
        };
      } else {
        debugPrint(
          '[UpdateService] Failed to check updates: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('[UpdateService] Error checking updates: $e');
      return null;
    }
  }

  /// Find Windows download URL from release assets
  static String? _findWindowsDownloadUrl(Map<String, dynamic> data) {
    try {
      final assets = data['assets'] as List?;
      if (assets != null) {
        for (final asset in assets) {
          final name = asset['name'] as String?;
          final downloadUrl = asset['browser_download_url'] as String?;

          if (name != null && downloadUrl != null) {
            // Look for Windows exe
            if (name.contains('noteapp') && name.endsWith('.exe')) {
              return downloadUrl;
            }
            // Fallback: any exe file
            if (name.endsWith('.exe')) {
              return downloadUrl;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[UpdateService] Error parsing assets: $e');
    }
    return null;
  }

  /// Compare versions (e.g., "v1.0.2" vs "1.0.1")
  /// Returns true if newVersion > currentVersion
  static bool _isNewerVersion(String newVersion, String currentVersion) {
    try {
      // Remove 'v' prefix if present
      final new_ = newVersion.replaceFirst(RegExp(r'^v'), '');
      final current = currentVersion.replaceFirst(RegExp(r'^v'), '');

      final newParts = new_.split('.').map(int.parse).toList();
      final currentParts = current.split('.').map(int.parse).toList();

      // Pad with zeros to match lengths
      while (newParts.length < currentParts.length) {
        newParts.add(0);
      }
      while (currentParts.length < newParts.length) {
        currentParts.add(0);
      }

      for (int i = 0; i < newParts.length; i++) {
        if (newParts[i] > currentParts[i]) return true;
        if (newParts[i] < currentParts[i]) return false;
      }

      return false; // Versions are equal
    } catch (e) {
      debugPrint('[UpdateService] Error comparing versions: $e');
      return false;
    }
  }

  /// Download app update
  static Future<File?> downloadUpdate(String downloadUrl) async {
    try {
      debugPrint('[UpdateService] Downloading update from: $downloadUrl');

      final response = await http
          .get(Uri.parse(downloadUrl))
          .timeout(const Duration(minutes: 5));

      if (response.statusCode == 200) {
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}\\noteapp_update.exe');

        await file.writeAsBytes(response.bodyBytes);
        debugPrint('[UpdateService] Update downloaded to: ${file.path}');

        return file;
      } else {
        debugPrint('[UpdateService] Download failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('[UpdateService] Error downloading update: $e');
      return null;
    }
  }

  /// Open GitHub releases page in browser
  static Future<void> openGitHubReleases() async {
    final url = 'https://github.com/$_GITHUB_REPO/releases';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[UpdateService] Error opening URL: $e');
    }
  }

  /// Get current version
  static String getCurrentVersion() => _CURRENT_VERSION;
}

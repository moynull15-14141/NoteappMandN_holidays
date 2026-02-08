import 'package:hive/hive.dart';
import 'package:noteapp/core/constants/app_constants.dart';
import 'package:noteapp/core/utils/exceptions.dart';
import 'package:noteapp/data/models/diary_entry_model.dart';
import 'package:noteapp/data/models/settings_model.dart';

// Conditional imports for platform-specific features
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

// Only import path_provider on non-web platforms
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;
import 'dart:io' show Directory;
import 'dart:async' show Future;

abstract class LocalDataSource {
  Future<void> initializeBoxes();

  // Diary Entries
  Future<void> saveDiaryEntry(DiaryEntryModel entry);
  Future<DiaryEntryModel?> getDiaryEntry(String id);
  Future<List<DiaryEntryModel>> getAllDiaryEntries();
  Future<void> deleteDiaryEntry(String id);
  Future<void> updateDiaryEntry(DiaryEntryModel entry);
  Future<List<DiaryEntryModel>> searchDiaryEntries(String query);
  Future<List<DiaryEntryModel>> getFavoriteDiaryEntries();

  // Settings
  Future<void> saveSettings(SettingsModel settings);
  Future<SettingsModel?> getSettings();

  // Statistics
  Future<int> getTotalEntriesCount();
}

class LocalDataSourceImpl implements LocalDataSource {
  late Box<DiaryEntryModel> _diaryBox;
  late Box<SettingsModel> _settingsBox;
  bool _isInitialized = false;

  /// Retry logic with exponential backoff for Hive lock conflicts
  Future<T> _retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(milliseconds: 100),
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        final errorStr = e.toString().toLowerCase();

        // Only retry on lock-related errors
        if (errorStr.contains('lock') ||
            errorStr.contains('locked') ||
            errorStr.contains('access')) {
          if (attempt < maxAttempts) {
            debugPrint(
              'Hive lock conflict (attempt $attempt/$maxAttempts). Retrying in ${delay.inMilliseconds}ms...',
            );
            await Future.delayed(delay);
            delay = Duration(
              milliseconds: delay.inMilliseconds * 2,
            ); // Exponential backoff
          } else {
            rethrow;
          }
        } else {
          rethrow;
        }
      }
    }

    throw Exception('Failed after $maxAttempts attempts');
  }

  @override
  Future<void> initializeBoxes() async {
    // Prevent multiple initialization attempts
    if (_isInitialized) {
      debugPrint('Hive boxes already initialized, skipping...');
      return;
    }

    try {
      // Only use custom path on native platforms (not web)
      if (!kIsWeb) {
        // Use local app data directory instead of OneDrive (desktop/mobile only)
        final appDataDir = await getApplicationSupportDirectory();
        final hiveDir = Directory('${appDataDir.path}\\hive');

        // Create the directory if it doesn't exist
        if (!hiveDir.existsSync()) {
          hiveDir.createSync(recursive: true);
        }

        // Initialize Hive with the custom path
        Hive.init(hiveDir.path);
        debugPrint('Hive initialized at: ${hiveDir.path}');
      }
      // On web, Hive will use IndexedDB automatically without explicit path initialization

      // Open boxes with retry logic to handle lock conflicts
      _diaryBox = await _retryWithBackoff(
        () => Hive.openBox<DiaryEntryModel>(AppConstants.diaryEntriesBox),
      );
      debugPrint('Diary box opened successfully');

      _settingsBox = await _retryWithBackoff(
        () => Hive.openBox<SettingsModel>(AppConstants.settingsBox),
      );
      debugPrint('Settings box opened successfully');

      _isInitialized = true;
      debugPrint('Hive initialization complete');
    } catch (e) {
      debugPrint('Hive initialization error: $e');
      throw StorageException(
        message: 'Failed to initialize storage: $e',
        code: 'STORAGE_INIT_ERROR',
      );
    }
  }

  @override
  Future<void> saveDiaryEntry(DiaryEntryModel entry) async {
    try {
      await _retryWithBackoff(() => _diaryBox.put(entry.id, entry));
    } catch (e) {
      throw StorageException(
        message: 'Failed to save diary entry: $e',
        code: 'SAVE_ENTRY_ERROR',
      );
    }
  }

  @override
  Future<DiaryEntryModel?> getDiaryEntry(String id) async {
    try {
      return await _retryWithBackoff(() => Future.value(_diaryBox.get(id)));
    } catch (e) {
      throw StorageException(
        message: 'Failed to retrieve diary entry: $e',
        code: 'GET_ENTRY_ERROR',
      );
    }
  }

  @override
  Future<List<DiaryEntryModel>> getAllDiaryEntries() async {
    try {
      final entries = await _retryWithBackoff(
        () => Future.value(_diaryBox.values.toList()),
      );
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entries;
    } catch (e) {
      throw StorageException(
        message: 'Failed to retrieve diary entries: $e',
        code: 'GET_ENTRIES_ERROR',
      );
    }
  }

  @override
  Future<void> deleteDiaryEntry(String id) async {
    try {
      await _retryWithBackoff(() => _diaryBox.delete(id));
    } catch (e) {
      throw StorageException(
        message: 'Failed to delete diary entry: $e',
        code: 'DELETE_ENTRY_ERROR',
      );
    }
  }

  @override
  Future<void> updateDiaryEntry(DiaryEntryModel entry) async {
    try {
      await _retryWithBackoff(() => _diaryBox.put(entry.id, entry));
    } catch (e) {
      throw StorageException(
        message: 'Failed to update diary entry: $e',
        code: 'UPDATE_ENTRY_ERROR',
      );
    }
  }

  @override
  Future<List<DiaryEntryModel>> searchDiaryEntries(String query) async {
    try {
      final queryLower = query.toLowerCase();
      final entries = await _retryWithBackoff(
        () => Future.value(
          _diaryBox.values.where((entry) {
            return entry.title.toLowerCase().contains(queryLower) ||
                entry.body.toLowerCase().contains(queryLower) ||
                entry.tags.any((tag) => tag.toLowerCase().contains(queryLower));
          }).toList(),
        ),
      );

      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entries;
    } catch (e) {
      throw StorageException(
        message: 'Failed to search diary entries: $e',
        code: 'SEARCH_ERROR',
      );
    }
  }

  @override
  Future<List<DiaryEntryModel>> getFavoriteDiaryEntries() async {
    try {
      final favorites = await _retryWithBackoff(
        () => Future.value(
          _diaryBox.values.where((entry) => entry.isFavorite).toList(),
        ),
      );

      favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return favorites;
    } catch (e) {
      throw StorageException(
        message: 'Failed to retrieve favorite entries: $e',
        code: 'GET_FAVORITES_ERROR',
      );
    }
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    try {
      await _retryWithBackoff(() => _settingsBox.put('settings', settings));
    } catch (e) {
      throw StorageException(
        message: 'Failed to save settings: $e',
        code: 'SAVE_SETTINGS_ERROR',
      );
    }
  }

  @override
  Future<SettingsModel?> getSettings() async {
    try {
      return await _retryWithBackoff(
        () => Future.value(_settingsBox.get('settings')),
      );
    } catch (e) {
      throw StorageException(
        message: 'Failed to retrieve settings: $e',
        code: 'GET_SETTINGS_ERROR',
      );
    }
  }

  @override
  Future<int> getTotalEntriesCount() async {
    try {
      return await _retryWithBackoff(() => Future.value(_diaryBox.length));
    } catch (e) {
      throw StorageException(
        message: 'Failed to get entries count: $e',
        code: 'COUNT_ERROR',
      );
    }
  }
}

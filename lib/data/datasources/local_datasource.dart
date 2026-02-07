import 'package:hive/hive.dart';
import 'package:noteapp/core/constants/app_constants.dart';
import 'package:noteapp/core/utils/exceptions.dart';
import 'package:noteapp/data/models/diary_entry_model.dart';
import 'package:noteapp/data/models/settings_model.dart';

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

  @override
  Future<void> initializeBoxes() async {
    try {
      _diaryBox = await Hive.openBox<DiaryEntryModel>(
        AppConstants.diaryEntriesBox,
      );
      _settingsBox = await Hive.openBox<SettingsModel>(
        AppConstants.settingsBox,
      );
    } catch (e) {
      throw StorageException(
        message: 'Failed to initialize storage: $e',
        code: 'STORAGE_INIT_ERROR',
      );
    }
  }

  @override
  Future<void> saveDiaryEntry(DiaryEntryModel entry) async {
    try {
      await _diaryBox.put(entry.id, entry);
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
      return _diaryBox.get(id);
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
      final entries = _diaryBox.values.toList();
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
      await _diaryBox.delete(id);
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
      await _diaryBox.put(entry.id, entry);
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
      final entries = _diaryBox.values.where((entry) {
        return entry.title.toLowerCase().contains(queryLower) ||
            entry.body.toLowerCase().contains(queryLower) ||
            entry.tags.any((tag) => tag.toLowerCase().contains(queryLower));
      }).toList();

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
      final favorites = _diaryBox.values
          .where((entry) => entry.isFavorite)
          .toList();

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
      await _settingsBox.put('settings', settings);
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
      return _settingsBox.get('settings');
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
      return _diaryBox.length;
    } catch (e) {
      throw StorageException(
        message: 'Failed to get entries count: $e',
        code: 'COUNT_ERROR',
      );
    }
  }
}

import 'package:noteapp/data/datasources/local_datasource.dart';
import 'package:noteapp/data/models/diary_entry_model.dart';
import 'package:noteapp/data/models/settings_model.dart';

abstract class DiaryRepository {
  Future<void> saveDiaryEntry(DiaryEntryModel entry);
  Future<DiaryEntryModel?> getDiaryEntry(String id);
  Future<List<DiaryEntryModel>> getAllDiaryEntries();
  Future<void> deleteDiaryEntry(String id);
  Future<void> updateDiaryEntry(DiaryEntryModel entry);
  Future<List<DiaryEntryModel>> searchDiaryEntries(String query);
  Future<List<DiaryEntryModel>> getFavoriteDiaryEntries();
  Future<int> getTotalEntriesCount();
}

class DiaryRepositoryImpl implements DiaryRepository {
  final LocalDataSource localDataSource;

  DiaryRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveDiaryEntry(DiaryEntryModel entry) =>
      localDataSource.saveDiaryEntry(entry);

  @override
  Future<DiaryEntryModel?> getDiaryEntry(String id) =>
      localDataSource.getDiaryEntry(id);

  @override
  Future<List<DiaryEntryModel>> getAllDiaryEntries() =>
      localDataSource.getAllDiaryEntries();

  @override
  Future<void> deleteDiaryEntry(String id) =>
      localDataSource.deleteDiaryEntry(id);

  @override
  Future<void> updateDiaryEntry(DiaryEntryModel entry) =>
      localDataSource.updateDiaryEntry(entry);

  @override
  Future<List<DiaryEntryModel>> searchDiaryEntries(String query) =>
      localDataSource.searchDiaryEntries(query);

  @override
  Future<List<DiaryEntryModel>> getFavoriteDiaryEntries() =>
      localDataSource.getFavoriteDiaryEntries();

  @override
  Future<int> getTotalEntriesCount() => localDataSource.getTotalEntriesCount();
}

abstract class SettingsRepository {
  Future<void> saveSettings(SettingsModel settings);
  Future<SettingsModel?> getSettings();
}

class SettingsRepositoryImpl implements SettingsRepository {
  final LocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveSettings(SettingsModel settings) =>
      localDataSource.saveSettings(settings);

  @override
  Future<SettingsModel?> getSettings() => localDataSource.getSettings();
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noteapp/data/datasources/local_datasource.dart';
import 'package:noteapp/data/models/settings_model.dart';
import 'package:noteapp/data/repositories/repositories.dart';

// Hive & DataSources
final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSourceImpl();
});

// Repositories
final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  final dataSource = ref.watch(localDataSourceProvider);
  return DiaryRepositoryImpl(localDataSource: dataSource);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dataSource = ref.watch(localDataSourceProvider);
  return SettingsRepositoryImpl(localDataSource: dataSource);
});

// Settings State
final settingsProvider = FutureProvider<SettingsModel?>((ref) async {
  try {
    final repository = ref.watch(settingsRepositoryProvider);
    final settings = await repository.getSettings();
    return settings ??
        SettingsModel(
          pinCode: null,
          isDarkTheme: false,
          autoLockDurationMinutes: 5,
          lastAuthTime: null,
        );
  } catch (e) {
    // Return default settings if error occurs
    return SettingsModel(
      pinCode: null,
      isDarkTheme: false,
      autoLockDurationMinutes: 5,
      lastAuthTime: null,
    );
  }
});

// Theme Provider
final themeProvider = StateProvider<bool>((ref) {
  return false; // false = light, true = dark
});

// Auto-lock Provider
final isAuthenticatedProvider = StateProvider<bool>((ref) {
  return false;
});

final lastAuthTimeProvider = StateProvider<DateTime?>((ref) {
  return null;
});

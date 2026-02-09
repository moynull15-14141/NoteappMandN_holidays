class AppConstants {
  // App Info
  static const String appName = 'Digital Diary';
  static const String appVersion = '1.0.2';

  // Hive Box Names
  static const String diaryEntriesBox = 'diary_entries';
  static const String settingsBox = 'settings';
  static const String favoritesBox = 'favorites';

  // Preferences Keys
  static const String pinCodeKey = 'pin_code';
  static const String themeKey = 'theme_dark';
  static const String isAuthenticatedKey = 'is_authenticated';
  static const String lastAuthTimeKey = 'last_auth_time';
  static const String autoLockDurationKey = 'auto_lock_duration';

  // Mood Emojis
  static const Map<String, String> moodEmojis = {
    'amazing': '🤩',
    'happy': '😊',
    'good': '👍',
    'neutral': '😐',
    'sad': '😢',
    'angry': '😠',
    'tired': '😴',
    'excited': '🎉',
  };

  // Auto-lock duration in minutes
  static const int autoLockDurationMinutes = 15;

  // Image constraints
  static const int maxImageSizeBytes = 5242880; // 5MB
  static const int maxImagesPerEntry = 5;

  // Search limit
  static const int searchResultsLimit = 100;
}

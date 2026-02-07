# Digital Diary - Production-Ready Flutter Application

A fully-featured, cross-platform digital diary application built with Flutter, optimized for Windows Desktop but also compatible with Android, iOS, and Web platforms.

## Features

### ✨ Core Features
- **📝 Diary Entries**: Create rich diary entries with title, body, and timestamps
- **🎭 Mood Tracking**: Select from 8 different moods (Amazing, Happy, Good, Neutral, Sad, Angry, Tired, Excited)
- **📷 Image Attachments**: Attach up to 5 images per entry (max 5MB each)
- **🏷️ Tags System**: Organize entries with custom tags
- **❤️ Favorites**: Bookmark favorite entries for quick access
- **🔍 Advanced Search**: Full-text search across titles, bodies, and tags

### 🔒 Security
- **PIN Protection**: 6-digit PIN code to unlock the diary
- **Local-First Storage**: All data stored locally using Hive database
- **Auto-Lock**: Automatic locking after inactivity
- **No Cloud Sync**: Privacy-focused, completely offline

### 📊 Organization & Export
- **Search & Filter**: Powerful search functionality
- **Date Organization**: View entries by date
- **Export Options**: JSON and PDF export for backup and sharing
- **Statistics**: View total number of entries

### 🎨 User Experience
- **Light & Dark Themes**: Toggle between beautiful light and dark modes
- **Responsive Design**: Desktop sidebar + mobile bottom navigation
- **Adaptive Layouts**: LayoutBuilder for all screen sizes
- **Smooth Animations**: Polished UI transitions

### 💾 Data Management
- **Hive Database**: Fast, local NoSQL storage
- **Persistent Storage**: All data saved locally on device
- **Backup & Restore**: Export/Import functionality

---

## Project Structure

```
noteapp/
├── lib/
│   ├── core/
│   │   ├── config/
│   │   │   └── app_themes.dart
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   └── utils/
│   │       ├── datetime_helper.dart
│   │       └── exceptions.dart
│   ├── data/
│   │   ├── datasources/
│   │   │   └── local_datasource.dart
│   │   ├── models/
│   │   │   ├── diary_entry_model.dart
│   │   │   └── settings_model.dart
│   │   ├── repositories/
│   │   │   └── repositories.dart
│   │   └── services/
│   │       ├── image_service.dart
│   │       └── export_service.dart
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── app_providers.dart
│   │   │   ├── auth_provider.dart
│   │   │   └── diary_providers.dart
│   │   ├── screens/
│   │   │   ├── authentication_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── diary_entry_screen.dart
│   │   │   ├── entry_detail_screen.dart
│   │   │   ├── search_screen.dart
│   │   │   └── settings_screen.dart
│   │   └── widgets/
│   │       ├── mood_selector.dart
│   │       ├── image_grid_view.dart
│   │       └── pin_input_dialog.dart
│   └── main.dart
├── pubspec.yaml
└── README.md
```

---

## Architecture

**Clean Architecture** with three layers:

1. **Data Layer**: Models, DataSources, Repositories, Services
2. **Domain Layer**: Business logic through repository interfaces
3. **Presentation Layer**: Riverpod providers, Screens, Widgets

**State Management**: Flutter Riverpod for efficient, reactive state handling

---

## Setup & Installation

### Prerequisites
- Flutter SDK >= 3.10.8
- Dart SDK >= 3.10.8
- Windows 10/11, Android Studio, or Xcode

### Quick Start

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate Hive adapters (IMPORTANT!)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Run the app
flutter run

# 4. Run on Windows desktop
flutter run -d windows
```

---

## Windows Desktop Setup

### Build Windows App
```bash
flutter build windows --release
```

### Windows Features
- Sidebar navigation
- Window resizing support
- Full keyboard support
- Optimized for larger screens

---

## Dependencies

**Core State & Database**
- `flutter_riverpod` - State management
- `hive_flutter` - Local NoSQL database
- `intl` - Date/time utilities

**UI & Media**
- `flutter_svg` - SVG support
- `image_picker` - Image selection
- `pdf` - PDF generation

**Security & Utilities**
- `encrypt` - Encryption utilities
- `local_auth` - Biometric authentication (future)
- `uuid` - Unique ID generation

**Dev Tools**
- `build_runner` - Code generation
- `hive_generator` - Hive adapters
- `riverpod_generator` - Riverpod code generation

---

## Database Schema

**DiaryEntryModel** (@HiveType typeId: 0)
- `id`: String (Unique ID)
- `title`: String
- `body`: String
- `createdAt`: DateTime
- `updatedAt`: DateTime
- `mood`: String (emoji)
- `imagePaths`: List<String>
- `isFavorite`: bool
- `tags`: List<String>

**SettingsModel** (@HiveType typeId: 1)
- `pinCode`: String?
- `isDarkTheme`: bool
- `autoLockDurationMinutes`: int
- `lastAuthTime`: DateTime?

---

## Key Features Implementation

### PIN Authentication
```dart
await ref.read(authProvider.notifier).authenticate(pinCode);
```

### Search Entries
```dart
ref.read(searchQueryProvider.notifier).state = "search term";
final results = ref.watch(searchResultsProvider);
```

### Save Entry
```dart
await repository.saveDiaryEntry(entry);
ref.invalidate(diaryEntriesProvider);
```

### Export Data
```dart
await ExportService.exportAsJSON(entries);
await ExportService.exportAsPDF(entries);
```

---

## Performance Optimizations
- Hive for fast local storage
- Riverpod caching and invalidation
- Image compression (85% quality)
- Responsive layout with LayoutBuilder

---

## Security
- PIN-protected diary
- Offline-first (no cloud sync)
- Local storage only
- Encryption-ready architecture

---

## Troubleshooting

**Hive adapters not found?**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Windows build fails?**
```bash
flutter clean && flutter pub get && flutter run -d windows
```

**Image picker issues?**
- Android: Check AndroidManifest.xml permissions
- iOS: Check Info.plist permissions

---

## Future Enhancements
- Biometric authentication
- Cloud sync with encryption
- Rich text editor
- Voice-to-text
- Monthly statistics
- Custom themes
- Notifications
- Sharing features

---

## License

This project is provided for personal use.

---

## Technical Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter |
| Language | Dart |
| State Management | Riverpod |
| Database | Hive |
| Architecture | Clean Architecture |
| Theme | Material Design 3 |
| Export | JSON, PDF |

---

**Built with ❤️ using Flutter**
**Version**: 1.0.0
**Last Updated**: February 2026

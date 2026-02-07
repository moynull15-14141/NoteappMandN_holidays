# 🚀 Digital Diary - Quick Reference Guide

## Command Cheat Sheet

### Initial Setup
```bash
flutter pub get                                      # Install dependencies
flutter pub run build_runner build --delete-conflicting-outputs  # Generate code
```

### Running the App
```bash
flutter run -d windows                             # Windows desktop
flutter run -d android                             # Android
flutter run -d ios                                 # iOS
flutter run -d chrome                              # Web
flutter run                                        # Default device
```

### Development
```bash
flutter run -d windows --verbose                   # With verbose logging
flutter run --debug                                # Debug mode
flutter run --profile                              # Profile mode (performance)
flutter run --release                              # Release mode (optimized)
```

### Code Generation
```bash
flutter pub run build_runner build --delete-conflicting-outputs  # One-time
flutter pub run build_runner watch                 # Auto-regenerate on changes
```

### Maintenance
```bash
flutter clean                                      # Remove build artifacts
flutter pub get                                    # Reinstall dependencies
flutter doctor                                     # Check environment
flutter doctor -v                                  # Verbose environment check
```

### Building for Distribution
```bash
flutter build windows --release                    # Windows installer
flutter build apk --release                        # Android APK
flutter build appbundle --release                  # Android App Bundle
flutter build ios --release                        # iOS app
flutter build web --release                        # Web app
```

---

## Project Structure Quick Map

```
noteapp/
├── lib/
│   ├── main.dart                 🎯 Start here - App entry point
│   ├── core/
│   │   ├── config/app_themes.dart        Light & Dark themes
│   │   ├── constants/app_constants.dart  App constants
│   │   └── utils/
│   │       ├── datetime_helper.dart      Date utilities
│   │       └── exceptions.dart           Custom exceptions
│   ├── data/
│   │   ├── datasources/local_datasource.dart   Database operations
│   │   ├── models/
│   │   │   ├── diary_entry_model.dart   Entry model
│   │   │   └── settings_model.dart      Settings model
│   │   ├── repositories/repositories.dart      Repository pattern
│   │   └── services/
│   │       ├── image_service.dart       Image picking
│   │       └── export_service.dart      JSON/PDF export
│   └── presentation/
│       ├── providers/
│       │   ├── app_providers.dart       Base providers
│       │   ├── auth_provider.dart       Auth logic
│       │   └── diary_providers.dart     Diary logic
│       ├── screens/
│       │   ├── home_screen.dart         📱 Main screen
│       │   ├── diary_entry_screen.dart  ✏️ Create/edit
│       │   ├── entry_detail_screen.dart 👁️ View details
│       │   ├── authentication_screen.dart 🔐 PIN screen
│       │   ├── search_screen.dart       🔍 Search
│       │   └── settings_screen.dart     ⚙️ Settings
│       └── widgets/
│           ├── mood_selector.dart       Mood picker
│           ├── image_grid_view.dart     Image display
│           └── pin_input_dialog.dart    PIN input
├── pubspec.yaml                  📦 Dependencies
├── README.md                     📖 Full documentation
├── SETUP.md                      🚀 Setup guide
├── WINDOWS_BUILD_GUIDE.md        🪟 Windows guide
└── IMPLEMENTATION_SUMMARY.md     📋 What was created
```

---

## Key Concepts

### State Management (Riverpod)
```dart
// Watch a provider (reactive)
final isDarkTheme = ref.watch(themeProvider);

// Update a provider
ref.read(themeProvider.notifier).state = !isDarkTheme;

// Invalidate to refresh
ref.invalidate(diaryEntriesProvider);

// Get future result
final entries = await ref.read(diaryEntriesProvider.future);
```

### Database Operations (Hive)
```dart
// Save entry
await repository.saveDiaryEntry(entry);

// Get all entries
final entries = await repository.getAllDiaryEntries();

// Search entries
final results = await repository.searchDiaryEntries("keyword");

// Get favorites
final favorites = await repository.getFavoriteDiaryEntries();

// Delete entry
await repository.deleteDiaryEntry(entryId);
```

### Navigation
```dart
// Push to next screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => NextScreen()),
);

// Pop to previous screen
Navigator.pop(context);
```

### Dialog/Sheet
```dart
// Show dialog
showDialog(
  context: context,
  builder: (context) => AlertDialog(...),
);

// Show bottom sheet
showModalBottomSheet(
  context: context,
  builder: (context) => Container(...),
);
```

---

## File Templates

### New Screen (ConsumerStatefulWidget)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyScreen extends ConsumerStatefulWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Title')),
      body: Center(child: const Text('Content')),
    );
  }
}
```

### New Widget (ConsumerWidget)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyWidget extends ConsumerWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
```

### New Provider
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myProvider = StateProvider<String>((ref) => '');
// or
final myProvider = FutureProvider<List>((ref) async => []);
```

---

## Common Patterns

### Handle AsyncValue
```dart
final dataAsync = ref.watch(someProvider);

dataAsync.when(
  data: (data) => Text(data),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

### Responsive Layout
```dart
final isMobile = MediaQuery.of(context).size.width < 600;

if (isMobile) {
  // Mobile layout
} else {
  // Desktop layout
}
```

### Show Snackbar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Message')),
);
```

### Async Operation with Loading
```dart
setState(() => _isLoading = true);
try {
  await someAsync();
} catch (e) {
  print('Error: $e');
} finally {
  setState(() => _isLoading = false);
}
```

---

## Troubleshooting Checklist

| Issue | Solution |
|-------|----------|
| "Hive adapters not found" | `flutter pub run build_runner build --delete-conflicting-outputs` |
| "Dependency not found" | `flutter pub get` |
| "Windows device not found" | `flutter config --enable-windows-desktop` |
| "Build fails randomly" | `flutter clean && flutter pub get` |
| "Hot reload doesn't work" | Do full hot restart (Press R) or `flutter run` again |
| "App shows black screen" | Check console for errors, run with `--verbose` |
| "Image picker doesn't work" | Check platform permissions (AndroidManifest.xml, Info.plist) |
| "Database errors on start" | Ensure Hive.initFlutter() called before runApp() |

---

## First-Time Developer Guide

### 1. Understand the Architecture
```
User Action → Screen/Widget
    ↓
Riverpod Provider (State)
    ↓
Repository (Business Logic)
    ↓
DataSource (Database)
    ↓
Hive Database (Local Storage)
```

### 2. Add a New Feature (Example: Add Priority)

**Step 1**: Update model
```dart
// In diary_entry_model.dart
@HiveField(9)
final String priority; // Add this
```

**Step 2**: Update database
```dart
// In local_datasource.dart
// No changes needed - Hive handles automatically
```

**Step 3**: Update UI
```dart
// In diary_entry_screen.dart
// Add priority selector widget
```

**Step 4**: Regenerate code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Testing Your Changes
- Hot reload to test quickly
- Test on Windows, Android, iOS, and Web
- Check database with Flutter DevTools

---

## Performance Tips

1. **Use const constructors**: `const MyWidget()`
2. **Use LayoutBuilder**: For responsive layouts
3. **Use ListView.builder**: For large lists
4. **Use provider.select()**: To rebuild only when needed
5. **Image compression**: Already done (85% quality)
6. **Code split**: Use import aliases for lazy loading

---

## Security Reminders

- ✅ Never log sensitive data
- ✅ Always validate user input
- ✅ Use HTTPS for any network calls
- ✅ Keep Hive database encrypted (future enhancement)
- ✅ Don't store tokens in shared preferences
- ✅ Implement session timeout
- ✅ Use secure random number generation

---

## Git Workflow

```bash
# Create feature branch
git checkout -b feature/diary-improvement

# Make changes
# Test thoroughly
# Commit
git add .
git commit -m "feat: add diary improvement"

# Push
git push origin feature/diary-improvement

# Create pull request on GitHub
```

---

## Resources

- **Flutter Docs**: https://docs.flutter.dev
- **Riverpod Docs**: https://riverpod.dev
- **Hive Docs**: https://docs.hivedb.dev
- **Dart Docs**: https://dart.dev/guides
- **Material Design 3**: https://m3.material.io
- **Flutter Community**: https://discord.gg/flutter-dev

---

## Emergency Commands

```bash
# Nuclear option - complete rebuild
flutter clean
flutter pub cache clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run

# Check everything
flutter doctor -v

# Update Flutter
flutter upgrade

# Analyze code
flutter analyze

# Run tests
flutter test
```

---

## Development Checklist

Before pushing code:
- [ ] Run `flutter analyze` - No errors
- [ ] Hot reload/restart works
- [ ] Tested on Windows
- [ ] Tested on Android
- [ ] All providers invalidated correctly
- [ ] No console errors
- [ ] Comments added to complex code
- [ ] Code follows Dart style guide
- [ ] No debugging print statements

---

## Quick Stats

- **Files Created**: 20+
- **Lines of Code**: 3000+
- **Architecture Layers**: 3 (Data, Domain, Presentation)
- **Riverpod Providers**: 15+
- **Screens**: 6
- **Widgets**: 3 custom
- **Dependencies**: 20+
- **Supported Platforms**: 4 (Windows, Android, iOS, Web)

---

## Contact & Support

- Read documentation in order: SETUP.md → README.md → WINDOWS_BUILD_GUIDE.md
- Check IMPLEMENTATION_SUMMARY.md for detailed overview
- Review inline code comments for specifics
- Search GitHub Flutter issues for known problems
- Join Flutter Discord for community help

---

**Happy Coding! 🚀**

Last Updated: February 2026

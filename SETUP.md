# Quick Setup Guide - Digital Diary

This guide walks you through setting up the Digital Diary application from scratch.

## ⚡ 5-Minute Quick Start

```bash
# 1. Navigate to project
cd d:\Moynull\ Hasan\new\ test\ app\nott\noteapp

# 2. Get dependencies
flutter pub get

# 3. Generate code (CRITICAL!)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run -d windows

# OR run on any device
flutter run
```

That's it! Your diary app is running.

---

## 📋 Prerequisites

- [ ] Flutter SDK 3.10.8+
- [ ] Dart SDK 3.10.8+
- [ ] Git
- [ ] Visual Studio (with C++ for Windows)

### Verify Installation

```bash
flutter --version
dart --version
flutter doctor
```

All should show ✓ (green checks).

---

## 🚀 First-Time Setup (Detailed)

### Step 1: Install Flutter

**Windows**:
1. Download from https://flutter.dev/docs/get-started/install/windows
2. Extract to `C:\flutter`
3. Add `C:\flutter\bin` to PATH
4. Run `flutter doctor` to verify

**Mac/Linux**: Follow official Flutter installation guide

### Step 2: Verify Flutter

```bash
flutter doctor -v
```

Expected output:
```
✓ Flutter
✓ Dart
✓ Visual Studio (Windows)
✓ Android Studio / Xcode
```

### Step 3: Clone/Navigate to Project

```bash
# If you haven't cloned yet
git clone <repository-url>
cd noteapp

# Or navigate if already cloned
cd "d:\Moynull Hasan\new test app\nott\noteapp"
```

### Step 4: Get Dependencies

```bash
flutter pub get
```

This downloads all packages from `pubspec.yaml`.

### Step 5: Generate Code

**CRITICAL STEP**: This generates Hive adapters for database.

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

You should see output:
```
Building package executable...
Building with `package:build_runner`...
Generated 2 adapters.
Completed successfully.
```

### Step 6: Run the App

#### On Windows Desktop
```bash
flutter run -d windows
```

#### On Android Emulator
```bash
flutter emulators --launch android_emulator
flutter run -d emulator-5554
```

#### On iOS Simulator
```bash
open -a Simulator
flutter run
```

#### On Any Connected Device
```bash
flutter devices          # List available devices
flutter run -d <device>  # Run on specific device
```

---

## ✨ First Launch

1. **Authentication Screen**: No PIN set initially
   - Tap "Unlock" without entering anything
   - This grants access

2. **Empty Home Screen**: No entries yet
   - Tap floating action button (+) to create first entry

3. **Create First Entry**:
   - Title: "My First Entry"
   - Select a mood (e.g., 😊)
   - Write something in the body
   - Tap the checkmark to save

4. **Entry Saved**:
   - You'll see it on the home screen
   - Can click to view details
   - Can edit, delete, or toggle favorite

5. **Settings**:
   - Go to settings tab
   - Set a PIN for security (6 digits)
   - Toggle dark mode

---

## 🔄 Common Development Tasks

### Hot Reload (Fast)
```bash
# While running:
# Press 'r' in terminal to hot reload
# Changes appear in app instantly

flutter run -d windows
# > r (to hot reload)
```

### Full Rebuild (Slow)
```bash
# Press 'R' in terminal
# OR restart the app
flutter run -d windows
# > R (to hot restart)
```

### Regenerate Code
```bash
# After modifying models or providers
flutter pub run build_runner build --delete-conflicting-outputs

# Or watch mode (auto-regenerates)
flutter pub run build_runner watch
```

### Clean Build
```bash
flutter clean
flutter pub get
flutter pub run build_builder build --delete-conflicting-outputs
flutter run
```

### View All Devices
```bash
flutter devices
```

### Verbose Logging
```bash
flutter run --verbose
```

---

## 📱 Testing on Different Platforms

### Windows Desktop
```bash
flutter run -d windows
```

### Android Device/Emulator
```bash
flutter run -d android
```

### iOS Device/Simulator
```bash
flutter run -d ios
```

### Web (Browser)
```bash
flutter run -d chrome
```

---

## 🏗️ Project Structure After Setup

```
noteapp/
├── lib/                      # All Dart source code
│   ├── main.dart            # App entry point
│   ├── core/                # Constants, themes, utilities
│   ├── data/                # Models, database, repositories
│   └── presentation/        # Screens, widgets, state management
├── build/                   # Build artifacts (auto-generated)
├── pubspec.yaml            # Dependencies list
├── pubspec.lock            # Locked dependency versions
├── analysis_options.yaml   # Linting rules
└── README.md               # Project documentation
```

---

## 🐛 Troubleshooting

### "Hive adapters not found"
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### "SDK version mismatch"
```bash
flutter upgrade
```

### "Windows targets not found"
```bash
flutter config --enable-windows-desktop
flutter doctor
```

### "pub get fails"
```bash
# Try:
flutter clean
flutter pub cache clean
flutter pub get
```

### "Permission denied" (Mac/Linux)
```bash
chmod +x $(which flutter)
flutter pub get
```

---

## 📚 Key Files to Know

| File | Purpose |
|------|---------|
| `lib/main.dart` | App initialization and setup |
| `lib/data/models/diary_entry_model.dart` | Diary entry data structure |
| `lib/presentation/screens/home_screen.dart` | Main screen |
| `lib/presentation/providers/*.dart` | State management |
| `pubspec.yaml` | Dependencies configuration |

---

## 🎯 Next Steps After Setup

1. **Create some test entries** to familiarize with the app
2. **Set a PIN** in settings for security
3. **Toggle dark mode** to see theme switching
4. **Search entries** to test search functionality
5. **Export data** (JSON/PDF) to test backup
6. **Read the code** starting with `lib/main.dart`

---

## 🔐 Security Setup

### Set PIN Protection
1. Go to Settings
2. Tap "PIN Protection"
3. Enter a 6-digit PIN
4. Confirm PIN
5. Now diary is locked on app restart

### Toggle Dark Mode
1. Go to Settings
2. Switch "Dark Theme" toggle
3. Theme changes instantly

---

## 📖 Documentation Structure

After setup, read in this order:
1. **README.md** - Overview and features
2. **SETUP.md** (this file) - Initial setup
3. **WINDOWS_BUILD_GUIDE.md** - Windows-specific setup
4. **Code comments** - Inline documentation in source files

---

## 🆘 Getting Help

### Check Status
```bash
flutter doctor -v  # Check all dependencies
flutter devices    # Check available devices
```

### View Logs
```bash
flutter run --verbose
```

### Clean Start
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Search for Solutions
- GitHub Issues: https://github.com/flutter/flutter/issues
- Stack Overflow: Tag `flutter` and `dart`
- Flutter Discord: https://discord.gg/flutter-dev

---

## ✅ Verification Checklist

After setup, verify:

- [ ] `flutter doctor` shows all green ✓
- [ ] `flutter devices` lists your device
- [ ] `flutter run -d windows` starts the app
- [ ] App displays "Digital Diary" home screen
- [ ] FAB (+) button works to create entry
- [ ] Creating an entry saves successfully
- [ ] Entry appears in home screen
- [ ] Settings screen accessible
- [ ] Dark mode toggle works
- [ ] Search screen works

All checks passed? You're ready to develop! 🎉

---

## 🔄 Daily Development Workflow

```bash
# Morning start
cd noteapp
flutter pub get
flutter pub run build_runner watch

# In another terminal
flutter run -d windows

# Make code changes
# App hot-reloads automatically (press 'r')

# Before committing
flutter analyze
flutter test
flutter build windows --release
```

---

## 📝 Notes

- **Never** skip the code generation step (`build_runner`)
- **Always** run `flutter pub get` after pulling new code
- **Use** hot reload during development for speed
- **Check** `flutter doctor` if something breaks
- **Clean** the project if you encounter weird errors

---

**Ready to build amazing diary features? Let's go! 🚀**

Last Updated: February 2026

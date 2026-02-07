# Windows Development & Build Guide

This guide provides comprehensive instructions for developing and building the Digital Diary app for Windows desktop.

## Prerequisites

### System Requirements
- **Windows 10** or **Windows 11**
- **Flutter SDK** >= 3.10.8
- **Dart SDK** >= 3.10.8
- **Visual Studio** with C++ workload (for Windows desktop development)
- **Git** (for version control)

### Install Visual Studio Build Tools

1. Download Visual Studio Community from https://visualstudio.microsoft.com/downloads/
2. Run the installer
3. Select "Desktop development with C++"
4. Complete installation
5. Verify installation:
   ```powershell
   flutter doctor
   ```

## Setting Up Flutter for Windows

### 1. Install Flutter

```powershell
# Download Flutter from https://flutter.dev/docs/get-started/install/windows
# Extract to a permanent location (e.g., C:\flutter)

# Add Flutter to PATH
# Edit Environment Variables and add: C:\flutter\bin to PATH

# Verify installation
flutter --version
flutter doctor
```

### 2. Enable Windows Desktop Development

```powershell
# Enable Windows as a target platform
flutter config --enable-windows-desktop

# Verify Windows is enabled
flutter devices
```

## Development Workflow

### Clone & Setup Project

```powershell
# Navigate to project directory
cd "d:\Moynull Hasan\new test app\nott\noteapp"

# Get dependencies
flutter pub get

# Generate Hive adapters (IMPORTANT!)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on Windows
flutter run -d windows
```

### Hot Reload Development

During development, use hot reload for faster iteration:

```powershell
# Run the app
flutter run -d windows

# In the terminal, press 'r' to hot reload
# Press 'R' for full hot restart
# Press 'q' to quit
```

### Code Generation

If you modify models or add new Riverpod providers:

```powershell
# Regenerate adapters and code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
flutter pub run build_runner watch
```

## Building for Windows

### Development Build

```powershell
flutter build windows --debug
# Output: build\windows\runner\Debug\noteapp.exe
```

### Release Build (Optimized)

```powershell
flutter build windows --release
# Output: build\windows\runner\Release\noteapp.exe
```

### Install from Build

```powershell
# The executable can be run directly from:
.\build\windows\runner\Release\noteapp.exe

# Or copy to Applications folder:
Copy-Item build\windows\runner\Release noteapp -Recurse
```

## Windows-Specific Configurations

### App Configuration (windows/runner/main.cpp)

The Windows app window is configured in `windows/runner/main.cpp`. The default settings are:
- Window size: 1280x720 (can be resized by user)
- Minimum window size: 800x600
- Window title: "Digital Diary"

### Modify Window Settings

Edit `windows/runner/main.cpp` to change:

```cpp
// Window size
static constexpr int kInitialWidth = 1280;
static constexpr int kInitialHeight = 720;

// Window title
FlutterWindow::kWindowTitle = L"Digital Diary";
```

### Package Installation (Installer.exe)

To create a Windows installer, use:

```powershell
# Option 1: Create MSIX package (Windows Store format)
flutter pub get msix

# Option 2: Use NSIS for traditional installer
# Download NSIS from https://nsis.sourceforge.io/
```

## Platform Channel Setup (Optional)

If you need native Windows functionality:

1. **Define platform channel in Dart**:
```dart
static const platform = MethodChannel('com.example.noteapp/platform');
```

2. **Implement in C++ (windows/runner/win32_window.cpp)**

3. **Call from Dart**:
```dart
try {
  final result = await platform.invokeMethod('getPlatformVersion');
} catch (e) {
  print('Error: $e');
}
```

## Keyboard Shortcuts (Implement in main_window.cpp)

Currently supported:
- Standard Windows shortcuts (Ctrl+C, Ctrl+V, etc.)

Future shortcuts to add:
- `Ctrl+N`: New entry
- `Ctrl+F`: Search
- `Ctrl+S`: Save
- `Ctrl+Q`: Quit

## Common Windows Development Issues

### Issue: "Windows targets not found"

**Solution**:
```powershell
flutter config --enable-windows-desktop
flutter doctor
```

### Issue: "Visual C++ build tools not found"

**Solution**: Install Visual Studio with C++ development tools

### Issue: "DLL not found" errors

**Solution**: Ensure Visual Studio C++ runtime libraries are installed:
1. Download from: https://support.microsoft.com/en-us/help/2977003/
2. Install Visual C++ Redistributable (x64)

### Issue: "Application fails on Windows 7"

**Note**: Flutter Windows requires Windows 10+ due to UWP API usage.

### Issue: Build takes very long

**Solution**: Use incremental builds:
```powershell
flutter pub run build_runner build
# Instead of --delete-conflicting-outputs (faster after first build)
```

## Performance Optimization for Windows

1. **Minimize bundle size**: Use `--split-debug-info` flag
```powershell
flutter build windows --release --split-debug-info=debuginfo/
```

2. **Profile app performance**:
```powershell
flutter run --profile -d windows
```

3. **Check frame rates**: Enable performance overlay with `P` during `flutter run`

## Testing on Windows

### Unit Tests
```powershell
flutter test
```

### Integration Tests
```powershell
flutter drive --target test_driver/app.dart
```

### Widget Tests
```powershell
flutter test test/presentation/screens/home_screen_test.dart
```

## Continuous Integration (CI/CD)

### GitHub Actions Example

Create `.github/workflows/windows_build.yml`:

```yaml
name: Windows Build

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: windows-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.10.8'
        channel: 'stable'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Generate code
      run: flutter pub run build_runner build --delete-conflicting-outputs
    
    - name: Build Windows
      run: flutter build windows --release
    
    - name: Upload artifact
      uses: actions/upload-artifact@v3
      with:
        name: noteapp-windows
        path: build/windows/runner/Release/
```

## Code Signing (Optional, for Distribution)

To sign your Windows executable:

```powershell
# Install signtool (comes with Windows SDK)
# Create a certificate request and sign it with a code signing certificate

# Sign the executable
signtool sign /f "your-certificate.pfx" /p "password" /t "http://timestamp.server.com" noteapp.exe
```

## Deployment

### For Internal Use
1. Build release: `flutter build windows --release`
2. Copy `build/windows/runner/Release/` to shared location
3. Users run `noteapp.exe`

### For External Distribution
1. Create installer using NSIS or WiX
2. Sign the installer with code signing certificate
3. Upload to website or app store
4. Provide download link

### Self-Contained Package
```powershell
# All dependencies are included in the Release build
# You only need to distribute the entire Release folder

xcopy build\windows\runner\Release\ noteapp-dist\ /E /I
# Users can run noteapp.exe directly
```

## Debugging Windows App

### Debug Build
```powershell
flutter run -d windows --debug
```

### Debug Specific Device
```powershell
flutter run -d windows --debug --verbose
```

### Debug Dart Code
- Set breakpoints in VSCode
- Use Debug Console for expressions
- Check "Debug" tab for variables

### Check System Info
```powershell
# Windows version
[System.Environment]::OSVersion.VersionString

# Flutter info
flutter doctor -v

# Dart info
dart --version
```

## Additional Resources

- [Flutter Windows Documentation](https://docs.flutter.dev/get-started/install/windows)
- [Flutter Desktop Documentation](https://docs.flutter.dev/desktop)
- [Windows 10/11 Development](https://docs.microsoft.com/en-us/windows/win32/)
- [Visual Studio Download](https://visualstudio.microsoft.com/downloads/)

## Support & Troubleshooting

For Windows-specific issues:
1. Check `flutter doctor -v` output
2. Review Flutter issue tracker: https://github.com/flutter/flutter/issues
3. Search Windows development forums
4. Check platform-specific discussions on Flutter Discord

---

**Last Updated**: February 2026

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:auto_updater/auto_updater.dart';
import 'package:noteapp/core/config/app_themes.dart';
import 'package:noteapp/data/datasources/local_datasource.dart';
import 'package:noteapp/data/models/adapters/diary_entry_adapter.dart';
import 'package:noteapp/data/models/adapters/settings_adapter.dart';
import 'package:noteapp/presentation/providers/app_providers.dart';
import 'package:noteapp/presentation/providers/auth_provider.dart';
import 'package:noteapp/presentation/screens/authentication_screen.dart';
import 'package:noteapp/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(DiaryEntryModelAdapter());
  Hive.registerAdapter(SettingsModelAdapter());

  // Initialize Database
  final localDataSource = LocalDataSourceImpl();
  await localDataSource.initializeBoxes();

  // Initialize Auto-Updater
  String feedURL =
      'https://raw.githubusercontent.com/moynull15-14141/NoteappMandN_holidays/main/appcast.xml';

  try {
    await autoUpdater.setFeedURL(feedURL);
    await autoUpdater.checkForUpdates();
    await autoUpdater.setScheduledCheckInterval(3600); // Checks every hour
  } catch (e) {
    // Auto-updater errors won't crash the app
  }

  // Create a ProviderContainer override for the datasource
  final container = ProviderContainer(
    overrides: [localDataSourceProvider.overrideWithValue(localDataSource)],
  );

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize auth state
    await ref.read(authProvider.notifier).initializeAuth();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Digital Diary',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: authState.isLocked
          ? const AuthenticationScreen()
          : const HomeScreen(),
    );
  }
}

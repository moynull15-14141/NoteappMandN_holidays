import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hive_flutter/hive_flutter.dart';
import 'package:noteapp/core/constants/app_constants.dart';
import 'package:noteapp/core/services/update_service.dart';
import 'package:noteapp/data/models/settings_model.dart';
import 'package:noteapp/presentation/providers/auth_provider.dart';
import 'package:noteapp/presentation/providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SettingSection(
            title: 'Appearance',
            children: [
              _SettingsTile(
                leading: Icon(isDarkTheme ? Icons.dark_mode : Icons.light_mode),
                title: 'Dark Theme',
                trailing: Switch(
                  value: isDarkTheme,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).state = value;
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _SettingSection(
            title: 'Security',
            children: [
              _SettingsTile(
                leading: const Icon(Icons.lock),
                title: 'PIN Protection',
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  // Check if PIN is already set
                  final settings = await ref.read(settingsProvider.future);

                  if (settings?.pinCode != null &&
                      settings!.pinCode!.isNotEmpty) {
                    // PIN already exists, verify first
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => SecurityVerificationDialog(
                          onVerified: () {
                            if (context.mounted) {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const PinSetupDialog(),
                              );
                            }
                          },
                        ),
                      );
                    }
                  } else {
                    // No PIN set yet, show setup dialog directly
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const PinSetupDialog(),
                      );
                    }
                  }
                },
              ),
              _SettingsTile(
                leading: const Icon(Icons.logout),
                title: 'Lock Diary',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ref.read(authProvider.notifier).lock(context);
                },
              ),
            ],
          ),
          const Divider(height: 32),
          _SettingSection(
            title: 'About & Updates',
            children: [
              _SettingsTile(
                leading: const Icon(Icons.info),
                title: 'App Version',
                trailing: const Text(
                  AppConstants.appVersion,
                  style: TextStyle(fontSize: 12),
                ),
              ),
              _SettingsTile(
                leading: const Icon(Icons.system_update),
                title: 'Check for Updates',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const _UpdateCheckDialog(),
                  );
                },
              ),
              _SettingsTile(
                leading: const Icon(Icons.open_in_new),
                title: 'GitHub Releases',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  UpdateService.openGitHubReleases();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PinSetupDialog extends StatefulWidget {
  const PinSetupDialog({super.key});

  @override
  State<PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<PinSetupDialog> {
  late final TextEditingController pinController;
  late final TextEditingController confirmPinController;
  late final TextEditingController questionController;
  late final TextEditingController answerController;

  @override
  void initState() {
    super.initState();
    pinController = TextEditingController();
    confirmPinController = TextEditingController();
    questionController = TextEditingController();
    answerController = TextEditingController();
  }

  @override
  void dispose() {
    pinController.dispose();
    confirmPinController.dispose();
    questionController.dispose();
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('PIN Setup'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set your PIN and security question:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'PIN (6 digits)',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Confirm PIN',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            TextField(
              controller: questionController,
              decoration: InputDecoration(
                labelText: 'Security Question',
                hintText: 'e.g., Your birth date, favorite color?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: answerController,
              decoration: InputDecoration(
                labelText: 'Answer',
                hintText: 'e.g., 15/06, Blue',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        Consumer(
          builder: (context, ref, _) {
            return ElevatedButton(
              onPressed: () async {
                // Validation
                if (pinController.text.isEmpty ||
                    confirmPinController.text.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN cannot be empty')),
                    );
                  }
                  return;
                }

                if (pinController.text.length != 6 ||
                    confirmPinController.text.length != 6) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PIN must be exactly 6 digits'),
                      ),
                    );
                  }
                  return;
                }

                if (pinController.text != confirmPinController.text) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PINs do not match')),
                    );
                  }
                  return;
                }

                if (questionController.text.isEmpty ||
                    answerController.text.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Question and answer cannot be empty'),
                      ),
                    );
                  }
                  return;
                }

                // Setup PIN with security question
                await ref
                    .read(authProvider.notifier)
                    .setupPinWithSecurityQuestion(
                      pinController.text,
                      questionController.text,
                      answerController.text,
                    );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'PIN and security question set successfully!',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Set'),
            );
          },
        ),
      ],
    );
  }
}

class SecurityVerificationDialog extends ConsumerStatefulWidget {
  final VoidCallback onVerified;

  const SecurityVerificationDialog({super.key, required this.onVerified});

  @override
  ConsumerState<SecurityVerificationDialog> createState() =>
      _SecurityVerificationDialogState();
}

class _SecurityVerificationDialogState
    extends ConsumerState<SecurityVerificationDialog> {
  late TextEditingController answerController;
  bool isVerifying = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    answerController = TextEditingController();
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verify Your Identity'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Answer your security question to proceed:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            FutureBuilder<SettingsModel?>(
              future: ref.watch(settingsProvider.future),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final settings = snapshot.data;
                final question = settings?.securityQuestion ?? 'Unknown';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        question,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: answerController,
                      decoration: InputDecoration(
                        labelText: 'Your Answer',
                        hintText: 'Enter your answer',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorText: errorMessage,
                      ),
                      onSubmitted: (_) => _verifyAnswer(context),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: isVerifying
                            ? null
                            : () {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => PinRecoveryDialog(
                                    onVerified: () {
                                      Navigator.pop(context);
                                      widget.onVerified();
                                    },
                                  ),
                                );
                              },
                        child: const Text('Forgot Answer? Use PIN instead'),
                      ),
                    ] else if (!isVerifying) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => PinRecoveryDialog(
                              onVerified: () {
                                Navigator.pop(context);
                                widget.onVerified();
                              },
                            ),
                          );
                        },
                        child: const Text('Forgot Answer? Use PIN instead'),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isVerifying ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isVerifying ? null : () => _verifyAnswer(context),
          child: isVerifying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Verify'),
        ),
      ],
    );
  }

  Future<void> _verifyAnswer(BuildContext context) async {
    if (answerController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your answer';
      });
      return;
    }

    setState(() {
      isVerifying = true;
      errorMessage = null;
    });

    try {
      // Add a small delay to ensure database is ready
      await Future.delayed(const Duration(milliseconds: 100));

      final isCorrect = await ref
          .read(authProvider.notifier)
          .verifySecurityAnswer(answerController.text);

      if (!context.mounted) return;

      if (isCorrect) {
        // Answer is correct, proceed with PIN setup
        widget.onVerified();
      } else {
        setState(() {
          errorMessage = 'Incorrect answer. Please try again.';
          isVerifying = false;
        });
      }
    } catch (e) {
      final errorMsg = _getUserFriendlyError(e);
      setState(() {
        errorMessage = errorMsg;
        isVerifying = false;
      });
    }
  }

  String _getUserFriendlyError(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('lock')) {
      return 'Database is busy. Please try again.';
    } else if (errorStr.contains('storage') || errorStr.contains('failed')) {
      return 'Failed to access security data. Try again.';
    } else {
      return 'Verification failed. Please try again.';
    }
  }
}

class PinRecoveryDialog extends ConsumerStatefulWidget {
  final VoidCallback onVerified;

  const PinRecoveryDialog({super.key, required this.onVerified});

  @override
  ConsumerState<PinRecoveryDialog> createState() => _PinRecoveryDialogState();
}

class _PinRecoveryDialogState extends ConsumerState<PinRecoveryDialog> {
  late TextEditingController pinController;
  bool isVerifying = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    pinController = TextEditingController();
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verify With PIN'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your PIN to proceed:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'PIN (6 digits)',
                hintText: 'Enter your 6-digit PIN',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: errorMessage,
              ),
              onSubmitted: (_) => _verifyPin(context),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isVerifying ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isVerifying ? null : () => _verifyPin(context),
          child: isVerifying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Verify PIN'),
        ),
      ],
    );
  }

  Future<void> _verifyPin(BuildContext context) async {
    if (pinController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your PIN';
      });
      return;
    }

    if (pinController.text.length != 6) {
      setState(() {
        errorMessage = 'PIN must be exactly 6 digits';
      });
      return;
    }

    setState(() {
      isVerifying = true;
      errorMessage = null;
    });

    try {
      // Add a small delay to ensure database is ready
      await Future.delayed(const Duration(milliseconds: 100));

      final isAuthenticated = await ref
          .read(authProvider.notifier)
          .authenticate(pinController.text);

      if (!context.mounted) return;

      if (isAuthenticated) {
        // PIN is correct, proceed with PIN setup
        widget.onVerified();
      } else {
        setState(() {
          errorMessage = 'Incorrect PIN. Please try again.';
          isVerifying = false;
        });
      }
    } catch (e) {
      final errorMsg = _getUserFriendlyError(e);
      setState(() {
        errorMessage = errorMsg;
        isVerifying = false;
      });
    }
  }

  String _getUserFriendlyError(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('lock')) {
      return 'Database is busy. Please try again.';
    } else if (errorStr.contains('storage') || errorStr.contains('failed')) {
      return 'Failed to verify PIN. Try again.';
    } else {
      return 'Verification failed. Please try again.';
    }
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    this.leading,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
      dense: true,
    );
  }
}

/// Dialog for checking app updates
class _UpdateCheckDialog extends StatefulWidget {
  const _UpdateCheckDialog();

  @override
  State<_UpdateCheckDialog> createState() => _UpdateCheckDialogState();
}

class _UpdateCheckDialogState extends State<_UpdateCheckDialog> {
  bool _isChecking = true;
  Map<String, dynamic>? _updateInfo;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  void _checkForUpdates() async {
    try {
      final info = await UpdateService.checkForUpdates();

      if (!mounted) return;

      setState(() {
        _isChecking = false;
        _updateInfo = info;
        if (info == null) {
          _errorMessage =
              'Unable to check for updates. Please check your internet connection.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isChecking = false;
        _errorMessage = 'Error checking for updates: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return AlertDialog(
        title: const Text('Checking for Updates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Please wait...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return AlertDialog(
        title: const Text('Update Check Failed'),
        content: Text(_errorMessage!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isChecking = true;
                _errorMessage = null;
              });
              _checkForUpdates();
            },
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (_updateInfo == null) {
      return AlertDialog(
        title: const Text('Update Check'),
        content: const Text('No update information available.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    }

    final hasUpdate = _updateInfo!['hasUpdate'] as bool? ?? false;
    final currentVersion =
        _updateInfo!['currentVersion'] as String? ?? 'Unknown';
    final latestVersion = _updateInfo!['latestVersion'] as String? ?? 'Unknown';
    final changelog =
        _updateInfo!['changelog'] as String? ?? 'No changelog available';

    if (!hasUpdate) {
      return AlertDialog(
        title: const Text('✅ App is Up to Date'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current version: $currentVersion'),
            const SizedBox(height: 8),
            const Text('You are running the latest version!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('🎉 Update Available!'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current version: $currentVersion',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Latest version: $latestVersion',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'What\'s new:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: SingleChildScrollView(
                child: Text(changelog, style: const TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Later'),
        ),
        ElevatedButton(
          onPressed: () {
            UpdateService.openGitHubReleases();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Opening GitHub releases page. Download the latest exe file.',
                ),
                duration: Duration(seconds: 4),
              ),
            );
          },
          child: const Text('Download Now'),
        ),
      ],
    );
  }
}

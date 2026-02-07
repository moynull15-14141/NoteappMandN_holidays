import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noteapp/core/constants/app_constants.dart';
import 'package:noteapp/presentation/providers/auth_provider.dart';
import 'package:noteapp/presentation/providers/app_providers.dart';
import 'package:noteapp/presentation/widgets/pin_input_dialog.dart';

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
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => PinInputDialog(
                      title: 'Set PIN',
                      description: 'Set a 6-digit PIN to protect your diary',
                      buttonText: 'Set PIN',
                      onSubmit: (pin) async {
                        await ref.read(authProvider.notifier).setupPin(pin);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('PIN set successfully'),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
              _SettingsTile(
                leading: const Icon(Icons.logout),
                title: 'Lock Diary',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ref.read(authProvider.notifier).lock();
                },
              ),
            ],
          ),
          const Divider(height: 32),
          _SettingSection(
            title: 'About',
            children: [
              _SettingsTile(
                leading: const Icon(Icons.info),
                title: 'App Version',
                trailing: const Text(
                  AppConstants.appVersion,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

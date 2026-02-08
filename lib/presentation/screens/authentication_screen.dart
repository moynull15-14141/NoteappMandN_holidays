import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noteapp/presentation/providers/app_providers.dart';
import 'package:noteapp/presentation/providers/auth_provider.dart';

class AuthenticationScreen extends ConsumerStatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  ConsumerState<AuthenticationScreen> createState() =>
      _AuthenticationScreenState();
}

class _AuthenticationScreenState extends ConsumerState<AuthenticationScreen> {
  late TextEditingController _pinController;
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();

    // Add listener to validate PIN as user types
    _pinController.addListener(() async {
      if (_pinController.text.length == 6) {
        final isAuthenticated = await ref
            .read(authProvider.notifier)
            .authenticate(_pinController.text);

        if (isAuthenticated) {
          // Automatically navigate to the next screen if PIN is correct
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _pinController.removeListener(
      () {},
    ); // Remove listener to avoid memory leaks
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Digital Diary',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your PIN to unlock your diary',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _pinController,
                  obscureText: _isObscured,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  decoration: InputDecoration(
                    hintText: '\u2022\u2022\u2022\u2022\u2022\u2022',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _isObscured = !_isObscured);
                      },
                    ),
                  ),
                ),
                if (authState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      authState.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    _showForgotPinDialog(context);
                  },
                  child: const Text('Forgot PIN?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPinDialog(BuildContext context) {
    _showSecurityQuestionDialog(context);
  }

  void _showSecurityQuestionDialog(BuildContext context) {
    final answerController = TextEditingController();

    // Get settings outside the dialog to avoid Riverpod issues
    ref.read(settingsProvider.future).then((settings) {
      final securityQuestion = settings?.securityQuestion;

      if (!context.mounted) return;

      if (securityQuestion == null || securityQuestion.isEmpty) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => AlertDialog(
            title: const Text('PIN Reset'),
            content: const Text(
              'No security question set for this account. Please reinstall the app and set a security question during PIN setup.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Security Question'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  securityQuestion,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: answerController,
                  decoration: InputDecoration(
                    labelText: 'Answer',
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
                answerController.dispose();
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final isCorrect = await ref
                    .read(authProvider.notifier)
                    .verifySecurityAnswer(answerController.text);

                if (isCorrect) {
                  answerController.dispose();
                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                    _showResetPinDialog(context);
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Incorrect answer. Please try again.'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Verify'),
            ),
          ],
        ),
      );
    });
  }

  void _showResetPinDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PinResetDialog(),
    );
  }
}

class PinResetDialog extends StatefulWidget {
  const PinResetDialog({super.key});

  @override
  State<PinResetDialog> createState() => _PinResetDialogState();
}

class _PinResetDialogState extends State<PinResetDialog> {
  late final TextEditingController newPinController;
  late final TextEditingController confirmPinController;

  @override
  void initState() {
    super.initState();
    newPinController = TextEditingController();
    confirmPinController = TextEditingController();
  }

  @override
  void dispose() {
    newPinController.dispose();
    confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set New PIN'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your new PIN (6 digits):',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'New PIN',
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
                if (newPinController.text.isEmpty ||
                    confirmPinController.text.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN cannot be empty')),
                    );
                  }
                  return;
                }

                if (newPinController.text.length != 6 ||
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

                if (newPinController.text != confirmPinController.text) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PINs do not match')),
                    );
                  }
                  return;
                }

                await ref
                    .read(authProvider.notifier)
                    .resetPin(newPinController.text);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN successfully reset!')),
                  );
                }
              },
              child: const Text('Reset PIN'),
            );
          },
        ),
      ],
    );
  }
}

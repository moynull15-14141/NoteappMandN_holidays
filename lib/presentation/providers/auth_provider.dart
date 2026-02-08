import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noteapp/core/utils/exceptions.dart';
import 'package:noteapp/data/models/settings_model.dart';
import 'package:noteapp/presentation/providers/app_providers.dart';

// Auth State
class AuthState {
  final bool isLocked;
  final String? error;
  final bool isLoading;

  AuthState({this.isLocked = true, this.error, this.isLoading = false});

  AuthState copyWith({bool? isLocked, String? error, bool? isLoading}) {
    return AuthState(
      isLocked: isLocked ?? this.isLocked,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState());

  Future<void> initializeAuth() async {
    try {
      final settings = await ref.read(settingsProvider.future);

      if (settings != null &&
          settings.pinCode != null &&
          settings.pinCode!.isNotEmpty) {
        state = state.copyWith(isLocked: true);
      } else {
        state = state.copyWith(isLocked: false);
      }
    } catch (e) {
      // If error getting settings, assume no PIN and unlock
      state = state.copyWith(isLocked: false);
    }
  }

  Future<bool> authenticate(String pinCode) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Add a small delay to ensure database is fully ready
      await Future.delayed(const Duration(milliseconds: 50));

      final settings = await ref.read(settingsProvider.future);

      // Safely check if PIN exists
      if (settings == null) {
        throw AuthenticationException(
          message: 'Settings not found',
          code: 'NO_SETTINGS',
        );
      }

      final savedPin = settings.pinCode;
      if (savedPin == null || savedPin.isEmpty) {
        throw AuthenticationException(
          message: 'PIN not set up',
          code: 'NO_PIN',
        );
      }

      // Safe PIN comparison
      if (pinCode.trim() == savedPin.trim()) {
        ref.read(isAuthenticatedProvider.notifier).state = true;
        ref.read(lastAuthTimeProvider.notifier).state = DateTime.now();

        state = state.copyWith(isLocked: false, isLoading: false);
        return true;
      } else {
        throw AuthenticationException(
          message: 'Incorrect PIN',
          code: 'WRONG_PIN',
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  Future<void> setupPin(String pinCode) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(settingsRepositoryProvider);
      final currentSettings = await repository.getSettings();

      final newSettings = (currentSettings ?? SettingsModel()).copyWith(
        pinCode: pinCode,
      );

      await repository.saveSettings(newSettings);

      // Invalidate settings provider to refresh cached data
      ref.invalidate(settingsProvider);

      ref.read(isAuthenticatedProvider.notifier).state = true;
      ref.read(lastAuthTimeProvider.notifier).state = DateTime.now();

      state = state.copyWith(isLocked: false, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: 'Failed to set PIN: $e', isLoading: false);
    }
  }

  Future<void> setupPinWithSecurityQuestion(
    String pinCode,
    String securityQuestion,
    String securityAnswer,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(settingsRepositoryProvider);
      final currentSettings = await repository.getSettings();

      final newSettings = (currentSettings ?? SettingsModel()).copyWith(
        pinCode: pinCode,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer.toLowerCase().trim(),
      );

      await repository.saveSettings(newSettings);

      // Invalidate settings provider to refresh cached data
      ref.invalidate(settingsProvider);

      ref.read(isAuthenticatedProvider.notifier).state = true;
      ref.read(lastAuthTimeProvider.notifier).state = DateTime.now();

      state = state.copyWith(isLocked: false, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: 'Failed to set PIN: $e', isLoading: false);
    }
  }

  Future<bool> verifySecurityAnswer(String answer) async {
    try {
      // Add a small delay to ensure database is fully ready
      await Future.delayed(const Duration(milliseconds: 50));

      final settings = await ref.read(settingsProvider.future);

      // Safely check if security answer exists
      if (settings == null) {
        return false;
      }

      final savedAnswer = settings.securityAnswer;
      if (savedAnswer == null || savedAnswer.isEmpty) {
        return false;
      }

      // Safe comparison of answers (normalize whitespace and case)
      final normalizedInput = answer.toLowerCase().trim();
      final normalizedSaved = savedAnswer.toLowerCase().trim();

      return normalizedInput == normalizedSaved;
    } catch (e) {
      debugPrint('Error verifying security answer: $e');
      return false;
    }
  }

  void lock(BuildContext? context) {
    state = state.copyWith(isLocked: true);
    ref.read(isAuthenticatedProvider.notifier).state = false;

    // Use WidgetsBinding to ensure navigation happens safely
    if (context != null && context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/auth');
          }
        } catch (e) {
          // Navigation error, continue gracefully
        }
      });
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> resetPin(String newPin) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(settingsRepositoryProvider);
      // Get current settings to preserve other data
      final currentSettings = await repository.getSettings();

      // Update only the PIN, keep everything else
      final updatedSettings = (currentSettings ?? SettingsModel()).copyWith(
        pinCode: newPin,
      );

      await repository.saveSettings(updatedSettings);

      // Invalidate settings provider to refresh cached data
      ref.invalidate(settingsProvider);

      // Authenticate with new PIN
      ref.read(isAuthenticatedProvider.notifier).state = true;
      ref.read(lastAuthTimeProvider.notifier).state = DateTime.now();
      state = state.copyWith(isLocked: false, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to reset PIN: $e',
        isLoading: false,
      );
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

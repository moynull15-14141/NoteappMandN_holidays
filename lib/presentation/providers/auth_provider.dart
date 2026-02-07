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
      final settings = await ref.read(settingsProvider.future);

      if (settings == null || settings.pinCode == null) {
        throw AuthenticationException(
          message: 'PIN not set up',
          code: 'NO_PIN',
        );
      }

      if (pinCode == settings.pinCode) {
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

  Future<void> updatePin(String currentPin, String newPin) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(settingsRepositoryProvider);
      final currentSettings = await repository.getSettings();

      if (currentSettings == null || currentSettings.pinCode == null) {
        throw AuthenticationException(
          message: 'No PIN is currently set.',
          code: 'NO_PIN',
        );
      }

      if (currentSettings.pinCode != currentPin) {
        throw AuthenticationException(
          message: 'Current PIN is incorrect.',
          code: 'WRONG_PIN',
        );
      }

      final newSettings = currentSettings.copyWith(pinCode: newPin);
      await repository.saveSettings(newSettings);

      // Invalidate settings provider to refresh cached data
      ref.invalidate(settingsProvider);

      ref.read(isAuthenticatedProvider.notifier).state = true;
      ref.read(lastAuthTimeProvider.notifier).state = DateTime.now();

      state = state.copyWith(isLocked: false, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update PIN: $e',
        isLoading: false,
      );
    }
  }

  void lock() {
    state = state.copyWith(isLocked: true);
    ref.read(isAuthenticatedProvider.notifier).state = false;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

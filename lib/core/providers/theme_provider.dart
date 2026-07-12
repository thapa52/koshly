import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Provides the [SharedPreferences] instance to the app.
///
/// Must be overridden in [ProviderScope] at startup.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden at startup.',
  );
});

/// Manages the app's theme mode (Light, Dark, System).
///
/// Reads and saves the theme preference to [SharedPreferences].
///
/// Usage in widgets:
/// ```dart
/// final themeMode = ref.watch(themeNotifierProvider);
/// ```
///
/// To change theme:
/// ```dart
/// ref.read(themeNotifierProvider.notifier).setThemeMode(ThemeMode.dark);
/// ```
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final savedTheme = prefs.getString(AppConstants.prefThemeMode);
    return _themeModeFromString(savedTheme);
  }

  /// Sets the theme mode and saves to SharedPreferences.
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.prefThemeMode, _themeModeToString(mode));
    state = mode;
  }

  /// Cycles through theme modes: System → Light → Dark → System
  Future<void> toggleTheme() async {
    switch (state) {
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
    }
  }

  /// Converts a string to ThemeMode.
  ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Converts ThemeMode to a string for storage.
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

/// Provider for [ThemeNotifier].
final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

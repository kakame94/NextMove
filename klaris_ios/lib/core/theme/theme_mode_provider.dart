import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-controlled theme override. `system` follows iOS appearance.
enum KlarisThemeMode { system, light, dark }

class _ThemeNotifier extends Notifier<KlarisThemeMode> {
  static const _prefsKey = 'klaris.theme_mode';

  @override
  KlarisThemeMode build() {
    _load();
    return KlarisThemeMode.system;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_prefsKey);
    state = switch (v) {
      'light' => KlarisThemeMode.light,
      'dark'  => KlarisThemeMode.dark,
      _       => KlarisThemeMode.system,
    };
  }

  Future<void> set(KlarisThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }
}

final themeModeProvider = NotifierProvider<_ThemeNotifier, KlarisThemeMode>(_ThemeNotifier.new);

/// Resolves the user override against the platform brightness.
Brightness resolveBrightness(KlarisThemeMode mode, Brightness platform) => switch (mode) {
      KlarisThemeMode.system => platform,
      KlarisThemeMode.light => Brightness.light,
      KlarisThemeMode.dark => Brightness.dark,
    };

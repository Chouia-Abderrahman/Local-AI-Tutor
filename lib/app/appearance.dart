import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// Light, dark, or whatever the phone is set to. Kept in the app settings.
class ThemeModeController extends Notifier<ThemeMode> {
  static const settingKey = 'theme_mode';

  @override
  ThemeMode build() {
    Future.microtask(_load);
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final name = await ref.read(databaseProvider).getSetting(settingKey);
    final mode = ThemeMode.values.where((m) => m.name == name).firstOrNull;
    if (ref.mounted && mode != null) state = mode;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(databaseProvider).setSetting(settingKey, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

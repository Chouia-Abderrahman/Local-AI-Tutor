import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/appearance.dart';
import '../../app/theme.dart';
import '../../app/ui.dart';
import '../model/model_controllers.dart';
import '../web/web_controllers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(activeModelProvider);
    final installed = ref.watch(installedModelsProvider).value ?? const [];
    final web = ref.watch(webSettingsProvider).value;
    final defaultName = model.path == null
        ? null
        : installed.where((m) => m.path == model.path).firstOrNull?.name ??
              model.fileName;
    final modelStatus = switch (model) {
      ActiveModelState(path: null) => 'Not set up',
      _ => '$defaultName · ${plural(installed.length, 'model')} on this phone',
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Tokens.gutter, 0, Tokens.gutter, 32),
        children: [
          const SectionLabel('Appearance'),
          const _ThemePicker(),
          const SectionLabel('AI'),
          PanelList(
            children: [
              PanelRow(
                leading: Icon(Icons.memory, color: context.colors.accent),
                title: const Text('AI models'),
                subtitle: Text(modelStatus),
                trailing: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: context.colors.muted,
                ),
                onTap: () => context.go('/settings/model'),
              ),
            ],
          ),
          const SectionLabel('Web'),
          PanelList(
            children: [
              PanelRow(
                leading: const Icon(Icons.public),
                title: const Text('Web access'),
                subtitle: Text(
                  web?.enabled ?? false
                      ? 'On · each document asks before its first lookup'
                      : 'Off unless you turn it on',
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: context.colors.muted,
                ),
                onTap: () => context.go('/settings/web'),
              ),
            ],
          ),
          const SectionLabel('About'),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Wordmark(),
                const SizedBox(height: 4),
                Text(
                  'Version ${StudyApp.version}',
                  style: context.text.bodySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'Turns your documents into verified study cards, answers '
                  'questions about them and tracks what you know, with an AI '
                  'model that runs on this phone. Your documents never leave '
                  'it; the network is used only to download models and, if '
                  'you allow it, for web lookups.',
                  style: context.text.bodyMedium,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: context.scheme.secondary,
                    ),
                    onPressed: () => showLicensePage(
                      context: context,
                      applicationName: StudyApp.name,
                      applicationVersion: StudyApp.version,
                    ),
                    child: const Text('Open-source licenses'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// System, light or dark.
class _ThemePicker extends ConsumerWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Panel(
      child: SegmentedButton<ThemeMode>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.brightness_auto_outlined, size: 18),
            label: Text('System'),
          ),
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode_outlined, size: 18),
            label: Text('Light'),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode_outlined, size: 18),
            label: Text('Dark'),
          ),
        ],
        selected: {mode},
        onSelectionChanged: (s) =>
            ref.read(themeModeProvider.notifier).set(s.single),
      ),
    );
  }
}

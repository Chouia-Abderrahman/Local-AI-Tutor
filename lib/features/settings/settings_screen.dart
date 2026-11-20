import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../model/model_controllers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(activeModelProvider);
    final modelStatus = switch (model) {
      ActiveModelState(path: null) => 'Not set up',
      ActiveModelState(phase: ModelPhase.ready) => '${model.fileName} · ready',
      ActiveModelState(phase: ModelPhase.loading) =>
        '${model.fileName} · loading',
      ActiveModelState(phase: ModelPhase.failed) =>
        '${model.fileName} · failed to load',
      _ => '${model.fileName} · not loaded',
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.memory),
            title: const Text('AI model'),
            subtitle: Text(modelStatus),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/model'),
          ),
          ListTile(
            leading: const Icon(Icons.travel_explore),
            title: const Text('Web access'),
            subtitle: const Text('Off unless you turn it on'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/web'),
          ),
          const AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: 'PDF Study Assistant',
            applicationVersion: '0.1.0',
            aboutBoxChildren: [
              Text(
                'Turns your documents into verified study questions with an '
                'AI model that runs on this phone.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

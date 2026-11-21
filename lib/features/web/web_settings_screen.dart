import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/ui.dart';
import 'web_controllers.dart';

/// Web access on/off, the optional search server, and every query sent.
class WebSettingsScreen extends ConsumerWidget {
  const WebSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(webSettingsProvider).value ?? const WebSettings();
    final log = ref.watch(webLogProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: const Text('Web access')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Tokens.gutter, 4, Tokens.gutter, 32),
        children: [
          PanelList(
            children: [
              PanelRow(
                leading: const Icon(Icons.public),
                title: const Text('Allow web lookups'),
                subtitle: const Text(
                  'Only when you tap "Check on the web" or "Search the web". '
                  'Each document asks before its first lookup.',
                ),
                trailing: SharpSwitch(
                  value: settings.enabled,
                  onChanged: (on) =>
                      ref.read(webSettingsProvider.notifier).setEnabled(on),
                ),
                onTap: () => ref
                    .read(webSettingsProvider.notifier)
                    .setEnabled(!settings.enabled),
              ),
              PanelRow(
                leading: const Icon(Icons.dns_outlined),
                title: const Text('Search server (optional)'),
                subtitle: Text(
                  settings.searxUrl ??
                      'Wikipedia is always used. Add a SearXNG server you run '
                          'to search the wider web.',
                ),
                trailing: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: context.colors.muted,
                ),
                onTap: () => _editSearx(context, ref, settings.searxUrl),
              ),
            ],
          ),
          SectionLabel(
            'Web activity',
            trailing: log.isEmpty
                ? null
                : TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 24),
                      foregroundColor: context.colors.muted,
                    ),
                    onPressed: () {
                      final db = ref.read(databaseProvider);
                      db.delete(db.webLogEntries).go();
                    },
                    child: const Text('Clear'),
                  ),
          ),
          if (log.isEmpty)
            Panel(
              child: Text(
                'Nothing has been sent. Every search and every page read '
                'shows up here.',
                style: context.text.bodySmall,
              ),
            )
          else
            PanelList(
              children: [
                for (final entry in log)
                  PanelRow(
                    title: Text(
                      '"${entry.query}" → ${entry.provider}',
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '${entry.at.toLocal().toString().substring(0, 16)}'
                      '${_urls(entry.urlsJson)}',
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  static String _urls(String? json) {
    if (json == null) return '';
    final urls = [for (final u in jsonDecode(json) as List) '$u'];
    return urls.isEmpty ? ' · no pages read' : '\n${urls.join('\n')}';
  }

  Future<void> _editSearx(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) async {
    final controller = TextEditingController(text: current ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SearXNG server'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'https://search.example.org',
            helperText: 'Its JSON format must be enabled.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('Remove'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (value == null) return;
    final uri = Uri.tryParse(value.trim());
    final valid =
        value.trim().isEmpty ||
        (uri != null &&
            (uri.isScheme('https') || uri.isScheme('http')) &&
            uri.host.isNotEmpty);
    if (!valid) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('That is not a web address.')),
        );
      }
      return;
    }
    await ref.read(webSettingsProvider.notifier).setSearxUrl(value);
  }
}

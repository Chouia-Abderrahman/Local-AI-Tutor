import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/ui.dart';
import '../../core/llm/installed_model.dart';
import '../../core/llm/model_catalog.dart';
import '../library/library_controllers.dart';
import 'model_controllers.dart';

/// The answer of [showModelPicker]: a model file, or null to use the
/// inherited model (the app default, or the document's).
@immutable
class ModelPick {
  const ModelPick(this.path);

  final String? path;
}

/// Lets the user choose a model among those on the phone.
///
/// [current] is the explicit choice (null: inherited). [inheritLabel] names
/// what null means, such as "App default", and [inheritPath] is the model it
/// stands for now.
Future<ModelPick?> showModelPicker(
  BuildContext context, {
  required String title,
  String? subtitle,
  required String? current,
  required String inheritLabel,
  required String? inheritPath,
}) => showModalBottomSheet<ModelPick>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  builder: (_) => _ModelPicker(
    title: title,
    subtitle: subtitle,
    current: current,
    inheritLabel: inheritLabel,
    inheritPath: inheritPath,
  ),
);

class _ModelPicker extends ConsumerWidget {
  const _ModelPicker({
    required this.title,
    required this.subtitle,
    required this.current,
    required this.inheritLabel,
    required this.inheritPath,
  });

  final String title;
  final String? subtitle;
  final String? current;
  final String inheritLabel;
  final String? inheritPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installed = ref.watch(installedModelsProvider);
    final loaded = ref.watch(activeModelProvider.select((s) => s.loadedPath));
    final ram = ref.watch(totalMemoryProvider).value;
    final recommended = recommendedModel(ram);

    Widget check(bool on) => on
        ? Icon(Icons.check, size: 20, color: context.scheme.onSurface)
        : const SizedBox(width: 20);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 12),
          children: [
            SheetHeader(
              title: title,
              subtitle:
                  subtitle ??
                  'One model runs at a time; switching takes a few seconds.',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Tokens.gutter),
              child: switch (installed) {
                AsyncData(:final value) when value.isEmpty => EmptyState(
                  icon: Icons.memory,
                  title: 'No model on this phone yet',
                  body: 'Download one in Settings → AI models.',
                  action: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/settings/model');
                    },
                    child: const Text('Get a model'),
                  ),
                ),
                AsyncData(:final value) => PanelList(
                  children: [
                    PanelRow(
                      leading: const Icon(Icons.subdirectory_arrow_right),
                      title: Text(inheritLabel),
                      subtitle: Text(
                        inheritPath == null
                            ? 'No model set'
                            : modelDisplayName(inheritPath!),
                      ),
                      trailing: check(current == null),
                      onTap: () =>
                          Navigator.pop(context, const ModelPick(null)),
                    ),
                    for (final model in value)
                      PanelRow(
                        leading: const Icon(Icons.memory),
                        title: Text(model.name),
                        subtitle: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(formatBytes(model.sizeBytes)),
                            if (model.spec?.id == recommended.id)
                              const Tag('Recommended', tone: TagTone.accent),
                            if (model.path == loaded)
                              const Tag('In memory', tone: TagTone.success),
                            if (model.copiedIn) const Tag('Copied in'),
                          ],
                        ),
                        trailing: check(current == model.path),
                        onTap: () =>
                            Navigator.pop(context, ModelPick(model.path)),
                      ),
                  ],
                ),
                AsyncError(:final error) => Text('$error'),
                _ => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('Manage models'),
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/settings/model');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A short note on where a model choice comes from, for model chips.
String modelOriginNote(ModelOrigin origin) => switch (origin) {
  ModelOrigin.conversation => '',
  ModelOrigin.document => '· document',
  ModelOrigin.appDefault => '· default',
};

/// Lets the user choose the model of a document.
Future<void> pickDocumentModel(
  BuildContext context,
  WidgetRef ref,
  int documentId,
) async {
  final documents = ref.read(documentsProvider).value ?? const [];
  final document = documents.where((d) => d.id == documentId).firstOrNull;
  final pick = await showModelPicker(
    context,
    title: 'Model for this document',
    subtitle:
        'Writes its questions and answers its new conversations. Each '
        'conversation can still choose its own.',
    current: document?.modelPath,
    inheritLabel: 'App default',
    inheritPath: ref.read(activeModelProvider).path,
  );
  if (pick == null) return;
  await ref.read(modelResolverProvider).setDocumentModel(documentId, pick.path);
}

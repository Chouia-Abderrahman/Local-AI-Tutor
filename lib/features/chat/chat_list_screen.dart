import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/ui.dart';
import '../../core/chat/chat_service.dart';
import '../../core/db/database.dart';
import '../../core/llm/installed_model.dart';
import '../library/library_controllers.dart';
import 'chat_controllers.dart';

/// The chat inbox: every conversation, across documents, the most recently
/// active first. Tapping one opens it; "New" starts one about a document.
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(allChatsProvider);
    final documents = (ref.watch(documentsProvider).value ?? const [])
        .where((d) => d.status == 'ready')
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      floatingActionButton: documents.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _startNew(context, ref, documents),
              icon: const Icon(Icons.add_comment_outlined, size: 20),
              label: const Text('New chat'),
            ),
      body: switch (chats) {
        AsyncData(:final value) when value.isEmpty => EmptyState(
          icon: Icons.chat_bubble_outline,
          title: documents.isEmpty
              ? 'Nothing to talk about yet'
              : 'No conversations yet',
          body: documents.isEmpty
              ? 'Import a document in the Library, then ask about it here.'
              : 'Ask a question about one of your documents. Your '
                    'conversations are listed here, newest first.',
          action: documents.isEmpty
              ? null
              : FilledButton.icon(
                  onPressed: () => _startNew(context, ref, documents),
                  icon: const Icon(Icons.add_comment_outlined, size: 20),
                  label: const Text('Start a chat'),
                ),
        ),
        AsyncData(:final value) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            Tokens.gutter,
            4,
            Tokens.gutter,
            96,
          ),
          itemCount: value.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _ConversationTile(entry: value[i]),
        ),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Future<void> _startNew(
    BuildContext context,
    WidgetRef ref,
    List<StudyDocument> documents,
  ) async {
    final id = documents.length == 1
        ? documents.single.id
        : await showModalBottomSheet<int>(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (sheet) => SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(sheet).height * 0.7,
                ),
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 12),
                  children: [
                    const SheetHeader(title: 'Chat about'),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Tokens.gutter,
                      ),
                      child: PanelList(
                        children: [
                          for (final d in documents)
                            PanelRow(
                              leading: const Icon(Icons.description_outlined),
                              title: Text(
                                d.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => Navigator.pop(sheet, d.id),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
    if (id == null || !context.mounted) return;
    ref.read(chatDocumentProvider.notifier).select(id);
    await ref.read(chatControllerProvider.notifier).newConversation(id);
    if (context.mounted) context.go('/chat/conversation');
  }
}

class _ConversationTile extends ConsumerWidget {
  const _ConversationTile({required this.entry});

  final ChatListEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = entry.info;
    final colors = context.colors;
    return Panel(
      onTap: () {
        ref.read(chatDocumentProvider.notifier).select(entry.documentId);
        ref
            .read(chatControllerProvider.notifier)
            .openConversation(entry.documentId, info.thread.id);
        context.go('/chat/conversation');
      },
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.accentSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              color: colors.accent,
              size: 21,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.thread.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 13,
                      color: colors.muted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        entry.documentTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    if (info.lastAt != null) timeAgo(info.lastAt!),
                    plural(info.messageCount, 'message'),
                    if (info.thread.modelPath != null)
                      modelDisplayName(info.thread.modelPath!),
                  ].join(' · '),
                  style: context.text.labelSmall?.copyWith(letterSpacing: 0.2),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: colors.muted),
        ],
      ),
    );
  }
}

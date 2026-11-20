import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/chat/chat_service.dart';
import '../../core/db/database.dart';
import '../library/library_controllers.dart';
import '../web/web_controllers.dart';
import 'chat_controllers.dart';

/// Chat about one document, answered from its passages with citations.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final documents = (ref.watch(documentsProvider).value ?? const [])
        .where((d) => d.status == 'ready')
        .toList();
    final selected = ref.watch(chatDocumentProvider);
    final documentId = documents.any((d) => d.id == selected)
        ? selected
        : documents.firstOrNull?.id;
    final chat = ref.watch(chatControllerProvider);
    final controller = ref.read(chatControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          if (documentId != null)
            IconButton(
              tooltip: 'New chat',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: chat.busy ? null : () => controller.clear(documentId),
            ),
        ],
      ),
      body: documentId == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Import a document in the Library to chat about it.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                if (documents.length > 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: DropdownButtonFormField<int>(
                      initialValue: documentId,
                      decoration: const InputDecoration(
                        labelText: 'Document',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        for (final d in documents)
                          DropdownMenuItem(value: d.id, child: Text(d.title)),
                      ],
                      onChanged: chat.busy
                          ? null
                          : ref.read(chatDocumentProvider.notifier).select,
                    ),
                  ),
                Expanded(
                  child: _Messages(
                    documentId: documentId,
                    scroll: _scroll,
                    onChange: _scrollToEnd,
                  ),
                ),
                if (chat.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      chat.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                _Composer(
                  input: _input,
                  busy: chat.busy,
                  mode: chat.mode,
                  onMode: controller.setMode,
                  onStop: controller.stop,
                  onSend: () {
                    final text = _input.text;
                    _input.clear();
                    controller.send(documentId, text);
                    _scrollToEnd();
                  },
                ),
              ],
            ),
    );
  }
}

class _Messages extends ConsumerWidget {
  const _Messages({
    required this.documentId,
    required this.scroll,
    required this.onChange,
  });

  final int documentId;
  final ScrollController scroll;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thread = ref.watch(chatThreadProvider(documentId)).value;
    if (thread == null) return const SizedBox.shrink();
    final messages = ref.watch(chatMessagesProvider(thread)).value ?? const [];
    final chat = ref.watch(chatControllerProvider);
    ref.listen(chatMessagesProvider(thread), (_, _) => onChange());
    ref.listen(
      chatControllerProvider.select((s) => s.streaming),
      (_, _) => onChange(),
    );

    if (messages.isEmpty && !chat.busy) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Ask anything about this document. Answers come from its text, '
            'with the pages they rely on.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView(
      controller: scroll,
      padding: const EdgeInsets.all(16),
      children: [
        for (final (i, m) in messages.indexed)
          m.role == 'user'
              ? _UserBubble(text: m.content)
              : _AssistantBubble(
                  documentId: documentId,
                  message: m,
                  question: i > 0 ? messages[i - 1].content : '',
                ),
        if (chat.busy)
          _AssistantBubble.streaming(
            text: chat.streaming.isEmpty ? '…' : chat.streaming,
          ),
      ],
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12, left: 48),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text),
    ),
  );
}

class _AssistantBubble extends ConsumerWidget {
  const _AssistantBubble({
    required this.documentId,
    required this.message,
    required this.question,
  }) : streamingText = null;

  const _AssistantBubble.streaming({required String text})
    : documentId = 0,
      message = null,
      question = '',
      streamingText = text;

  final int documentId;
  final ChatMessage? message;
  final String question;
  final String? streamingText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final text = streamingText ?? message!.content;
    final meta = ReplyMeta.fromJson(message?.citationsJson);
    final unsupported = meta.unsupported.toSet();
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    final cited = {
      for (final m in RegExp(r'\[(\d+)\]').allMatches(text))
        int.parse(m.group(1)!),
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 24),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  for (final s in sentences)
                    TextSpan(
                      text: '$s ',
                      style: unsupported.contains(s)
                          ? TextStyle(color: theme.colorScheme.outline)
                          : null,
                    ),
                ],
              ),
            ),
            if (unsupported.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Grayed sentences are not backed by your document.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            if (meta.notFound)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Your document does not seem to cover this.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    if (message != null && question.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.travel_explore, size: 18),
                        label: const Text('Search the web'),
                        onPressed: () async {
                          if (!await ensureWebAllowed(
                            context,
                            ref,
                            documentId,
                          )) {
                            return;
                          }
                          await ref
                              .read(chatControllerProvider.notifier)
                              .searchWeb(documentId, question);
                        },
                      ),
                  ],
                ),
              ),
            if (message?.usedWeb ?? false) ...[
              const SizedBox(height: 6),
              Text(
                'From the web, not your document',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.tertiary,
                ),
              ),
              // Several passages can come from one page: list pages once.
              for (final page in {
                for (final w in meta.webSources)
                  w.url: [
                    for (final x in meta.webSources)
                      if (x.url == w.url) x,
                  ],
              }.values)
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: page.first.url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied.')),
                    );
                  },
                  child: Text(
                    '[${page.map((w) => 'W${w.number}').join(', ')}] '
                    '${page.first.title}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
            if (message != null && meta.citations.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in meta.citations)
                    if (cited.isEmpty || cited.contains(c.number))
                      ActionChip(
                        visualDensity: VisualDensity.compact,
                        label: Text('[${c.number}] ${c.pages}'),
                        tooltip: c.headingPath,
                        onPressed: () => context.go(
                          '/library/doc/$documentId/section/${c.sectionId}',
                        ),
                      ),
                ],
              ),
            ],
            if (message != null &&
                !meta.notFound &&
                !message!.usedWeb &&
                question.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                  label: const Text('Save as card'),
                  onPressed: () async {
                    final id = await ref
                        .read(chatRepositoryProvider)
                        .saveAsCard(
                          question: question,
                          answer: message!.content,
                          citations: meta.citations,
                        );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          id == null
                              ? "Couldn't find a sentence in the document that "
                                    'supports this answer.'
                              : 'Saved as a flashcard. It will come up in '
                                    'Study.',
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.input,
    required this.busy,
    required this.mode,
    required this.onMode,
    required this.onSend,
    required this.onStop,
  });

  final TextEditingController input;
  final bool busy;
  final ChatMode mode;
  final void Function(ChatMode mode) onMode;
  final VoidCallback onSend;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<ChatMode>(
              segments: [
                for (final m in ChatMode.values)
                  ButtonSegment(value: m, label: Text(m.label)),
              ],
              selected: {mode},
              showSelectedIcon: false,
              onSelectionChanged: busy ? null : (s) => onMode(s.single),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: input,
                    enabled: !busy,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    decoration: const InputDecoration(
                      hintText: 'Ask about the document',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                busy
                    ? IconButton(
                        tooltip: 'Stop',
                        icon: const Icon(Icons.stop_circle_outlined),
                        onPressed: onStop,
                      )
                    : IconButton(
                        tooltip: 'Send',
                        icon: const Icon(Icons.send),
                        onPressed: onSend,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens the chat about [documentId].
void openChat(BuildContext context, WidgetRef ref, StudyDocument document) {
  ref.read(chatDocumentProvider.notifier).select(document.id);
  context.go('/chat');
}

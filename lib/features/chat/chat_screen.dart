import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/ui.dart';
import '../../core/chat/chat_service.dart';
import '../../core/db/database.dart';
import '../../core/llm/installed_model.dart';
import '../../core/text/markup.dart';
import '../library/library_controllers.dart';
import '../model/model_controllers.dart';
import '../model/model_picker.dart';
import '../web/web_controllers.dart';
import 'chat_controllers.dart';

/// Conversations about one document, answered from its passages with
/// citations. Each conversation can use its own model.
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

  Future<void> _send(int documentId, int threadId, [String? text]) async {
    final question = (text ?? _input.text).trim();
    if (question.isEmpty) return;
    _input.clear();
    _scrollToEnd();
    final asked = await ref
        .read(chatControllerProvider.notifier)
        .send(documentId, threadId, question);
    // Couldn't ask (no model, for one): give the question back.
    if (!asked && mounted && _input.text.isEmpty) _input.text = question;
  }

  @override
  Widget build(BuildContext context) {
    final documents = (ref.watch(documentsProvider).value ?? const [])
        .where((d) => d.status == 'ready')
        .toList();
    final selected = ref.watch(chatDocumentProvider);
    final document =
        documents.where((d) => d.id == selected).firstOrNull ??
        documents.firstOrNull;
    final chat = ref.watch(chatControllerProvider);

    if (document == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const EmptyState(
          icon: Icons.chat_bubble_outline,
          title: 'Nothing to talk about yet',
          body: 'Import a document in the Library, then ask about it here.',
        ),
      );
    }

    final threadId = ref.watch(chatThreadProvider(document.id)).value;
    final threads =
        ref.watch(chatThreadsProvider(document.id)).value ?? const [];
    final thread = threads
        .where((t) => t.thread.id == threadId)
        .firstOrNull
        ?.thread;
    final controller = ref.read(chatControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: Tokens.gutter,
        title: InkWell(
          borderRadius: BorderRadius.circular(Tokens.radius),
          onTap: () => _showConversations(context, document),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  thread == null ||
                          thread.title == ChatRepository.newTitle ||
                          thread.title == 'Chat'
                      ? 'New conversation'
                      : thread.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.expand_more, size: 20, color: context.colors.muted),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Conversations',
            icon: const Icon(Icons.forum_outlined, size: 21),
            onPressed: () => _showConversations(context, document),
          ),
          IconButton(
            tooltip: 'New conversation',
            icon: const Icon(Icons.add_comment_outlined, size: 21),
            onPressed: chat.busy
                ? null
                : () => controller.newConversation(document.id),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(41),
          child: Container(
            height: 41,
            padding: const EdgeInsets.fromLTRB(Tokens.gutter, 0, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: _DocumentSwitch(
                    document: document,
                    others: documents.length > 1,
                    enabled: !chat.busy,
                  ),
                ),
                const SizedBox(width: 8),
                if (threadId != null)
                  _ConversationModelChip(
                    documentId: document.id,
                    threadId: threadId,
                    enabled: !chat.busy,
                  ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const Divider(),
          Expanded(
            child: threadId == null
                ? const SizedBox.shrink()
                : _Messages(
                    document: document,
                    threadId: threadId,
                    scroll: _scroll,
                    onChange: _scrollToEnd,
                    onSuggestion: (text) => _send(document.id, threadId, text),
                  ),
          ),
          if (chat.error != null)
            Container(
              width: double.infinity,
              color: context.scheme.errorContainer,
              padding: const EdgeInsets.symmetric(
                horizontal: Tokens.gutter,
                vertical: 8,
              ),
              child: Text(
                chat.error!,
                style: context.text.bodySmall?.copyWith(
                  color: context.scheme.onErrorContainer,
                ),
              ),
            ),
          _Composer(
            input: _input,
            busy: chat.busy,
            mode: chat.mode,
            onMode: controller.setMode,
            onStop: controller.stop,
            onSend: threadId == null
                ? null
                : () => _send(document.id, threadId),
          ),
        ],
      ),
    );
  }

  Future<void> _showConversations(
    BuildContext context,
    StudyDocument document,
  ) => showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _ConversationsSheet(document: document),
  );
}

/// The document the chat is about; tapping it switches documents.
class _DocumentSwitch extends ConsumerWidget {
  const _DocumentSwitch({
    required this.document,
    required this.others,
    required this.enabled,
  });

  final StudyDocument document;
  final bool others;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.description_outlined, size: 15, color: context.colors.muted),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            document.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelMedium?.copyWith(
              color: context.colors.muted,
            ),
          ),
        ),
        if (others)
          Icon(Icons.unfold_more, size: 14, color: context.colors.muted),
      ],
    );
    if (!others) return Align(alignment: Alignment.centerLeft, child: label);
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        borderRadius: BorderRadius.circular(Tokens.radius),
        onTap: enabled ? () => _pick(context, ref) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: label,
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final documents = (ref.read(documentsProvider).value ?? const [])
        .where((d) => d.status == 'ready')
        .toList();
    final id = await showModalBottomSheet<int>(
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
                padding: const EdgeInsets.symmetric(horizontal: Tokens.gutter),
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
                        trailing: d.id == document.id
                            ? const Icon(Icons.check, size: 20)
                            : null,
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
    if (id != null) ref.read(chatDocumentProvider.notifier).select(id);
  }
}

/// The conversation's model; tapping it chooses another.
class _ConversationModelChip extends ConsumerWidget {
  const _ConversationModelChip({
    required this.documentId,
    required this.threadId,
    required this.enabled,
  });

  final int documentId;
  final int threadId;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(
      conversationModelProvider((documentId: documentId, threadId: threadId)),
    );
    final loading = ref.watch(
      activeModelProvider.select(
        (s) => s.phase == ModelPhase.loading && s.targetPath == model.path,
      ),
    );
    return ModelChip(
      name: model.name,
      note: switch (model.origin) {
        ModelOrigin.conversation => null,
        ModelOrigin.document => 'doc',
        ModelOrigin.appDefault => 'default',
      },
      loading: loading,
      onTap: enabled ? () => _pick(context, ref) : null,
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final threads = ref.read(chatThreadsProvider(documentId)).value ?? const [];
    final thread = threads.where((t) => t.thread.id == threadId).firstOrNull;
    final documents = ref.read(documentsProvider).value ?? const [];
    final document = documents.where((d) => d.id == documentId).firstOrNull;
    final inherited = resolveModel(
      document: document?.modelPath,
      appDefault: ref.read(activeModelProvider).path,
    );
    final pick = await showModelPicker(
      context,
      title: 'Model for this conversation',
      current: thread?.thread.modelPath,
      inheritLabel: inherited.origin == ModelOrigin.document
          ? "The document's model"
          : 'App default',
      inheritPath: inherited.path,
    );
    if (pick == null) return;
    await ref
        .read(chatControllerProvider.notifier)
        .setConversationModel(threadId, pick.path);
  }
}

class _ConversationsSheet extends ConsumerWidget {
  const _ConversationsSheet({required this.document});

  final StudyDocument document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(chatThreadsProvider(document.id)).value ?? [];
    final current = ref.watch(chatThreadProvider(document.id)).value;
    final controller = ref.read(chatControllerProvider.notifier);
    final busy = ref.watch(chatControllerProvider.select((s) => s.busy));
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(
            Tokens.gutter,
            0,
            Tokens.gutter,
            12,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Conversations', style: context.text.titleLarge),
                      Text(
                        document.title,
                        style: context.text.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () async {
                          await controller.newConversation(document.id);
                          if (context.mounted) Navigator.pop(context);
                        },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PanelList(
              children: [
                for (final info in threads)
                  PanelRow(
                    leading: Icon(
                      info.thread.id == current
                          ? Icons.chat_bubble
                          : Icons.chat_bubble_outline,
                      size: 18,
                      color: info.thread.id == current
                          ? context.colors.accent
                          : null,
                    ),
                    title: Text(
                      info.messageCount == 0
                          ? 'New conversation'
                          : info.thread.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      [
                        plural(info.messageCount, 'message'),
                        if (info.lastAt != null) _ago(info.lastAt!),
                        if (info.thread.modelPath != null)
                          modelDisplayName(info.thread.modelPath!),
                      ].join(' · '),
                    ),
                    trailing: IconButton(
                      tooltip: 'Delete conversation',
                      icon: Icon(
                        Icons.delete_outline,
                        size: 19,
                        color: context.colors.muted,
                      ),
                      onPressed: busy
                          ? null
                          : () => _confirmDelete(context, ref, info),
                    ),
                    onTap: busy
                        ? null
                        : () {
                            controller.openConversation(
                              document.id,
                              info.thread.id,
                            );
                            Navigator.pop(context);
                          },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ChatThreadInfo info,
  ) async {
    final ok =
        info.messageCount == 0 ||
        await showDialog<bool>(
              context: context,
              builder: (dialog) => AlertDialog(
                title: const Text('Delete this conversation?'),
                content: Text(
                  '"${info.thread.title}" and its '
                  '${plural(info.messageCount, 'message')} are deleted. '
                  'Cards you saved from it stay.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialog, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialog, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ==
            true;
    if (!ok) return;
    await ref
        .read(chatControllerProvider.notifier)
        .deleteConversation(document.id, info.thread.id);
  }

  static String _ago(DateTime at) {
    final d = DateTime.now().difference(at.toLocal());
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes} min ago';
    if (d.inDays < 1) return '${d.inHours} h ago';
    if (d.inDays < 7) return '${plural(d.inDays, 'day')} ago';
    final local = at.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}

class _Messages extends ConsumerWidget {
  const _Messages({
    required this.document,
    required this.threadId,
    required this.scroll,
    required this.onChange,
    required this.onSuggestion,
  });

  final StudyDocument document;
  final int threadId;
  final ScrollController scroll;
  final VoidCallback onChange;
  final void Function(String text) onSuggestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages =
        ref.watch(chatMessagesProvider(threadId)).value ?? const [];
    final chat = ref.watch(chatControllerProvider);
    final model = ref.watch(
      conversationModelProvider((documentId: document.id, threadId: threadId)),
    );
    ref.listen(chatMessagesProvider(threadId), (_, _) => onChange());
    ref.listen(
      chatControllerProvider.select((s) => s.streaming),
      (_, _) => onChange(),
    );

    if (messages.isEmpty && !chat.busy) {
      return _EmptyConversation(
        document: document,
        modelName: model.name,
        onSuggestion: onSuggestion,
      );
    }
    return ListView(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(Tokens.gutter, 16, Tokens.gutter, 8),
      children: [
        for (final (i, m) in messages.indexed)
          m.role == 'user'
              ? _UserMessage(text: m.content)
              : _AssistantMessage(
                  documentId: document.id,
                  threadId: threadId,
                  message: m,
                  question: i > 0 ? messages[i - 1].content : '',
                ),
        if (chat.busy) _PendingReply(text: chat.streaming, model: model),
      ],
    );
  }
}

class _EmptyConversation extends ConsumerWidget {
  const _EmptyConversation({
    required this.document,
    required this.modelName,
    required this.onSuggestion,
  });

  final StudyDocument document;
  final String modelName;
  final void Function(String text) onSuggestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outline = ref.watch(documentOutlineProvider(document.id)).value;
    final topics = [
      for (final s in outline?.sections ?? const [])
        if (!s.isSkipped && s.studyChunks > 0)
          s.section.title.replaceFirst(RegExp(r'^[\d.]+\s+'), ''),
    ].take(3).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(Tokens.gutter, 32, Tokens.gutter, 16),
      children: [
        const Center(child: AppMark(size: 40, badge: true)),
        const SizedBox(height: 16),
        Text(
          'Ask about ${document.title}',
          style: context.text.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Answers come from the document and cite the passages they use. '
          'Written on this phone by $modelName.',
          style: context.text.bodySmall,
          textAlign: TextAlign.center,
        ),
        if (topics.isNotEmpty) ...[
          const SectionLabel('Try', padding: EdgeInsets.fromLTRB(2, 28, 2, 8)),
          PanelList(
            children: [
              for (final topic in topics)
                PanelRow(
                  leading: Icon(
                    Icons.north_east,
                    size: 16,
                    color: context.colors.accent,
                  ),
                  title: Text(
                    'Explain $topic',
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => onSuggestion('Explain $topic'),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _UserMessage extends StatelessWidget {
  const _UserMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.82,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: context.scheme.primary,
          borderRadius: BorderRadius.circular(Tokens.radius),
        ),
        child: SelectableText(
          text,
          style: context.text.bodyMedium?.copyWith(
            color: context.scheme.onPrimary,
          ),
        ),
      ),
    ),
  );
}

/// Who is answering: the mark and the model's name.
class _ReplyHeader extends StatelessWidget {
  const _ReplyHeader({required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        const AppMark(size: 16, badge: true),
        const SizedBox(width: 8),
        Text(label, style: context.text.labelMedium),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    ),
  );
}

class _PendingReply extends ConsumerWidget {
  const _PendingReply({required this.text, required this.model});

  final String text;
  final ResolvedModel model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(
      activeModelProvider.select((s) => s.phase == ModelPhase.loading),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReplyHeader(label: model.name),
          if (text.isEmpty)
            Row(
              children: [
                const SizedBox.square(
                  dimension: 12,
                  child: CircularProgressIndicator(strokeWidth: 1.6),
                ),
                const SizedBox(width: 8),
                Text(
                  loading ? 'Loading ${model.name}…' : 'Reading the passages…',
                  style: context.text.bodySmall,
                ),
              ],
            )
          else
            Text.rich(
              TextSpan(children: _bold(text)),
              style: context.text.bodyMedium,
            ),
        ],
      ),
    );
  }
}

class _AssistantMessage extends ConsumerWidget {
  const _AssistantMessage({
    required this.documentId,
    required this.threadId,
    required this.message,
    required this.question,
  });

  final int documentId;
  final int threadId;
  final ChatMessage message;
  final String question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = message.content;
    final meta = ReplyMeta.fromJson(message.citationsJson);
    final unsupported = meta.unsupported.toSet();
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    final cited = {
      for (final m in RegExp(r'\[(\d+)\]').allMatches(text))
        int.parse(m.group(1)!),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReplyHeader(
            label: message.usedWeb ? 'From the web' : 'From your document',
            trailing: message.usedWeb
                ? const Tag('Web', tone: TagTone.accent, icon: Icons.public)
                : null,
          ),
          Text.rich(
            TextSpan(
              children: [
                for (final s in sentences)
                  TextSpan(
                    children: _bold('$s '),
                    style: unsupported.contains(s)
                        ? TextStyle(
                            color: context.colors.muted,
                            decoration: TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.dotted,
                            decorationColor: context.colors.muted,
                          )
                        : null,
                  ),
              ],
            ),
            style: context.text.bodyMedium,
          ),
          if (unsupported.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Dotted sentences are not backed by your document.',
                style: context.text.bodySmall,
              ),
            ),
          if (meta.citations.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final c in meta.citations)
                  if (cited.isEmpty || cited.contains(c.number))
                    _CitationChip(
                      label: '[${c.number}] ${c.pages}',
                      tooltip: c.headingPath,
                      onTap: () => context.go(
                        '/library/doc/$documentId/section/${c.sectionId}',
                      ),
                    ),
              ],
            ),
          ],
          if (message.usedWeb)
            for (final page in {
              for (final w in meta.webSources)
                w.url: [
                  for (final x in meta.webSources)
                    if (x.url == w.url) x,
                ],
            }.values)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: _CitationChip(
                  label:
                      '[${page.map((w) => 'W${w.number}').join(', ')}] '
                      '${page.first.title}',
                  tooltip: page.first.url,
                  icon: Icons.link,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: page.first.url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied.')),
                    );
                  },
                ),
              ),
          if (meta.notFound && !message.usedWeb) ...[
            const SizedBox(height: 8),
            Panel(
              padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
              color: context.scheme.surfaceContainer,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your document does not seem to cover this.',
                      style: context.text.bodySmall,
                    ),
                  ),
                  if (question.isNotEmpty)
                    TextButton.icon(
                      icon: const Icon(Icons.travel_explore, size: 17),
                      label: const Text('Search the web'),
                      onPressed: () async {
                        if (!await ensureWebAllowed(context, ref, documentId)) {
                          return;
                        }
                        await ref
                            .read(chatControllerProvider.notifier)
                            .searchWeb(documentId, threadId, question);
                      },
                    ),
                ],
              ),
            ),
          ],
          if (!meta.notFound && !message.usedWeb && question.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  _ReplyAction(
                    icon: Icons.copy_outlined,
                    label: 'Copy',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Answer copied.')),
                      );
                    },
                  ),
                  _ReplyAction(
                    icon: Icons.bookmark_add_outlined,
                    label: 'Save as card',
                    onTap: () => _saveAsCard(context, ref, meta),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveAsCard(
    BuildContext context,
    WidgetRef ref,
    ReplyMeta meta,
  ) async {
    final id = await ref
        .read(chatRepositoryProvider)
        .saveAsCard(
          question: question,
          answer: message.content,
          citations: meta.citations,
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          id == null
              ? "Couldn't find a sentence in the document that supports this "
                    'answer.'
              : 'Saved as a flashcard. It will come up in Study.',
        ),
      ),
    );
  }
}

class _CitationChip extends StatelessWidget {
  const _CitationChip({
    required this.label,
    required this.onTap,
    this.tooltip,
    this.icon,
  });

  final String label;
  final String? tooltip;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final chip = Material(
      color: context.scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
        side: BorderSide(color: context.scheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon ?? Icons.menu_book_outlined,
                size: 13,
                color: context.colors.accent,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return tooltip == null ? chip : Tooltip(message: tooltip!, child: chip);
  }
}

class _ReplyAction extends StatelessWidget {
  const _ReplyAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    style: TextButton.styleFrom(
      foregroundColor: context.colors.muted,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      minimumSize: const Size(0, 30),
    ),
    icon: Icon(icon, size: 16),
    label: Text(label, style: context.text.labelMedium),
    onPressed: onTap,
  );
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
  final VoidCallback? onSend;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.scheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: context.colors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (final m in ChatMode.values) ...[
                    _ModeToggle(
                      label: m.label,
                      selected: m == mode,
                      onTap: busy ? null : () => onMode(m),
                    ),
                    const SizedBox(width: 6),
                  ],
                  const Spacer(),
                  Text(
                    'Answers cite your document',
                    style: context.text.bodySmall?.copyWith(fontSize: 11.5),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: input,
                      enabled: !busy,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend?.call(),
                      decoration: const InputDecoration(
                        hintText: 'Ask about the document',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox.square(
                    dimension: 42,
                    child: busy
                        ? IconButton.outlined(
                            tooltip: 'Stop',
                            icon: const Icon(Icons.stop, size: 20),
                            onPressed: onStop,
                          )
                        : IconButton.filled(
                            tooltip: 'Send',
                            icon: const Icon(Icons.arrow_upward, size: 20),
                            onPressed: onSend,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected
        ? context.scheme.secondaryContainer
        : context.scheme.surfaceContainerLowest,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(3),
      side: BorderSide(
        color: selected ? context.colors.accent : context.scheme.outline,
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          label,
          style: context.text.labelMedium?.copyWith(
            color: selected ? context.scheme.onSecondaryContainer : null,
          ),
        ),
      ),
    ),
  );
}

/// Opens the chat about [document].
void openChat(BuildContext context, WidgetRef ref, StudyDocument document) {
  ref.read(chatDocumentProvider.notifier).select(document.id);
  context.go('/chat');
}

/// `**bold**` in a reply, as bold text.
List<InlineSpan> _bold(String text) => [
  for (final segment in boldSegments(text))
    TextSpan(
      text: segment.text,
      style: segment.bold ? const TextStyle(fontWeight: FontWeight.w600) : null,
    ),
];

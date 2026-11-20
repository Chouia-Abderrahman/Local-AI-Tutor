import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/chat/chat_service.dart';
import '../../core/chat/retrieval.dart';
import '../../core/db/database.dart';
import '../../core/llm/llm_engine.dart';
import '../../core/web/search.dart';
import '../generate/generate_controllers.dart';
import '../model/model_controllers.dart';
import '../web/web_controllers.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(ref.watch(databaseProvider)),
);

final retrieverProvider = Provider<Retriever>(
  (ref) => Retriever(ref.watch(databaseProvider)),
);

/// The document the chat is about.
class ChatDocument extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? documentId) => state = documentId;
}

final chatDocumentProvider = NotifierProvider<ChatDocument, int?>(
  ChatDocument.new,
);

final chatThreadProvider = FutureProvider.family<int, int>(
  (ref, documentId) => ref.watch(chatRepositoryProvider).threadFor(documentId),
);

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, int>(
  (ref, threadId) => ref.watch(chatRepositoryProvider).watchMessages(threadId),
);

@immutable
class ChatState {
  const ChatState({
    this.busy = false,
    this.streaming = '',
    this.error,
    this.mode = ChatMode.ask,
  });

  final bool busy;

  /// The reply being written.
  final String streaming;
  final String? error;
  final ChatMode mode;

  ChatState copyWith({
    bool? busy,
    String? streaming,
    String? Function()? error,
    ChatMode? mode,
  }) => ChatState(
    busy: busy ?? this.busy,
    streaming: streaming ?? this.streaming,
    error: error == null ? this.error : error(),
    mode: mode ?? this.mode,
  );
}

class ChatController extends Notifier<ChatState> {
  StreamSubscription<LlmChunk>? _subscription;

  @override
  ChatState build() {
    ref.onDispose(() => _subscription?.cancel());
    return const ChatState();
  }

  void setMode(ChatMode mode) => state = state.copyWith(mode: mode);

  Future<void> send(int documentId, String question) async {
    final text = question.trim();
    if (text.isEmpty || state.busy) return;
    state = state.copyWith(busy: true, streaming: '', error: () => null);

    if (!await ref.read(activeModelProvider.notifier).ensureLoaded()) {
      if (ref.mounted) {
        state = state.copyWith(
          busy: false,
          error: () => 'Load an AI model first (Settings → AI model).',
        );
      }
      return;
    }

    // The chat is in the foreground: background generation steps aside
    // (its current step is cancelled and retried later) and resumes after.
    final runner = ref.read(generationRunnerProvider);
    final yielded = runner.state.working && !runner.state.paused;
    if (yielded) {
      runner.pause();
      ref.read(llmEngineProvider).cancel();
      await runner.idle();
    }
    try {
      await _answer(documentId, text);
    } finally {
      if (yielded) runner.resume();
    }
  }

  Future<void> _answer(int documentId, String text) async {
    final repo = ref.read(chatRepositoryProvider);
    final db = ref.read(databaseProvider);
    final threadId = await repo.threadFor(documentId);
    final history = await repo.messages(threadId);
    await repo.add(threadId, 'user', text);

    // Follow-ups ("why?") need the previous question to find passages.
    final retriever = ref.read(retrieverProvider);
    var excerpts = await retriever.search(documentId, text, limit: 3);
    final lastUser = history.where((m) => m.role == 'user').lastOrNull;
    if (excerpts.isEmpty && lastUser != null) {
      excerpts = await retriever.search(
        documentId,
        '${lastUser.content} $text',
        limit: 3,
      );
    }
    final document = await (db.select(
      db.documents,
    )..where((d) => d.id.equals(documentId))).getSingle();

    final messages = chatMessages(
      question: text,
      excerpts: excerpts,
      history: history,
      mode: state.mode,
      language: document.language,
    );
    final buffer = StringBuffer();
    final sinceFlush = Stopwatch()..start();
    final done = Completer<void>();
    _subscription = ref
        .read(llmEngineProvider)
        .stream(
          messages,
          params: LlmParams(
            maxTokens: state.mode == ChatMode.explain ? 450 : 260,
            temperature: 0.3,
          ),
        )
        .listen(
          (chunk) {
            buffer.write(chunk.text);
            if (sinceFlush.elapsedMilliseconds > 50 && ref.mounted) {
              state = state.copyWith(streaming: buffer.toString());
              sinceFlush.reset();
            }
          },
          onError: (Object error) {
            if (ref.mounted) state = state.copyWith(error: () => '$error');
            if (!done.isCompleted) done.complete();
          },
          onDone: () {
            if (!done.isCompleted) done.complete();
          },
        );
    await done.future;
    _subscription = null;

    final reply = buffer.toString().trim();
    if (reply.isNotEmpty) {
      final grounding = checkGrounding(reply, excerpts);
      final meta = ReplyMeta(
        citations: [
          for (final (i, e) in excerpts.indexed) Citation.fromExcerpt(i + 1, e),
        ],
        unsupported: [
          for (final s in grounding)
            if (!s.supported) s.text,
        ],
        notFound:
            excerpts.isEmpty ||
            saysNotFound(reply) ||
            mostlyUnsupported(grounding),
      );
      await repo.add(threadId, 'assistant', reply, meta: meta.toJson());
    }
    if (ref.mounted) state = state.copyWith(busy: false, streaming: '');
  }

  /// Answers [question] from the web (Wikipedia, and the user's search
  /// server if set). The caller has already asked the user's permission.
  Future<void> searchWeb(int documentId, String question) async {
    if (state.busy) return;
    state = state.copyWith(busy: true, streaming: '', error: () => null);
    final runner = ref.read(generationRunnerProvider);
    final yielded = runner.state.working && !runner.state.paused;
    if (yielded) {
      runner.pause();
      ref.read(llmEngineProvider).cancel();
      await runner.idle();
    }
    try {
      if (!await ref.read(activeModelProvider.notifier).ensureLoaded()) {
        throw LlmException('Load an AI model first (Settings → AI model).');
      }
      final db = ref.read(databaseProvider);
      final web = ref.read(webClientProvider);
      final query = searchQueryFor(question);
      final document = await (db.select(
        db.documents,
      )..where((d) => d.id.equals(documentId))).getSingle();
      final passages = <WebPassage>[];
      for (final provider in await ref.read(searchProvidersProvider.future)) {
        final read = <String>[];
        try {
          for (final hit in (await provider.search(
            query,
            language: document.language,
          )).take(3)) {
            final text = hit.text ?? (await web.fetchPage(hit.url)).text;
            read.add(hit.url);
            passages.addAll(
              rankPassages(question, text, title: hit.title, url: hit.url),
            );
          }
        } on Object {
          // Try the next provider.
        }
        await logWebQuery(
          db,
          query: query,
          provider: provider.name,
          urls: read,
        );
        if (passages.length >= 2) break;
      }
      passages.sort((a, b) => b.score.compareTo(a.score));
      final best = passages.take(3).toList();
      final repo = ref.read(chatRepositoryProvider);
      final threadId = await repo.threadFor(documentId);
      if (best.isEmpty) {
        await repo.add(
          threadId,
          'assistant',
          'The web search found nothing useful for this question.',
          usedWeb: true,
        );
        return;
      }
      final reply = await ref
          .read(llmEngineProvider)
          .complete(
            webChatMessages(
              question: question,
              passages: [for (final p in best) (title: p.title, text: p.text)],
              language: document.language,
            ),
            params: const LlmParams(maxTokens: 260, temperature: 0.3),
          );
      await repo.add(
        threadId,
        'assistant',
        reply.text,
        usedWeb: true,
        meta: ReplyMeta(
          citations: const [],
          unsupported: const [],
          notFound: false,
          webSources: [
            for (final (i, p) in best.indexed)
              WebSource(number: i + 1, title: p.title, url: p.url),
          ],
        ).toJson(),
      );
    } on Object catch (error) {
      if (ref.mounted) state = state.copyWith(error: () => '$error');
    } finally {
      if (yielded) runner.resume();
      if (ref.mounted) state = state.copyWith(busy: false, streaming: '');
    }
  }

  void stop() {
    ref.read(llmEngineProvider).cancel();
    unawaited(_subscription?.cancel());
  }

  Future<void> clear(int documentId) async {
    final repo = ref.read(chatRepositoryProvider);
    await repo.clear(await repo.threadFor(documentId));
  }
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(
  ChatController.new,
);

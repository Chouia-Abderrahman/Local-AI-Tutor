import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/chat/chat_service.dart';
import '../../core/chat/retrieval.dart';
import '../../core/db/database.dart';
import '../../core/llm/llm_engine.dart';
import '../../core/web/search.dart';
import '../library/library_controllers.dart';
import '../model/model_controllers.dart';
import '../model/model_use.dart';
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

/// The conversation open for each document. A document without an entry
/// shows its most recent conversation.
class ChatThreadChoice extends Notifier<Map<int, int>> {
  @override
  Map<int, int> build() => const {};

  void select(int documentId, int threadId) =>
      state = {...state, documentId: threadId};

  void forget(int documentId) => state = {...state}..remove(documentId);
}

final chatThreadChoiceProvider =
    NotifierProvider<ChatThreadChoice, Map<int, int>>(ChatThreadChoice.new);

/// A document's conversations, newest activity first.
final chatThreadsProvider = StreamProvider.family<List<ChatThreadInfo>, int>(
  (ref, documentId) =>
      ref.watch(chatRepositoryProvider).watchThreads(documentId),
);

/// The conversation shown for a document.
final chatThreadProvider = FutureProvider.family<int, int>((
  ref,
  documentId,
) async {
  final repo = ref.watch(chatRepositoryProvider);
  final chosen = ref.watch(
    chatThreadChoiceProvider.select((choices) => choices[documentId]),
  );
  if (chosen != null && await repo.thread(chosen) != null) return chosen;
  return repo.threadFor(documentId);
});

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, int>(
  (ref, threadId) => ref.watch(chatRepositoryProvider).watchMessages(threadId),
);

/// The model a conversation answers with: its own choice, the document's,
/// or the app default.
final conversationModelProvider =
    Provider.family<ResolvedModel, ({int documentId, int threadId})>((
      ref,
      key,
    ) {
      final threads =
          ref.watch(chatThreadsProvider(key.documentId)).value ?? const [];
      final thread = threads
          .where((t) => t.thread.id == key.threadId)
          .firstOrNull
          ?.thread;
      final documents = ref.watch(documentsProvider).value ?? const [];
      final document = documents
          .where((d) => d.id == key.documentId)
          .firstOrNull;
      return resolveModel(
        conversation: thread?.modelPath,
        document: document?.modelPath,
        appDefault: ref.watch(activeModelProvider.select((s) => s.path)),
      );
    });

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
  Completer<void>? _replyDone;

  @override
  ChatState build() {
    ref.onDispose(() => _subscription?.cancel());
    return const ChatState();
  }

  void setMode(ChatMode mode) => state = state.copyWith(mode: mode);

  /// Answers [question] in conversation [threadId]. False when the question
  /// couldn't even be asked (no model, for one), so the screen can give the
  /// text back to the user.
  Future<bool> send(int documentId, int threadId, String question) async {
    final text = question.trim();
    if (text.isEmpty || state.busy) return false;
    state = state.copyWith(busy: true, streaming: '', error: () => null);
    var asked = false;
    try {
      await ref
          .read(modelUseProvider)
          .run(
            title: 'Writing an answer',
            detail: ChatRepository.titleFrom(text),
            documentId: documentId,
            threadId: threadId,
            body: (engine) async {
              asked = true;
              await _answer(engine, documentId, threadId, text);
            },
          );
      return true;
    } on Object catch (error) {
      if (ref.mounted) state = state.copyWith(error: () => '$error');
      return asked;
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false, streaming: '');
    }
  }

  Future<void> _answer(
    LlmEngine engine,
    int documentId,
    int threadId,
    String text,
  ) async {
    final repo = ref.read(chatRepositoryProvider);
    final db = ref.read(databaseProvider);
    final history = await repo.messages(threadId);
    await repo.add(threadId, 'user', text);
    if (history.isEmpty) {
      final thread = await repo.thread(threadId);
      if (thread != null &&
          (thread.title == ChatRepository.newTitle || thread.title == 'Chat')) {
        await repo.rename(threadId, ChatRepository.titleFrom(text));
      }
    }

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
    final done = _replyDone = Completer<void>();
    _subscription = engine
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
            if (error is! LlmCancelledException && ref.mounted) {
              state = state.copyWith(error: () => '$error');
            }
            if (!done.isCompleted) done.complete();
          },
          onDone: () {
            if (!done.isCompleted) done.complete();
          },
        );
    await done.future;
    _subscription = null;
    _replyDone = null;

    // A stopped reply keeps what was written so far.
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
  }

  /// Answers [question] from the web (Wikipedia, and the user's search
  /// server if set). The caller has already asked the user's permission.
  Future<void> searchWeb(int documentId, int threadId, String question) async {
    if (state.busy) return;
    state = state.copyWith(busy: true, streaming: '', error: () => null);
    try {
      await ref
          .read(modelUseProvider)
          .run(
            title: 'Searching the web',
            detail: ChatRepository.titleFrom(question),
            documentId: documentId,
            threadId: threadId,
            body: (engine) =>
                _searchWeb(engine, documentId, threadId, question),
          );
    } on Object catch (error) {
      if (ref.mounted) state = state.copyWith(error: () => '$error');
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false, streaming: '');
    }
  }

  Future<void> _searchWeb(
    LlmEngine engine,
    int documentId,
    int threadId,
    String question,
  ) async {
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
      await logWebQuery(db, query: query, provider: provider.name, urls: read);
      if (passages.length >= 2) break;
    }
    passages.sort((a, b) => b.score.compareTo(a.score));
    final best = passages.take(3).toList();
    final repo = ref.read(chatRepositoryProvider);
    if (best.isEmpty) {
      await repo.add(
        threadId,
        'assistant',
        'The web search found nothing useful for this question.',
        usedWeb: true,
      );
      return;
    }
    final reply = await engine.complete(
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
  }

  /// Stops the reply being written; what it wrote so far is kept.
  void stop() {
    ref.read(llmEngineProvider).cancel();
    unawaited(_subscription?.cancel());
    final done = _replyDone;
    if (done != null && !done.isCompleted) done.complete();
  }

  /// Opens a fresh conversation about [documentId].
  Future<void> newConversation(int documentId) async {
    final id = await ref.read(chatRepositoryProvider).newThread(documentId);
    ref.read(chatThreadChoiceProvider.notifier).select(documentId, id);
  }

  void openConversation(int documentId, int threadId) =>
      ref.read(chatThreadChoiceProvider.notifier).select(documentId, threadId);

  Future<void> deleteConversation(int documentId, int threadId) async {
    await ref.read(chatRepositoryProvider).deleteThread(threadId);
    if (ref.read(chatThreadChoiceProvider)[documentId] == threadId) {
      ref.read(chatThreadChoiceProvider.notifier).forget(documentId);
    }
    ref.invalidate(chatThreadProvider(documentId));
  }

  /// Sets the model of conversation [threadId] (null: the document's).
  Future<void> setConversationModel(int threadId, String? path) =>
      ref.read(modelResolverProvider).setThreadModel(threadId, path);
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(
  ChatController.new,
);

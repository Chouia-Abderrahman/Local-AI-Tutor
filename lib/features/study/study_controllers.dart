import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsrs/fsrs.dart' as fsrs;

import '../../app/providers.dart';
import '../../core/study/study_repository.dart';

final studyRepositoryProvider = Provider<StudyRepository>(
  (ref) => StudyRepository(ref.watch(databaseProvider)),
);

/// Due and new counts; `null` document means all documents. Invalidated
/// when a session ends.
final studyOverviewProvider = FutureProvider.family<StudyOverview, int?>(
  (ref, documentId) =>
      ref.watch(studyRepositoryProvider).overview(documentId: documentId),
);

enum SessionPhase { loading, empty, asking, answered, finished }

@immutable
class SessionState {
  const SessionState({
    this.phase = SessionPhase.loading,
    this.queue = const [],
    this.index = 0,
    this.options = const [],
    this.chosen,
    this.previews = const {},
    this.typed = '',
    this.typedCorrect,
    this.revealed = false,
    this.rated = false,
    this.reviewed = 0,
    this.correct = 0,
  });

  final SessionPhase phase;
  final List<StudyItem> queue;
  final int index;

  /// Shuffled options of the current multiple-choice question.
  final List<String> options;
  final int? chosen;

  /// When the current fact would come back after each answer.
  final Map<fsrs.Rating, Duration> previews;
  final String typed;
  final bool? typedCorrect;

  /// The answer of a flashcard or cloze card is shown.
  final bool revealed;

  /// The current item's review has been recorded.
  final bool rated;
  final int reviewed;
  final int correct;

  StudyItem? get current => index < queue.length ? queue[index] : null;

  int? get correctOption {
    final item = current;
    if (item == null) return null;
    final i = options.indexOf(item.question.answer);
    return i < 0 ? null : i;
  }

  SessionState copyWith({
    SessionPhase? phase,
    List<StudyItem>? queue,
    int? index,
    List<String>? options,
    int? Function()? chosen,
    Map<fsrs.Rating, Duration>? previews,
    String? typed,
    bool? Function()? typedCorrect,
    bool? revealed,
    bool? rated,
    int? reviewed,
    int? correct,
  }) => SessionState(
    phase: phase ?? this.phase,
    queue: queue ?? this.queue,
    index: index ?? this.index,
    options: options ?? this.options,
    chosen: chosen == null ? this.chosen : chosen(),
    previews: previews ?? this.previews,
    typed: typed ?? this.typed,
    typedCorrect: typedCorrect == null ? this.typedCorrect : typedCorrect(),
    revealed: revealed ?? this.revealed,
    rated: rated ?? this.rated,
    reviewed: reviewed ?? this.reviewed,
    correct: correct ?? this.correct,
  );
}

class SessionController extends Notifier<SessionState> {
  final _random = math.Random();
  DateTime _shownAt = DateTime.now();

  @override
  SessionState build() => const SessionState();

  StudyRepository get _repo => ref.read(studyRepositoryProvider);

  Future<void> start({int? documentId, int? sectionId}) async {
    state = const SessionState();
    final queue = await _repo.buildSession(
      documentId: documentId,
      sectionId: sectionId,
    );
    if (!ref.mounted) return;
    if (queue.isEmpty) {
      state = const SessionState(phase: SessionPhase.empty);
      return;
    }
    _show(SessionState(queue: queue), 0);
  }

  void _show(SessionState base, int index) {
    _shownAt = DateTime.now();
    final item = index < base.queue.length ? base.queue[index] : null;
    if (item == null) {
      state = base.copyWith(phase: SessionPhase.finished, index: index);
      return;
    }
    final options = item.question.type == 'mcq'
        ? ([item.question.answer, ...item.distractors]..shuffle(_random))
        : const <String>[];
    state = SessionState(
      phase: SessionPhase.asking,
      queue: base.queue,
      index: index,
      options: options,
      reviewed: base.reviewed,
      correct: base.correct,
    );
    unawaited(_loadPreviews(item, index));
  }

  /// Fills in the "back in 4 days" labels of the answer buttons.
  Future<void> _loadPreviews(StudyItem item, int index) async {
    final previews = await _repo.previewDelays(item.fact.id);
    if (!ref.mounted || state.index != index || state.current != item) return;
    state = state.copyWith(previews: previews);
  }

  /// Picking an option turns the card over. A wrong pick is "Again" and is
  /// recorded at once. A right pick waits for the learner to say how sure
  /// they were: a lucky guess out of four is not the same as knowing it.
  Future<void> choose(int option) async {
    final item = state.current;
    if (item == null || state.phase != SessionPhase.asking) return;
    final ms = _elapsedMs();
    final correct = option == state.correctOption;
    state = state.copyWith(phase: SessionPhase.answered, chosen: () => option);
    if (!correct) {
      await _record(fsrs.Rating.again, correct: false, ms: ms);
    }
  }

  void setTyped(String text) => state = state.copyWith(typed: text);

  /// Checks a typed cloze answer: right is Good, wrong is Again.
  Future<void> checkTyped() async {
    final item = state.current;
    if (item == null || state.phase != SessionPhase.asking) return;
    final ms = _elapsedMs();
    final correct = typedAnswerMatches(state.typed, item.question.answer);
    state = state.copyWith(
      phase: SessionPhase.answered,
      typedCorrect: () => correct,
      revealed: true,
    );
    await _record(
      correct ? fsrs.Rating.good : fsrs.Rating.again,
      correct: correct,
      ms: ms,
    );
  }

  /// Shows a flashcard's (or untyped cloze card's) answer for self-rating.
  void reveal() {
    if (state.phase != SessionPhase.asking) return;
    state = state.copyWith(phase: SessionPhase.answered, revealed: true);
  }

  /// The learner's own grade of a flashcard, a cloze they revealed, or a
  /// right multiple-choice pick. Records it and moves on to the next card.
  Future<void> rate(fsrs.Rating rating) async {
    if (state.rated || state.phase != SessionPhase.answered) return;
    await _record(
      rating,
      correct: rating != fsrs.Rating.again,
      unsure: rating == fsrs.Rating.hard,
      ms: _elapsedMs(),
    );
    if (ref.mounted) next();
  }

  Future<void> _record(
    fsrs.Rating rating, {
    required bool correct,
    required int ms,
    bool unsure = false,
  }) async {
    final item = state.current!;
    final outcome = await _repo.recordReview(
      factId: item.fact.id,
      questionId: item.question.id,
      rating: rating,
      correct: correct,
      unsure: unsure,
      responseMs: ms,
    );
    var queue = state.queue;
    if (rating == fsrs.Rating.again &&
        outcome.dueSoon(DateTime.now().toUtc())) {
      // Missed: ask it again a few cards later in this session, worded
      // differently when another question exists. Cards answered right
      // come back in a later session when FSRS says they are due.
      final again = await _repo.nextItemFor(
        item.fact.id,
        avoidQuestionId: item.question.id,
      );
      if (again != null) {
        final at = math.min(state.index + 4, queue.length);
        queue = [...queue]..insert(at, again);
      }
    }
    if (!ref.mounted) return;
    state = state.copyWith(
      rated: true,
      queue: queue,
      reviewed: state.reviewed + 1,
      correct: state.correct + (correct ? 1 : 0),
    );
  }

  void next() {
    if (!state.rated) return;
    _show(state, state.index + 1);
    if (state.phase == SessionPhase.finished) {
      ref.invalidate(studyOverviewProvider);
    }
  }

  /// Reports the current question; with [factIsWrong] the fact leaves the
  /// schedule. Moves on without recording a review.
  Future<void> report({bool factIsWrong = false}) async {
    final item = state.current;
    if (item == null) return;
    await _repo.report(item.question.id, factIsWrong: factIsWrong);
    if (!ref.mounted) return;
    final queue = [
      for (final (i, q) in state.queue.indexed)
        if (i <= state.index ||
            (factIsWrong
                ? q.fact.id != item.fact.id
                : q.question.id != item.question.id))
          q,
    ];
    _show(state.copyWith(queue: queue), state.index + 1);
  }

  int _elapsedMs() => DateTime.now().difference(_shownAt).inMilliseconds;
}

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

/// Code checks on generated items. Every rejection reason has a code so the
/// rejection log and the eval report can count them.
library;

import '../ingest/language.dart';
import '../text/matching.dart';

enum CheckFailure {
  empty,
  tooLong,
  quoteNotFound,
  duplicateFact,
  answerNotGrounded,
  answerInQuestion,
  distractorCount,
  distractorEqualsAnswer,
  distractorContainsAnswer,
  distractorTrueInSource,
  distractorsSimilar,
  allOfTheAbove,
  lengthBias,
  duplicateQuestion,
  languageMismatch,
  blindMismatch,
  critiqueRejected;

  /// Soft failures can be repaired by the critique step (Thorough and up);
  /// at lower qualities they reject like the others.
  bool get soft =>
      this == CheckFailure.lengthBias ||
      this == CheckFailure.distractorsSimilar ||
      this == CheckFailure.blindMismatch;

  String get description => switch (this) {
    CheckFailure.empty => 'A field is empty.',
    CheckFailure.tooLong => 'Too long to work as a study question.',
    CheckFailure.quoteNotFound => 'The quote is not in the passage.',
    CheckFailure.duplicateFact => 'Repeats another fact.',
    CheckFailure.answerNotGrounded => "The answer isn't backed by the source.",
    CheckFailure.answerInQuestion => 'The question gives away the answer.',
    CheckFailure.distractorCount => 'Needs exactly three wrong answers.',
    CheckFailure.distractorEqualsAnswer => 'A wrong answer equals the answer.',
    CheckFailure.distractorContainsAnswer =>
      'A wrong answer contains the right one.',
    CheckFailure.distractorTrueInSource =>
      'A wrong answer is something the passage says is true.',
    CheckFailure.distractorsSimilar => 'Two wrong answers say the same thing.',
    CheckFailure.allOfTheAbove => 'Uses "all/none of the above".',
    CheckFailure.lengthBias => 'The right answer is much longer than the rest.',
    CheckFailure.duplicateQuestion => 'Repeats another question.',
    CheckFailure.languageMismatch => "Not written in the document's language.",
    CheckFailure.blindMismatch =>
      'Answering it from the passage gave a different option.',
    CheckFailure.critiqueRejected =>
      'The review found a problem it could not fix.',
  };
}

const _maxQuestionChars = 320;
const _maxAnswerChars = 160;

/// Checks a flashcard written with a fact.
List<CheckFailure> checkFlashcard({
  required String front,
  required String back,
  required String quote,
  required String statement,
}) {
  final failures = <CheckFailure>[];
  if (front.trim().isEmpty || back.trim().isEmpty) {
    return [CheckFailure.empty];
  }
  if (front.length > _maxQuestionChars || back.length > _maxAnswerChars) {
    failures.add(CheckFailure.tooLong);
  }
  if (coverage(back, '$quote $statement') < 0.6) {
    failures.add(CheckFailure.answerNotGrounded);
  }
  if (_givesAway(front, back)) failures.add(CheckFailure.answerInQuestion);
  return failures;
}

/// Checks a multiple-choice question against its fact and passage.
List<CheckFailure> checkMcq({
  required String question,
  required String answer,
  required List<String> distractors,
  required String quote,
  required String statement,
  required String passage,
  String? language,
  bool requireGrounding = true,
  Iterable<String> otherQuestions = const [],
}) {
  final failures = <CheckFailure>{};
  if (question.trim().isEmpty ||
      answer.trim().isEmpty ||
      distractors.any((d) => d.trim().isEmpty)) {
    failures.add(CheckFailure.empty);
  }
  if (question.length > _maxQuestionChars ||
      answer.length > _maxAnswerChars ||
      distractors.any((d) => d.length > _maxAnswerChars)) {
    failures.add(CheckFailure.tooLong);
  }
  if (distractors.length != 3) failures.add(CheckFailure.distractorCount);

  // Apply/analyze answers may be inferences; the blind check covers them.
  if (requireGrounding &&
      coverage(answer, '$quote $statement') < 0.6 &&
      coverage(answer, passage) < 0.8) {
    failures.add(CheckFailure.answerNotGrounded);
  }
  if (_givesAway(question, answer)) failures.add(CheckFailure.answerInQuestion);

  final normalizedAnswer = normalizeForMatch(answer);
  final normalizedPassage = normalizeForMatch(passage);
  for (final (i, distractor) in distractors.indexed) {
    final normalized = normalizeForMatch(distractor);
    // Order-aware: "lower to higher" and "higher to lower" differ.
    if (normalized == normalizedAnswer ||
        sequenceSimilarity(distractor, answer) >= 0.9) {
      failures.add(CheckFailure.distractorEqualsAnswer);
    }
    if (contentWords(answer).isNotEmpty &&
        normalizedAnswer.length >= 3 &&
        containsPhrase(distractor, answer)) {
      failures.add(CheckFailure.distractorContainsAnswer);
    }
    if (RegExp(
      r'\b(all|none|both|neither) of (the|these)\b',
      caseSensitive: false,
    ).hasMatch(distractor)) {
      failures.add(CheckFailure.allOfTheAbove);
    }
    // A wrong answer copied from the passage is usually a true statement.
    // (A reversed one, the classic misconception, is a good wrong answer,
    // hence the order-aware comparison.)
    if (contentWords(distractor).length >= 4 &&
        (normalizedPassage.contains(normalized) ||
            sequenceSimilarity(distractor, quote) >= 0.8)) {
      failures.add(CheckFailure.distractorTrueInSource);
    }
    for (final other in distractors.skip(i + 1)) {
      final a = normalizeForMatch(other);
      if (a == normalized || sequenceSimilarity(distractor, other) >= 0.8) {
        failures.add(CheckFailure.distractorsSimilar);
      }
    }
  }

  if (distractors.isNotEmpty) {
    final mean =
        distractors.fold<int>(0, (n, d) => n + d.length) / distractors.length;
    if (answer.length > mean * 1.6 && answer.length - mean > 15) {
      failures.add(CheckFailure.lengthBias);
    }
  }

  final combined = '$question $answer';
  for (final other in otherQuestions) {
    if (similarity(combined, other) >= 0.8) {
      failures.add(CheckFailure.duplicateQuestion);
      break;
    }
  }

  if (language != null && language != 'und') {
    final detected = detectLanguage(
      '$question $answer ${distractors.join(' ')}',
    );
    if (detected != 'und' && detected != language) {
      failures.add(CheckFailure.languageMismatch);
    }
  }
  return failures.toList();
}

/// True when the question already states the answer.
bool _givesAway(String question, String answer) {
  final words = contentWords(answer);
  if (words.isEmpty) return false;
  if (words.length == 1) return containsPhrase(question, answer.trim());
  return coverage(answer, question) >= 0.8;
}

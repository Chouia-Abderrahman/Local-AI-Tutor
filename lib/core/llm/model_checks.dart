import 'llm_engine.dart';

/// Passage used by the model checks. Written for this app.
const String samplePassage =
    'Osmosis is the movement of water across a selectively permeable '
    'membrane, from a region where water is more concentrated to a region '
    'where it is less concentrated. Put another way, water moves toward the '
    'side with the higher concentration of dissolved particles, called '
    'solutes. The membrane lets water molecules pass but blocks most solutes, '
    'so the solutes cannot spread out to even the difference themselves.\n\n'
    "Cell membranes behave this way, which is why a cell's surroundings "
    'matter so much. A solution with a lower solute concentration than the '
    "cell's cytoplasm is called hypotonic. In a hypotonic solution, water "
    'flows into the cell and the cell swells. Animal cells, which lack a cell '
    'wall, can burst. A solution with a higher solute concentration is called '
    'hypertonic; water leaves the cell and it shrinks. When the '
    'concentrations on both sides are equal, the solution is isotonic and '
    'there is no net movement of water, although individual molecules still '
    'cross in both directions.\n\n'
    'Plant cells handle hypotonic conditions better than animal cells. Their '
    'rigid cell wall pushes back against the swelling vacuole, creating turgor '
    'pressure, which keeps stems and leaves firm. When a plant loses too much '
    'water, turgor pressure drops and the plant wilts. In a strongly '
    'hypertonic solution, the cell membrane pulls away from the wall, a '
    'process called plasmolysis.\n\n'
    'Osmosis is a form of passive transport: it needs no energy from the '
    'cell, because water moves down its own concentration gradient. This '
    'distinguishes it from active transport, in which the cell spends energy, '
    'usually in the form of ATP, to move substances against their '
    'concentration gradient.';

/// JSON schema for one multiple-choice question. The evidence comes first so
/// the model commits to a source sentence before it writes the question.
/// Lengths are checked in code rather than in the schema, so a long answer
/// gets a clear rejection reason instead of a slow constrained retry.
const Map<String, Object?> mcqSchema = {
  'type': 'object',
  'properties': {
    'quote': {'type': 'string'},
    'question': {'type': 'string'},
    'answer': {'type': 'string'},
    'distractors': {
      'type': 'array',
      'items': {'type': 'string'},
      'minItems': 3,
      'maxItems': 3,
    },
    'explanation': {'type': 'string'},
  },
  'required': ['quote', 'question', 'answer', 'distractors', 'explanation'],
  'additionalProperties': false,
};

class SpeedResult {
  const SpeedResult({
    required this.readTokensPerSecond,
    required this.writeTokensPerSecond,
    required this.firstQuestion,
    required this.nextQuestion,
    required this.cachedPromptShare,
    required this.question,
  });

  /// How fast the model reads a prompt.
  final double readTokensPerSecond;

  /// How fast the model writes its reply.
  final double writeTokensPerSecond;

  /// Time for a question about a passage the model hasn't read yet.
  final Duration firstQuestion;

  /// Time for another question about the same passage, which reuses the
  /// cached passage.
  final Duration nextQuestion;

  /// Share of the second question's prompt served from the cache (0 to 1),
  /// or null when the runtime doesn't report it.
  final double? cachedPromptShare;

  /// The first question written during the test.
  final QuestionCheck question;
}

/// Reading and writing speed, in tokens per second.
class QuickSpeed {
  const QuickSpeed({
    required this.readTokensPerSecond,
    required this.writeTokensPerSecond,
  });

  final double readTokensPerSecond;
  final double writeTokensPerSecond;
}

class QuestionCheck {
  const QuestionCheck({
    required this.json,
    required this.problems,
    required this.elapsed,
    this.usage,
    this.usedGrammar = false,
  });

  final Map<String, Object?> json;
  final List<String> problems;
  final Duration elapsed;
  final LlmUsage? usage;

  /// The fast plain-text attempt failed and the slow constrained retry ran.
  final bool usedGrammar;

  bool get ok => problems.isEmpty;
}

/// Quick checks that a loaded model works for this app: structured output,
/// prompt-prefix reuse, and speed. Used by the Model Lab screen and the
/// on-laptop model test.
class ModelChecks {
  ModelChecks(this.engine);

  final LlmEngine engine;

  static const String _system =
      'You write study questions from a textbook passage. Use only facts '
      'stated in the passage. Write in the language of the passage.';

  static List<LlmMessage> questionMessages(String focus) => [
    const LlmMessage.system(_system),
    LlmMessage.user(
      'Passage:\n"""\n$samplePassage\n"""\n\n'
      'Write one multiple-choice question about $focus in the passage. '
      'First copy, word for word, the one sentence from the passage that '
      'supports the answer. Then give the question, the correct answer, three '
      'wrong but plausible answers, and a one-sentence explanation.',
    ),
  ];

  Future<QuestionCheck> question({String focus = 'a key fact'}) async {
    final watch = Stopwatch()..start();
    final result = await engine.completeJson(
      questionMessages(focus),
      schema: mcqSchema,
      params: const LlmParams(maxTokens: 400, temperature: 0.3),
    );
    watch.stop();
    return QuestionCheck(
      json: result.json,
      problems: basicQuestionProblems(result.json, samplePassage),
      elapsed: watch.elapsed,
      usage: result.usage,
      usedGrammar: result.usedGrammar,
    );
  }

  Future<SpeedResult> speed({void Function(String step)? onStep}) async {
    onStep?.call('Warming up');
    await engine.complete(const [
      LlmMessage.user('Reply with OK.'),
    ], params: const LlmParams(maxTokens: 4, temperature: 0));

    onStep?.call('Measuring reading speed');
    final read = await engine.complete(
      const [
        LlmMessage.user(
          'Read this passage, then reply with the single word "done".'
          '\n\n$samplePassage',
        ),
      ],
      params: const LlmParams(
        maxTokens: 3,
        temperature: 0,
        reusePromptPrefix: false,
      ),
    );

    onStep?.call('Measuring writing speed');
    final write = await engine.complete(const [
      LlmMessage.user(
        'Write a long, detailed paragraph about how a public library '
        'organizes its books.',
      ),
    ], params: const LlmParams(maxTokens: 96, temperature: 0.7));

    onStep?.call('Writing a question');
    final first = await question(focus: 'a key fact');
    onStep?.call('Writing a second question on the same passage');
    final second = await question(focus: 'a different key fact');

    return SpeedResult(
      readTokensPerSecond:
          read.perf?.promptTokensPerSecond ??
          _rate(read.usage?.promptTokens, read.usage?.duration),
      writeTokensPerSecond:
          write.perf?.generationTokensPerSecond ??
          _rate(write.usage?.completionTokens, write.usage?.duration),
      firstQuestion: first.elapsed,
      nextQuestion: second.elapsed,
      cachedPromptShare: _share(second.usage),
      question: first,
    );
  }

  /// Reading and writing speed only: three short requests, fast enough to
  /// run on every backend in a row.
  Future<QuickSpeed> quickSpeed({void Function(String step)? onStep}) async {
    onStep?.call('Warming up');
    await engine.complete(const [
      LlmMessage.user('Reply with OK.'),
    ], params: const LlmParams(maxTokens: 4, temperature: 0));

    onStep?.call('Reading');
    final read = await engine.complete(
      const [
        LlmMessage.user(
          'Read this passage, then reply with the single word "done".'
          '\n\n$samplePassage',
        ),
      ],
      params: const LlmParams(
        maxTokens: 3,
        temperature: 0,
        reusePromptPrefix: false,
      ),
    );

    onStep?.call('Writing');
    final write = await engine.complete(const [
      LlmMessage.user(
        'Write a long, detailed paragraph about how a public library '
        'organizes its books.',
      ),
    ], params: const LlmParams(maxTokens: 64, temperature: 0.7));

    return QuickSpeed(
      readTokensPerSecond:
          read.perf?.promptTokensPerSecond ??
          _rate(read.usage?.promptTokens, read.usage?.duration),
      writeTokensPerSecond:
          write.perf?.generationTokensPerSecond ??
          _rate(write.usage?.completionTokens, write.usage?.duration),
    );
  }

  static double _rate(int? tokens, Duration? duration) {
    if (tokens == null || duration == null || duration.inMilliseconds == 0) {
      return 0;
    }
    return tokens * 1000 / duration.inMilliseconds;
  }

  static double? _share(LlmUsage? usage) {
    if (usage == null || usage.promptTokens == 0) return null;
    return usage.cachedPromptTokens / usage.promptTokens;
  }
}

/// A few quick sanity checks on a generated question. The full verifier is
/// part of the generation pipeline.
List<String> basicQuestionProblems(
  Map<String, Object?> question,
  String passage,
) {
  final problems = <String>[];
  // Models often wrap the copied sentence in quotation marks.
  final quote = _norm(
    '${question['quote'] ?? ''}',
  ).replaceAll(RegExp('^["\'«»]+|["\'«»]+\$'), '').trim();
  if (quote.isEmpty || !_norm(passage).contains(quote)) {
    problems.add('The quote is not copied exactly from the passage.');
  }
  final answer = _norm('${question['answer'] ?? ''}');
  final distractors = [
    for (final d in (question['distractors'] as List?) ?? const []) _norm('$d'),
  ];
  if (distractors.toSet().length != distractors.length) {
    problems.add('Two wrong answers are the same.');
  }
  if (distractors.contains(answer)) {
    problems.add('A wrong answer is the same as the right one.');
  }
  if (answer.isNotEmpty && _norm('${question['question']}').contains(answer)) {
    problems.add('The question gives away the answer.');
  }
  return problems;
}

String _norm(String text) => text
    .toLowerCase()
    .replaceAll(RegExp('[‘’]'), "'")
    .replaceAll(RegExp('[“”]'), '"')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

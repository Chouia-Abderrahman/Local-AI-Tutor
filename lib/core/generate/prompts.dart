/// Prompts and JSON schemas for each generation stage. Bump
/// [promptVersion] whenever a prompt or schema changes: it is part of the
/// cache key and is stored with every question.
library;

import '../llm/llm_engine.dart';
import 'profile.dart';

const int promptVersion = 2;

String languageName(String? code) =>
    const {
      'en': 'English',
      'fr': 'French',
      'es': 'Spanish',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'nl': 'Dutch',
      'ar': 'Arabic',
      'ru': 'Russian',
      'el': 'Greek',
      'he': 'Hebrew',
      'hi': 'Hindi',
      'ja': 'Japanese',
      'ko': 'Korean',
      'zh': 'Chinese',
    }[code] ??
    'the language of the passage';

/// How many facts to ask for: about one per 110 tokens, between 2 and 8.
int factsWanted(int tokens) => (tokens / 110).round().clamp(2, 8);

String _system(String? language) =>
    'You are a careful teacher who writes study material from a textbook '
    'passage. Use only what the passage says; never add facts from your own '
    'knowledge. Write in ${languageName(language)}.';

String _passage(String headingPath, String text) =>
    'Section: $headingPath\nPassage:\n<<<\n$text\n>>>';

// ---------------------------------------------------------------------------
// Stage 1: facts (with a flashcard each).

Map<String, Object?> factsSchema(int maxFacts) => {
  'type': 'object',
  'properties': {
    'facts': {
      'type': 'array',
      'minItems': 1,
      'maxItems': maxFacts,
      'items': {
        'type': 'object',
        'properties': {
          'quote': {'type': 'string'},
          'statement': {'type': 'string'},
          'key_term': {'type': 'string'},
          'importance': {'type': 'integer', 'minimum': 1, 'maximum': 3},
          'front': {'type': 'string'},
          'back': {'type': 'string'},
        },
        'required': [
          'quote',
          'statement',
          'key_term',
          'importance',
          'front',
          'back',
        ],
        'additionalProperties': false,
      },
    },
  },
  'required': ['facts'],
  'additionalProperties': false,
};

List<LlmMessage> factsMessages({
  required String headingPath,
  required String text,
  required String? language,
  required int count,
}) => [
  LlmMessage.system(_system(language)),
  LlmMessage.user(
    '${_passage(headingPath, text)}\n\n'
    'List the $count most important facts a student should learn from this '
    'passage (fewer if it has fewer). For each fact:\n'
    '- quote: copy, word for word, the one sentence of the passage that '
    'states the fact.\n'
    '- statement: the fact in one short sentence of your own.\n'
    '- key_term: the key word or short phrase of the fact (1 to 4 words), '
    'copied exactly from the quote.\n'
    '- importance: 3 = essential, 2 = useful, 1 = detail.\n'
    '- front: a flashcard question about the fact. It must not contain the '
    'answer.\n'
    '- back: the short answer, in a few words.',
  ),
];

// ---------------------------------------------------------------------------
// Stage 2: multiple-choice questions for all facts of a chunk.

/// A fact as the question stage sees it.
class FactBrief {
  const FactBrief({
    required this.statement,
    required this.quote,
    required this.depth,
    this.alreadyAsked = const [],
  });

  final String statement;
  final String quote;
  final Depth depth;

  /// Questions this fact already has, which new ones must not repeat.
  final List<String> alreadyAsked;
}

Map<String, Object?> mcqSchema({
  required int maxQuestions,
  required bool distractorNotes,
}) => {
  'type': 'object',
  'properties': {
    'questions': {
      'type': 'array',
      'minItems': 1,
      'maxItems': maxQuestions,
      'items': {
        'type': 'object',
        'properties': {
          'fact': {'type': 'integer', 'minimum': 1, 'maximum': 50},
          'question': {'type': 'string'},
          'answer': {'type': 'string'},
          'distractors': {
            'type': 'array',
            'items': {'type': 'string'},
            'minItems': 3,
            'maxItems': 3,
          },
          'explanation': {'type': 'string'},
          if (distractorNotes)
            'why_wrong': {
              'type': 'array',
              'items': {'type': 'string'},
              'minItems': 3,
              'maxItems': 3,
            },
        },
        'required': [
          'fact',
          'question',
          'answer',
          'distractors',
          'explanation',
          if (distractorNotes) 'why_wrong',
        ],
        'additionalProperties': false,
      },
    },
  },
  'required': ['questions'],
  'additionalProperties': false,
};

List<LlmMessage> mcqMessages({
  required String headingPath,
  required String text,
  required String? language,
  required List<FactBrief> facts,
  required int perFact,
  required ExplanationLevel explanation,
  String? context,
}) {
  final factList = [
    for (final (i, fact) in facts.indexed)
      '${i + 1}. [${fact.depth.name}] ${fact.statement} '
          '(source: "${fact.quote}")'
          '${fact.alreadyAsked.isEmpty ? '' : '\n   Already asked, so ask something different: ${fact.alreadyAsked.map((q) => '"$q"').join('; ')}'}',
  ].join('\n');
  final depthHelp = {
    for (final fact in facts) fact.depth,
  }.map((d) => '- ${d.name}: ${d.instruction}.').join('\n');
  final explain = switch (explanation) {
    ExplanationLevel.quoteOnly ||
    ExplanationLevel.short => 'one sentence saying why the answer is right',
    ExplanationLevel.full =>
      'two sentences saying why the answer is right, using the passage',
    ExplanationLevel.withDistractors =>
      'two sentences saying why the answer is right; in why_wrong, one short '
          'sentence per wrong answer saying why it is wrong',
  };
  return [
    LlmMessage.system(_system(language)),
    LlmMessage.user(
      '${_passage(headingPath, text)}\n\n'
      '${context == null ? '' : 'Context from the same section, for reference only:\n<<<\n$context\n>>>\n\n'}'
      'Facts from the passage, each with the kind of question wanted:\n'
      '$factList\n\n'
      'Kinds:\n$depthHelp\n\n'
      'For each fact, write $perFact multiple-choice '
      '${perFact == 1 ? 'question' : 'different questions'}, and give the '
      'fact number for each.\n'
      'Rules:\n'
      '- The correct answer must follow from the passage. Keep it short: a '
      'word or a phrase of at most 12 words, not a full sentence copied from '
      'the passage.\n'
      '- Write three wrong answers that are plausible, the same kind of thing '
      'as the correct answer and about as long, but clearly wrong according '
      'to the passage. Never use something the passage says is true as a '
      'wrong answer.\n'
      '- No "all of the above" or "none of the above".\n'
      '- The question must not give away the answer.\n'
      '- explanation: $explain.',
    ),
  ];
}

// ---------------------------------------------------------------------------
// Stage 3: blind answering.

const List<String> optionLetters = ['A', 'B', 'C', 'D'];

/// A question as shown to the blind answerer: options already shuffled.
class BlindItem {
  const BlindItem({required this.question, required this.options});

  final String question;
  final List<String> options;
}

Map<String, Object?> blindSchema(int count) => {
  'type': 'object',
  'properties': {
    'answers': {
      'type': 'array',
      'minItems': count,
      'maxItems': count,
      'items': {
        'type': 'object',
        'properties': {
          'question': {'type': 'integer', 'minimum': 1, 'maximum': 50},
          'choice': {'type': 'string', 'enum': optionLetters},
        },
        'required': ['question', 'choice'],
        'additionalProperties': false,
      },
    },
  },
  'required': ['answers'],
  'additionalProperties': false,
};

List<LlmMessage> blindMessages({
  required String headingPath,
  required String text,
  required String? language,
  required List<BlindItem> items,
}) {
  final questions = [
    for (final (i, item) in items.indexed)
      '${i + 1}. ${item.question}\n'
          '${[for (final (j, option) in item.options.indexed) '${optionLetters[j]}) $option'].join('\n')}',
  ].join('\n\n');
  return [
    LlmMessage.system(_system(language)),
    LlmMessage.user(
      '${_passage(headingPath, text)}\n\n'
      'Answer each question using only the passage. For each question, give '
      'its number and the letter of the best option.\n\n$questions',
    ),
  ];
}

// ---------------------------------------------------------------------------
// Stage 4: critique and rewrite.

class CritiqueItem {
  const CritiqueItem({
    required this.question,
    required this.answer,
    required this.distractors,
    this.knownProblem,
  });

  final String question;
  final String answer;
  final List<String> distractors;
  final String? knownProblem;
}

Map<String, Object?> critiqueSchema(int count) => {
  'type': 'object',
  'properties': {
    'reviews': {
      'type': 'array',
      'minItems': count,
      'maxItems': count,
      'items': {
        'type': 'object',
        'properties': {
          'question': {'type': 'integer', 'minimum': 1, 'maximum': 50},
          'ok': {'type': 'boolean'},
          'problem': {'type': 'string'},
          'fixed_question': {'type': 'string'},
          'fixed_answer': {'type': 'string'},
          'fixed_distractors': {
            'type': 'array',
            'items': {'type': 'string'},
            'minItems': 3,
            'maxItems': 3,
          },
          'fixed_explanation': {'type': 'string'},
        },
        'required': ['question', 'ok', 'problem'],
        'additionalProperties': false,
      },
    },
  },
  'required': ['reviews'],
  'additionalProperties': false,
};

List<LlmMessage> critiqueMessages({
  required String headingPath,
  required String text,
  required String? language,
  required List<CritiqueItem> items,
}) {
  final list = [
    for (final (i, item) in items.indexed)
      '${i + 1}. ${item.question}\n'
          'Correct: ${item.answer}\n'
          'Wrong: ${item.distractors.join(' | ')}'
          '${item.knownProblem == null ? '' : '\nKnown problem: ${item.knownProblem}'}',
  ].join('\n\n');
  return [
    LlmMessage.system(_system(language)),
    LlmMessage.user(
      '${_passage(headingPath, text)}\n\n'
      'Review these multiple-choice questions written from the passage. For '
      'each, check that:\n'
      '- exactly one option is correct according to the passage, and it is '
      'the one marked correct;\n'
      '- the wrong options are plausible but clearly wrong;\n'
      '- the wording is clear and does not give away the answer;\n'
      '- it tests an important idea of the passage.\n'
      'Set ok to true if the question is good, and problem to an empty '
      'string. Otherwise set ok to false, describe the problem, and give a '
      'fixed version in fixed_question, fixed_answer, fixed_distractors and '
      'fixed_explanation.\n\n$list',
    ),
  ];
}

// ---------------------------------------------------------------------------
// More cards for facts that already have some: flashcards and blanks.

/// A fact as the "more cards" stages see it.
class CardFactBrief {
  const CardFactBrief({
    required this.statement,
    required this.quote,
    this.alreadyHave = const [],
  });

  final String statement;
  final String quote;

  /// What the fact already has: flashcard fronts, or blanked words.
  final List<String> alreadyHave;
}

String _cardFacts(List<CardFactBrief> facts, String haveLabel) => [
  for (final (i, fact) in facts.indexed)
    '${i + 1}. ${fact.statement} (source: "${fact.quote}")'
        '${fact.alreadyHave.isEmpty ? '' : '\n   $haveLabel: ${fact.alreadyHave.map((q) => '"$q"').join('; ')}'}',
].join('\n');

Map<String, Object?> flashcardsSchema(int maxCards) => {
  'type': 'object',
  'properties': {
    'cards': {
      'type': 'array',
      'minItems': 1,
      'maxItems': maxCards,
      'items': {
        'type': 'object',
        'properties': {
          'fact': {'type': 'integer', 'minimum': 1, 'maximum': 50},
          'front': {'type': 'string'},
          'back': {'type': 'string'},
        },
        'required': ['fact', 'front', 'back'],
        'additionalProperties': false,
      },
    },
  },
  'required': ['cards'],
  'additionalProperties': false,
};

List<LlmMessage> flashcardsMessages({
  required String headingPath,
  required String text,
  required String? language,
  required List<CardFactBrief> facts,
  required int perFact,
}) => [
  LlmMessage.system(_system(language)),
  LlmMessage.user(
    '${_passage(headingPath, text)}\n\n'
    'Facts from the passage:\n${_cardFacts(facts, 'Flashcards it already has')}\n\n'
    'For each fact, write $perFact new flashcard${perFact == 1 ? '' : 's'}, '
    'giving the fact number for each. Ask about the fact from a different '
    'angle than the flashcards it already has.\n'
    '- front: a question. It must not contain the answer.\n'
    '- back: the short answer, in a few words, that follows from the '
    'passage.',
  ),
];

Map<String, Object?> blanksSchema(int maxTerms) => {
  'type': 'object',
  'properties': {
    'terms': {
      'type': 'array',
      'minItems': 1,
      'maxItems': maxTerms,
      'items': {
        'type': 'object',
        'properties': {
          'fact': {'type': 'integer', 'minimum': 1, 'maximum': 50},
          'term': {'type': 'string'},
        },
        'required': ['fact', 'term'],
        'additionalProperties': false,
      },
    },
  },
  'required': ['terms'],
  'additionalProperties': false,
};

List<LlmMessage> blanksMessages({
  required String headingPath,
  required String text,
  required String? language,
  required List<CardFactBrief> facts,
  required int perFact,
}) => [
  LlmMessage.system(_system(language)),
  LlmMessage.user(
    '${_passage(headingPath, text)}\n\n'
    'Facts from the passage, each with the sentence it comes from:\n'
    '${_cardFacts(facts, 'Words already blanked')}\n\n'
    'For each fact, choose $perFact other key word${perFact == 1 ? '' : 's'} '
    'or short phrase${perFact == 1 ? '' : 's'} (1 to 4 words) that a student '
    'should be able to fill in when it is blanked out of the sentence, and '
    'give the fact number for each.\n'
    '- term: copied exactly from the sentence, appearing in it once.\n'
    '- It must be a meaningful term, not a common word, and different from '
    'the words already blanked.',
  ),
];

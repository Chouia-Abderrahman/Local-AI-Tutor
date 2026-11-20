/// Generation settings: Quality (how careful) and Depth (what is asked).
/// See DESIGN.md section 8.
library;

enum Quality {
  quick('Quick'),
  standard('Standard'),
  thorough('Thorough'),
  deep('Deep');

  const Quality(this.label);

  final String label;

  String get summary => switch (this) {
    Quality.quick => 'Cloze cards and flashcards from verified facts.',
    Quality.standard => 'Adds multiple choice, checked by answering it blind.',
    Quality.thorough => 'Adds a critique that rewrites weak questions.',
    Quality.deep => 'More candidates and a second blind check.',
  };
}

enum Depth {
  recall('Recall'),
  understand('Understand'),
  apply('Apply'),
  analyze('Analyze');

  const Depth(this.label);

  final String label;

  /// The least careful quality that handles this depth reliably.
  Quality get minimumQuality => switch (this) {
    Depth.recall || Depth.understand => Quality.quick,
    Depth.apply => Quality.standard,
    Depth.analyze => Quality.thorough,
  };

  /// Instruction given to the model for questions of this depth.
  String get instruction => switch (this) {
    Depth.recall => 'ask directly for the fact',
    Depth.understand =>
      'check understanding: rephrase the idea, or ask which statement is '
          'correct',
    Depth.apply =>
      'describe a short new situation and ask which option applies the fact',
    Depth.analyze =>
      'ask about a cause, consequence or comparison that links this fact to '
          'other parts of the passage',
  };
}

enum ExplanationLevel { quoteOnly, short, full, withDistractors }

class GenerationProfile {
  const GenerationProfile({
    required this.quality,
    required this.depths,
    required this.multipleChoice,
    required this.candidatesPerFact,
    required this.blindRuns,
    required this.critique,
    required this.neighborContext,
    required this.explanation,
  });

  factory GenerationProfile.preset(
    Quality quality, {
    Set<Depth> depths = const {Depth.recall, Depth.understand},
  }) => switch (quality) {
    Quality.quick => GenerationProfile(
      quality: quality,
      depths: depths,
      multipleChoice: false,
      candidatesPerFact: 1,
      blindRuns: 0,
      critique: false,
      neighborContext: false,
      explanation: ExplanationLevel.quoteOnly,
    ),
    Quality.standard => GenerationProfile(
      quality: quality,
      depths: depths,
      multipleChoice: true,
      candidatesPerFact: 1,
      blindRuns: 1,
      critique: false,
      neighborContext: false,
      explanation: ExplanationLevel.short,
    ),
    Quality.thorough => GenerationProfile(
      quality: quality,
      depths: depths,
      multipleChoice: true,
      candidatesPerFact: 2,
      blindRuns: 1,
      critique: true,
      neighborContext: true,
      explanation: ExplanationLevel.full,
    ),
    Quality.deep => GenerationProfile(
      quality: quality,
      depths: depths,
      multipleChoice: true,
      candidatesPerFact: 3,
      blindRuns: 2,
      critique: true,
      neighborContext: true,
      explanation: ExplanationLevel.withDistractors,
    ),
  }.normalized();

  final Quality quality;
  final Set<Depth> depths;
  final bool multipleChoice;
  final int candidatesPerFact;
  final int blindRuns;
  final bool critique;
  final bool neighborContext;
  final ExplanationLevel explanation;

  /// Depths this quality can handle, in a stable order; recall when none is.
  List<Depth> get usableDepths {
    final usable = [
      for (final depth in Depth.values)
        if (depths.contains(depth) &&
            depth.minimumQuality.index <= quality.index)
          depth,
    ];
    return usable.isEmpty ? const [Depth.recall] : usable;
  }

  /// Drops depths the quality can't handle.
  GenerationProfile normalized() => GenerationProfile(
    quality: quality,
    depths: usableDepths.toSet(),
    multipleChoice: multipleChoice,
    candidatesPerFact: candidatesPerFact.clamp(1, 3),
    blindRuns: blindRuns.clamp(0, 2),
    critique: critique,
    neighborContext: neighborContext,
    explanation: explanation,
  );

  Map<String, Object?> toJson() => {
    'quality': quality.name,
    'depths': [for (final d in usableDepths) d.name],
    'multipleChoice': multipleChoice,
    'candidatesPerFact': candidatesPerFact,
    'blindRuns': blindRuns,
    'critique': critique,
    'neighborContext': neighborContext,
    'explanation': explanation.name,
  };

  factory GenerationProfile.fromJson(Map<String, Object?> json) =>
      GenerationProfile(
        quality: Quality.values.byName(json['quality'] as String),
        depths: {
          for (final d in (json['depths'] as List? ?? const []))
            Depth.values.byName(d as String),
        },
        multipleChoice: json['multipleChoice'] as bool? ?? false,
        candidatesPerFact: json['candidatesPerFact'] as int? ?? 1,
        blindRuns: json['blindRuns'] as int? ?? 0,
        critique: json['critique'] as bool? ?? false,
        neighborContext: json['neighborContext'] as bool? ?? false,
        explanation: ExplanationLevel.values.byName(
          json['explanation'] as String? ?? 'short',
        ),
      );
}

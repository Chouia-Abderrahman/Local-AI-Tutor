import 'chunk_generator.dart';
import 'profile.dart';
import 'prompts.dart';

/// Reading and writing speed of the model on this device.
class ModelSpeed {
  const ModelSpeed({
    required this.readTokensPerSecond,
    required this.writeTokensPerSecond,
    required this.measured,
  });

  /// Rough numbers for a ~4B model on a recent phone, used until the speed
  /// test has run.
  static const phoneGuess = ModelSpeed(
    readTokensPerSecond: 40,
    writeTokensPerSecond: 6,
    measured: false,
  );

  final double readTokensPerSecond;
  final double writeTokensPerSecond;
  final bool measured;
}

/// Estimated generation time for passages of [chunkTokens] tokens. Token
/// counts per stage follow the prompts: instructions, the passage (re-read
/// by every call, see prompts.dart), and typical reply lengths.
Duration estimateGeneration({
  required List<int> chunkTokens,
  required GenerationProfile profile,
  required ModelSpeed speed,
}) {
  final read = speed.readTokensPerSecond;
  final write = speed.writeTokensPerSecond;
  var seconds = 0.0;
  for (final tokens in chunkTokens) {
    final facts = factsWanted(tokens);
    seconds += (tokens + 350) / read + facts * 120 / write;
    if (!profile.multipleChoice) continue;
    final questions = facts * profile.candidatesPerFact;
    seconds += (tokens + 300 + facts * 60) / read + questions * 130 / write;
    seconds +=
        profile.blindRuns *
        ((tokens + 200 + questions * 70) / read + questions * 12 / write);
    if (profile.critique) {
      seconds +=
          (tokens + 300 + questions * 80) / read + questions * 60 / write;
    }
  }
  return Duration(seconds: seconds.round());
}

/// Estimated time to add [perFact] questions of [kind] to every fact of
/// passages of [chunkTokens] tokens.
Duration estimateMore({
  required List<int> chunkTokens,
  required MoreKind kind,
  required int perFact,
  required GenerationProfile profile,
  required ModelSpeed speed,
}) {
  final read = speed.readTokensPerSecond;
  final write = speed.writeTokensPerSecond;
  var seconds = 0.0;
  for (final tokens in chunkTokens) {
    final facts = factsWanted(tokens);
    final cards = facts * perFact;
    switch (kind) {
      case MoreKind.mcq:
        final candidates =
            facts *
            (profile.candidatesPerFact > perFact
                ? profile.candidatesPerFact
                : perFact);
        seconds +=
            (tokens + 300 + facts * 90) / read + candidates * 130 / write;
        seconds +=
            profile.blindRuns *
            ((tokens + 200 + candidates * 70) / read + candidates * 12 / write);
        if (profile.critique) {
          seconds +=
              (tokens + 300 + candidates * 80) / read + candidates * 60 / write;
        }
      case MoreKind.flashcard:
        seconds += (tokens + 250 + facts * 80) / read + cards * 40 / write;
      case MoreKind.cloze:
        seconds += (tokens + 250 + facts * 80) / read + cards * 10 / write;
    }
  }
  return Duration(seconds: seconds.round());
}

String formatDuration(Duration d) {
  if (d.inMinutes < 1) return 'under a minute';
  if (d.inMinutes < 60) return '${d.inMinutes} min';
  final minutes = d.inMinutes % 60;
  return '${d.inHours} h${minutes == 0 ? '' : ' $minutes min'}';
}

/// An estimate for display: "under a minute", "about 6 min", "about 2 h".
String approxDuration(Duration d) =>
    d.inMinutes < 1 ? 'under a minute' : 'about ${formatDuration(d)}';

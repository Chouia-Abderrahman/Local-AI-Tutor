/// Light markup in model replies.
library;

/// Splits `**bold**` out of [text]: its segments in order, markers removed.
/// A marker without its pair (a reply still streaming) is dropped.
List<({String text, bool bold})> boldSegments(String text) {
  final segments = <({String text, bool bold})>[];
  var last = 0;
  for (final match in RegExp(r'\*\*(.+?)\*\*').allMatches(text)) {
    if (match.start > last) {
      segments.add((
        text: text.substring(last, match.start).replaceAll('**', ''),
        bold: false,
      ));
    }
    segments.add((text: match.group(1)!, bold: true));
    last = match.end;
  }
  if (last < text.length) {
    segments.add((
      text: text.substring(last).replaceAll('**', ''),
      bold: false,
    ));
  }
  return segments;
}

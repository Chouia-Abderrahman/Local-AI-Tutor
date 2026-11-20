import 'dart:math' as math;
import 'dart:ui';

/// Squarified treemap layout (Bruls, Huizing and van Wijk): splits [rect]
/// into one rectangle per value, with areas proportional to [values] and
/// aspect ratios kept close to square. Rectangles come back in input order.
List<Rect> squarify(List<double> values, Rect rect) {
  final result = List<Rect>.filled(values.length, Rect.zero);
  final total = values.fold<double>(0, (a, b) => a + b);
  if (total <= 0 || rect.isEmpty) return result;

  // Work on indices sorted by size, largest first.
  final order = List<int>.generate(values.length, (i) => i)
    ..sort((a, b) => values[b].compareTo(values[a]));
  final scale = rect.width * rect.height / total;
  final areas = [for (final i in order) values[i] * scale];

  var free = rect;
  var start = 0;
  while (start < areas.length) {
    final side = math.min(free.width, free.height);
    var end = start + 1;
    var best = _worst(areas.sublist(start, end), side);
    while (end < areas.length) {
      final next = _worst(areas.sublist(start, end + 1), side);
      if (next > best) break;
      best = next;
      end++;
    }
    final row = areas.sublist(start, end);
    final rowArea = row.fold<double>(0, (a, b) => a + b);
    if (free.width >= free.height) {
      // Lay the row out as a column on the left.
      final width = rowArea / free.height;
      var y = free.top;
      for (var k = 0; k < row.length; k++) {
        final height = row[k] / width;
        result[order[start + k]] = Rect.fromLTWH(free.left, y, width, height);
        y += height;
      }
      free = Rect.fromLTRB(
        free.left + width,
        free.top,
        free.right,
        free.bottom,
      );
    } else {
      // Lay the row out along the top.
      final height = rowArea / free.width;
      var x = free.left;
      for (var k = 0; k < row.length; k++) {
        final width = row[k] / height;
        result[order[start + k]] = Rect.fromLTWH(x, free.top, width, height);
        x += width;
      }
      free = Rect.fromLTRB(
        free.left,
        free.top + height,
        free.right,
        free.bottom,
      );
    }
    start = end;
  }
  return result;
}

/// Worst aspect ratio of a row of [areas] laid along a side of [side].
double _worst(List<double> areas, double side) {
  final sum = areas.fold<double>(0, (a, b) => a + b);
  final maxArea = areas.reduce(math.max);
  final minArea = areas.reduce(math.min);
  final s2 = side * side;
  final sum2 = sum * sum;
  return math.max(s2 * maxArea / sum2, sum2 / (s2 * minArea));
}

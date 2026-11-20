/// Helpers for getting JSON out of a model without constrained decoding.
///
/// Constrained decoding in llamadart 0.20 checks the grammar against the full
/// vocabulary on every token, which made each question about 4x slower in
/// testing. The engine therefore asks for JSON in plain text first, extracts
/// and validates it, and uses the grammar only as a fallback.
library;

import 'dart:convert';

/// Returns the text of the first complete top-level JSON object in [text],
/// skipping code fences and any chatter around it. Null when there is none.
String? extractJsonObjectText(String text) {
  final start = text.indexOf('{');
  if (start < 0) return null;
  var depth = 0;
  var inString = false;
  var escaped = false;
  for (var i = start; i < text.length; i++) {
    final char = text[i];
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (char == r'\') {
        escaped = true;
      } else if (char == '"') {
        inString = false;
      }
      continue;
    }
    if (char == '"') {
      inString = true;
    } else if (char == '{') {
      depth++;
    } else if (char == '}') {
      depth--;
      if (depth == 0) return text.substring(start, i + 1);
    }
  }
  return null;
}

/// A compact, human-readable sketch of the JSON an object [schema] expects,
/// for example `{"answer": "...", "distractors": ["...", "...", "..."]}`.
/// Models follow such a sketch closely.
String describeJsonShape(Map<String, Object?> schema) => _shape(schema);

String _shape(Object? node) {
  if (node is! Map) return '<value>';
  final options = node['enum'];
  if (options is List) return options.map(jsonEncode).join(' | ');
  switch (node['type']) {
    case 'object':
      final properties = (node['properties'] as Map?) ?? const {};
      final fields = [
        for (final entry in properties.entries)
          '${jsonEncode(entry.key)}: ${_shape(entry.value)}',
      ];
      return '{${fields.join(', ')}}';
    case 'array':
      final item = _shape(node['items']);
      final min = node['minItems'];
      final max = node['maxItems'];
      if (min is int && min == max) {
        return '[${List.filled(min, item).join(', ')}]';
      }
      return '[$item, ...]';
    case 'string':
      return '"..."';
    case 'integer':
      final min = node['minimum'];
      final max = node['maximum'];
      return min != null && max != null ? '<integer $min-$max>' : '<integer>';
    case 'number':
      return '<number>';
    case 'boolean':
      return 'true | false';
  }
  return '<value>';
}

/// Repairs common near-misses of small models so the reply passes schema
/// validation without a slow constrained retry: numbers written as text,
/// integers out of range (clamped), too many array items (truncated), and
/// fields the schema doesn't allow (dropped). Anything else is left as is
/// for the validator to reject.
Object? coerceToSchema(Object? value, Object? schema) {
  if (schema is! Map) return value;
  final type = schema['type'];
  switch (type) {
    case 'object':
      if (value is! Map) return value;
      final properties = (schema['properties'] as Map?) ?? const {};
      final strict = schema['additionalProperties'] == false;
      return {
        for (final entry in value.entries)
          if (!strict || properties.containsKey(entry.key))
            '${entry.key}': coerceToSchema(entry.value, properties[entry.key]),
      };
    case 'array':
      if (value is! List) return value;
      final max = schema['maxItems'];
      final items = [
        for (final item in value) coerceToSchema(item, schema['items']),
      ];
      return max is int && items.length > max ? items.sublist(0, max) : items;
    case 'integer':
      final number = value is num
          ? value.round()
          : value is String
          ? int.tryParse(value.trim()) ?? double.tryParse(value.trim())?.round()
          : null;
      if (number == null) return value;
      final min = schema['minimum'];
      final max = schema['maximum'];
      var result = number;
      if (min is num && result < min) result = min.ceil();
      if (max is num && result > max) result = max.floor();
      return result;
    case 'number':
      return value is String ? (double.tryParse(value.trim()) ?? value) : value;
    case 'string':
      final options = schema['enum'];
      if (value is String && options is List && !options.contains(value)) {
        // "Supports" or "supports." for the enum value "supports".
        final key = value.trim().toLowerCase().replaceAll(
          RegExp(r'[^\p{L}\p{N}]', unicode: true),
          '',
        );
        for (final option in options) {
          if ('$option'.toLowerCase() == key) return option;
        }
      }
      return value is num || value is bool ? '$value' : value;
    case 'boolean':
      if (value is String) {
        final v = value.trim().toLowerCase();
        if (v == 'true') return true;
        if (v == 'false') return false;
      }
      return value;
  }
  return value;
}

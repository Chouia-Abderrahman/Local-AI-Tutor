import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'model_catalog.dart';

/// A model file on this phone: downloaded from the catalog or copied in.
@immutable
class InstalledModel {
  const InstalledModel({
    required this.path,
    required this.sizeBytes,
    this.spec,
    this.copiedIn = false,
  });

  final String path;
  final int sizeBytes;

  /// Copied onto the phone by hand rather than downloaded by the app (it can
  /// still be a catalog model, under the same name as a download).
  final bool copiedIn;

  /// The catalog entry, when the file is one of the catalog models.
  final ModelSpec? spec;

  String get fileName => p.basename(path);

  /// "Qwen3.5 4B" rather than "Qwen3.5-4B-Q4_K_M.gguf".
  String get name => spec?.name ?? modelDisplayName(fileName);

  @override
  bool operator ==(Object other) =>
      other is InstalledModel && other.path == path;

  @override
  int get hashCode => path.hashCode;
}

/// The catalog entry for a file name, if any.
ModelSpec? catalogSpecForFile(String fileName) {
  for (final spec in modelCatalog) {
    if (spec.fileName == fileName ||
        spec.legacySources.any((s) => s.split('/').last == fileName)) {
      return spec;
    }
  }
  return null;
}

final _quantization = RegExp(
  r'[-_.](?:i?q\d[\w]*|f16|f32|bf16)$',
  caseSensitive: false,
);

/// A readable name for a model file: "Qwen3.5-0.8B-Q4_K_M.gguf" becomes
/// "Qwen3.5 0.8B". Catalog files use their catalog name.
String modelDisplayName(String fileOrPath) {
  final fileName = p.basename(fileOrPath);
  final spec = catalogSpecForFile(fileName);
  if (spec != null) return spec.name;
  var name = fileName;
  if (name.toLowerCase().endsWith('.gguf')) {
    name = name.substring(0, name.length - 5);
  }
  name = name.replaceFirst(_quantization, '');
  name = name.replaceAll(RegExp(r'[-_]+'), ' ').trim();
  return name.isEmpty ? fileName : name;
}

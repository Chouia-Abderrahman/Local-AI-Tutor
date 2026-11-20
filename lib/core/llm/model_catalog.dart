/// Models the app offers to download, and which one suits a phone.
library;

const int _gib = 1024 * 1024 * 1024;

class ModelSpec {
  const ModelSpec({
    required this.id,
    required this.name,
    required this.source,
    required this.sizeBytes,
    required this.minRamBytes,
    required this.summary,
  });

  final String id;
  final String name;

  /// llamadart model source, such as `hf://owner/repo/file.gguf`.
  final String source;
  final int sizeBytes;

  /// Smallest total device RAM (as the OS reports it) this model is
  /// recommended for. Phones sold as "8 GB" report about 7.2-7.5 GiB.
  final int minRamBytes;
  final String summary;

  String get fileName => source.split('/').last;
}

/// Ordered from largest to smallest. All are Qwen3.5 instruct models
/// (Apache-2.0), quantized to Q4_K_M by unsloth.
const List<ModelSpec> modelCatalog = [
  ModelSpec(
    id: 'qwen3.5-4b',
    name: 'Qwen3.5 4B',
    source: 'hf://unsloth/Qwen3.5-4B-GGUF/Qwen3.5-4B-Q4_K_M.gguf',
    sizeBytes: 2741000000,
    minRamBytes: 6 * _gib + _gib ~/ 2,
    summary: 'Best questions. For phones with 8 GB of RAM or more.',
  ),
  ModelSpec(
    id: 'qwen3.5-2b',
    name: 'Qwen3.5 2B',
    source: 'hf://unsloth/Qwen3.5-2B-GGUF/Qwen3.5-2B-Q4_K_M.gguf',
    sizeBytes: 1281000000,
    minRamBytes: 4 * _gib + _gib ~/ 2,
    summary: 'Good balance. For phones with 6 GB of RAM.',
  ),
  ModelSpec(
    id: 'qwen3.5-0.8b',
    name: 'Qwen3.5 0.8B',
    source: 'hf://unsloth/Qwen3.5-0.8B-GGUF/Qwen3.5-0.8B-Q4_K_M.gguf',
    sizeBytes: 533000000,
    minRamBytes: 0,
    summary: 'Fastest but weakest. For testing and phones with little RAM.',
  ),
];

/// The largest catalog model recommended for a device with [totalRamBytes].
/// Unknown RAM gets the middle model.
ModelSpec recommendedModel(int? totalRamBytes) {
  if (totalRamBytes == null) return modelCatalog[1];
  for (final spec in modelCatalog) {
    if (totalRamBytes >= spec.minRamBytes) return spec;
  }
  return modelCatalog.last;
}

ModelSpec? modelSpecById(String id) {
  for (final spec in modelCatalog) {
    if (spec.id == id) return spec;
  }
  return null;
}

/// "2.7 GB" style size for display.
String formatBytes(int bytes) {
  if (bytes >= 1000000000) return '${(bytes / 1e9).toStringAsFixed(1)} GB';
  if (bytes >= 1000000) return '${(bytes / 1e6).toStringAsFixed(0)} MB';
  if (bytes >= 1000) return '${(bytes / 1e3).toStringAsFixed(0)} KB';
  return '$bytes B';
}

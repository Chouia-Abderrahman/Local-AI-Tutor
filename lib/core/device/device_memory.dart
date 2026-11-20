import 'dart:io';

/// Total RAM in bytes as the OS reports it, or null when unknown.
///
/// Android and Linux expose it in `/proc/meminfo`, readable without any
/// permission.
Future<int?> readTotalMemoryBytes() async {
  try {
    return parseMemTotal(await File('/proc/meminfo').readAsString());
  } on FileSystemException {
    return null;
  }
}

/// Parses the `MemTotal:` line of `/proc/meminfo` (given in KiB).
int? parseMemTotal(String meminfo) {
  final match = RegExp(
    r'^MemTotal:\s+(\d+)\s*kB',
    multiLine: true,
  ).firstMatch(meminfo);
  if (match == null) return null;
  return int.parse(match.group(1)!) * 1024;
}

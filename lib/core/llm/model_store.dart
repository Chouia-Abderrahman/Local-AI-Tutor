import 'dart:io';

import 'package:llamadart/llamadart.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'model_catalog.dart';

/// Where model files live on the device.
///
/// Downloads go to the app's private support directory, which the OS does
/// not clear under storage pressure (unlike the cache directory).
///
/// `.gguf` files copied in by hand are listed too, from two places:
/// - `<support>/sideload`, reachable on debug builds with
///   `adb shell "run-as <package> sh -c 'mkdir -p files/sideload && cp /data/local/tmp/<model>.gguf files/sideload/'"`
/// - the app's external files directory, where file managers can copy on
///   older Android versions.
class ModelStore {
  ModelStore._(this.manager, this.directory, this.sideloadDirectories);

  static Future<ModelStore> open() async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory(p.join(support.path, 'models'));
    await directory.create(recursive: true);
    final external = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : null;
    return ModelStore._(
      DefaultModelDownloadManager.auto(
        appPrivateCacheDirectory: directory.path,
      ),
      directory,
      [Directory(p.join(support.path, 'sideload')), ?external],
    );
  }

  final ModelDownloadManager manager;
  final Directory directory;
  final List<Directory> sideloadDirectories;

  /// Path of the downloaded file for [spec], or null if it isn't on the device.
  /// The current file first, then an earlier one (see
  /// [ModelSpec.legacySources]).
  Future<String?> downloadedPath(ModelSpec spec) async {
    for (final source in [spec.source, ...spec.legacySources]) {
      final entry = await manager.get(ModelSource.parse(source).cacheKey);
      if (entry != null && File(entry.filePath).existsSync()) {
        return entry.filePath;
      }
    }
    return null;
  }

  Future<void> delete(ModelSpec spec) async {
    for (final source in [spec.source, ...spec.legacySources]) {
      final key = ModelSource.parse(source).cacheKey;
      if (await manager.get(key) != null) await manager.remove(key);
    }
  }

  /// `.gguf` files copied onto the device by hand.
  List<File> sideloadedFiles() => [
    for (final dir in sideloadDirectories)
      if (dir.existsSync())
        ...dir.listSync().whereType<File>().where(
          (file) => file.path.toLowerCase().endsWith('.gguf'),
        ),
  ]..sort((a, b) => a.path.compareTo(b.path));

  ModelDownloadController newDownload() =>
      ModelDownloadController(manager: manager);
}

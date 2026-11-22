import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/llm/installed_model.dart';
import '../../core/llm/model_catalog.dart';
import '../generate/generate_controllers.dart';
import '../model/model_controllers.dart';
import 'background_tasks.dart';
import 'progress_notification.dart';

@pragma('vm:entry-point')
void keepAliveCallback() =>
    FlutterForegroundTask.setTaskHandler(_KeepAliveHandler());

/// The work runs in the app's own isolate; the plugin needs a handler, so
/// this one only brings the app back when the notification is tapped.
class _KeepAliveHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  @override
  void onNotificationPressed() => FlutterForegroundTask.launchApp();
}

/// What the app is doing that should go on when the user leaves it.
@immutable
class BackgroundActivity {
  const BackgroundActivity(
    this.title,
    this.text, {
    this.bar = false,
    this.percent,
  });

  final String title;
  final String text;

  /// The notification shows a progress bar.
  final bool bar;

  /// 0 to 100; with [bar] and no percent, the bar is indeterminate.
  final int? percent;

  @override
  bool operator ==(Object other) =>
      other is BackgroundActivity &&
      other.title == title &&
      other.text == text &&
      other.bar == bar &&
      other.percent == percent;

  @override
  int get hashCode => Object.hash(title, text, bar, percent);
}

/// The most important work in progress, or null when the app is idle.
/// Order: model downloads, then work the user waits for (an answer, a fact
/// check), then a model loading, then question generation.
final backgroundActivityProvider = Provider<BackgroundActivity?>((ref) {
  final downloads = ref.watch(modelDownloadsProvider);
  final running = [
    for (final spec in modelCatalog)
      if (downloads[spec.id]?.phase == DownloadPhase.running)
        (spec, downloads[spec.id]!),
  ];
  if (running.isNotEmpty) {
    final (spec, status) = running.first;
    final received = status.receivedBytes;
    // The server may not send a length; the catalog knows the file's size.
    final fraction =
        status.fraction ??
        (received == null ? null : received / spec.sizeBytes);
    final percent = fraction == null
        ? null
        : (fraction * 100).floor().clamp(0, 100);
    final more = running.length > 1 ? ' · ${running.length - 1} more' : '';
    return BackgroundActivity(
      'Downloading ${spec.name}',
      percent == null
          ? 'Starting…$more'
          : received == null
          ? '$percent% of ${formatBytes(spec.sizeBytes)}$more'
          : '$percent% · ${formatBytes(received)} of '
                '${formatBytes(spec.sizeBytes)}$more',
      bar: true,
      percent: percent,
    );
  }

  final tasks = ref.watch(backgroundTasksProvider);
  if (tasks.isNotEmpty) {
    final task = tasks.values.last;
    return BackgroundActivity(task.title, task.detail ?? 'Working…');
  }

  final model = ref.watch(activeModelProvider);
  if (model.phase == ModelPhase.loading && model.targetPath != null) {
    return BackgroundActivity(
      'Loading ${modelDisplayName(model.targetPath!)}',
      'Getting the model ready',
      bar: true,
    );
  }

  final runner = ref.watch(runnerStateProvider).value;
  if (runner != null && runner.working) {
    return BackgroundActivity(
      'Generating questions',
      runner.total == 0
          ? 'Working…'
          : '${runner.done} of ${runner.total} steps done',
      bar: true,
      percent: runner.total == 0
          ? null
          : (runner.done * 100 ~/ runner.total).clamp(0, 100),
    );
  }
  return null;
});

/// Keeps the app process alive while [backgroundActivityProvider] reports
/// work: an Android foreground service with a notification, a partial wake
/// lock and a Wi-Fi lock (so downloads keep their speed with the screen
/// off). Without it Android stops the work soon after the user leaves the
/// app.
class KeepAlive {
  bool _running = false;
  bool _initialized = false;
  BackgroundActivity? _shown;
  BackgroundActivity? _wanted;
  Timer? _throttle;
  Future<void> _pending = Future<void>.value();

  /// Download progress changes many times a second; the notification is
  /// updated at most this often.
  static const minInterval = Duration(seconds: 1);

  void update(BackgroundActivity? activity) {
    if (!Platform.isAndroid) return;
    _wanted = activity;
    // Starting and stopping happen at once; text updates are throttled.
    if (activity == null || !_running) {
      _schedule();
    } else {
      _throttle ??= Timer(minInterval, () {
        _throttle = null;
        _schedule();
      });
    }
  }

  void _schedule() {
    // Serialize: start/update/stop calls must not overlap.
    _pending = _pending.then((_) => _apply(_wanted)).catchError((Object e) {
      debugPrint('Foreground service: $e');
    });
  }

  Future<void> _apply(BackgroundActivity? activity) async {
    if (activity == null) {
      if (_running) {
        _running = false;
        _shown = null;
        await FlutterForegroundTask.stopService();
      }
      return;
    }
    // Android 15 and later allow a data-sync service 6 hours a day; when
    // that runs out, the plugin stops the service. Start it again later
    // (possible once the app is in the foreground) instead of updating a
    // stopped one.
    if (_running && !await FlutterForegroundTask.isRunningService) {
      _running = false;
    }
    if (_running) {
      if (activity == _shown) return;
      if (!await _show(activity)) {
        await FlutterForegroundTask.updateService(
          notificationTitle: activity.title,
          notificationText: activity.text,
        );
      }
      _shown = activity;
    } else {
      await _start(activity);
    }
  }

  /// Posts [activity] on the service's notification with its progress bar.
  Future<bool> _show(BackgroundActivity activity) => ProgressNotification.show(
    title: activity.title,
    text: activity.text,
    bar: activity.bar,
    percent: activity.percent,
  );

  Future<void> _start(BackgroundActivity activity) async {
    if (!_initialized) {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'background_work',
          channelName: 'Background work',
          channelDescription:
              'Shown while models download or load, answers are written and '
              'questions are generated.',
          onlyAlertOnce: true,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: false,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.nothing(),
          allowWakeLock: true,
          allowWifiLock: true,
          // The work runs in the app's own isolate, which ends when the app
          // is swiped away. A service that outlived it kept the process
          // alive with a stale notification, and the next launch landed in
          // that process and never drew its first frame.
          stopWithTask: true,
          allowAutoRestart: false,
        ),
      );
      _initialized = true;
    }
    if (await FlutterForegroundTask.checkNotificationPermission() !=
        NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
    final result = await FlutterForegroundTask.startService(
      serviceId: 412,
      notificationTitle: activity.title,
      notificationText: activity.text,
      notificationIcon: const NotificationIcon(
        metaDataName: 'local_ai_tutor.NOTIFICATION_ICON',
        backgroundColor: Color(0xFF15171C),
      ),
      callback: keepAliveCallback,
    );
    _running = result is ServiceRequestSuccess;
    if (_running) {
      _shown = activity;
      // The plugin's notification has no bar; replace it with one.
      if (activity.bar) await _show(activity);
    }
  }

  void dispose() {
    _throttle?.cancel();
    if (_running) unawaited(FlutterForegroundTask.stopService());
  }
}

/// Watched by the home shell for the app's lifetime.
final keepAliveProvider = Provider<KeepAlive>((ref) {
  final keepAlive = KeepAlive();
  ref.listen(
    backgroundActivityProvider,
    (_, next) => keepAlive.update(next),
    fireImmediately: true,
  );
  ref.onDispose(keepAlive.dispose);
  return keepAlive;
});

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/generate/runner.dart';
import 'generate_controllers.dart';

@pragma('vm:entry-point')
void keepAliveCallback() =>
    FlutterForegroundTask.setTaskHandler(_KeepAliveHandler());

/// Generation runs in the app's own isolate; the plugin needs a handler, so
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

/// Keeps the app process alive while questions are generated: an Android
/// foreground service with a progress notification and a partial wake lock.
/// Without it Android stops the work soon after the user leaves the app.
class GenerationKeepAlive {
  bool _running = false;
  bool _initialized = false;
  Future<void> _pending = Future<void>.value();

  void update(RunnerState state) {
    if (!Platform.isAndroid) return;
    // Serialize: start/update/stop calls must not overlap.
    _pending = _pending.then((_) => _apply(state)).catchError((Object e) {
      debugPrint('Foreground service: $e');
    });
  }

  Future<void> _apply(RunnerState state) async {
    if (state.working) {
      final text = state.total == 0
          ? 'Working…'
          : '${state.done} of ${state.total} steps done';
      // Android 15 and later allow a data-sync service 6 hours a day; when
      // that runs out, the plugin stops the service. Start it again later
      // (possible once the app is in the foreground) instead of updating a
      // stopped one.
      if (_running && !await FlutterForegroundTask.isRunningService) {
        _running = false;
      }
      if (_running) {
        await FlutterForegroundTask.updateService(notificationText: text);
      } else {
        await _start(text);
      }
    } else if (_running) {
      _running = false;
      await FlutterForegroundTask.stopService();
    }
  }

  Future<void> _start(String text) async {
    if (!_initialized) {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'generation',
          channelName: 'Question generation',
          channelDescription: 'Shown while questions are being generated.',
          onlyAlertOnce: true,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: false,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.nothing(),
          allowWakeLock: true,
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
      notificationTitle: 'Generating questions',
      notificationText: text,
      callback: keepAliveCallback,
    );
    _running = result is ServiceRequestSuccess;
  }

  void dispose() {
    if (_running) unawaited(FlutterForegroundTask.stopService());
  }
}

/// Watched by the home shell for the app's lifetime.
final generationKeepAliveProvider = Provider<GenerationKeepAlive>((ref) {
  final keepAlive = GenerationKeepAlive();
  ref.listen(runnerStateProvider, (_, next) {
    final state = next.value;
    if (state != null) keepAlive.update(state);
  });
  ref.onDispose(keepAlive.dispose);
  return keepAlive;
});

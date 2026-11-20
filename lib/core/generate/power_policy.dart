import 'dart:async';

import 'package:flutter/foundation.dart';

import 'runner.dart';

typedef BatteryReading = ({int level, bool charging});

/// Pauses generation at 20% battery or less when the phone isn't charging,
/// and resumes it once the phone charges or is back at 30%. If the user
/// resumes or pauses by hand during a low-battery pause, their choice stands
/// until the battery recovers.
class PowerPolicy {
  PowerPolicy({required this.runner, required this.readBattery});

  final GenerationRunner runner;
  final Future<BatteryReading> Function() readBattery;

  static const pauseAt = 20;
  static const resumeAt = 30;

  /// The message of the pause this policy made, while it lasts.
  String? _reason;

  /// The user took over during a low-battery pause.
  bool _overridden = false;
  bool _wasWorking = false;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  Timer? _timer;

  /// Checks when [batteryChanges] fires, when generation starts, and every
  /// [every].
  void start({
    Stream<Object?>? batteryChanges,
    Duration every = const Duration(minutes: 2),
  }) {
    if (batteryChanges != null) {
      _subscriptions.add(batteryChanges.listen((_) => check()));
    }
    _subscriptions.add(
      runner.states.listen((state) {
        if (state.working && !_wasWorking) check();
        _wasWorking = state.working;
      }),
    );
    _timer = Timer.periodic(every, (_) => check());
  }

  Future<void> check() async {
    final BatteryReading battery;
    try {
      battery = await readBattery();
    } on Object catch (error) {
      // Battery readings are best effort; generation goes on without them.
      debugPrint('Battery check failed: $error');
      return;
    }
    final low = !battery.charging && battery.level <= pauseAt;
    final recovered = battery.charging || battery.level >= resumeAt;
    final state = runner.state;
    final ours = _reason != null && state.paused && state.message == _reason;
    if (_reason != null && !ours) {
      // Someone resumed or paused by hand since our pause.
      _reason = null;
      _overridden = true;
    }
    if (recovered) _overridden = false;
    if (ours && recovered) {
      _reason = null;
      runner.resume();
    } else if (low && state.working && _reason == null && !_overridden) {
      _reason =
          'Paused to save battery (${battery.level}%). It continues when you '
          'plug in the phone.';
      runner.pause(reason: _reason);
    }
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _timer?.cancel();
  }
}

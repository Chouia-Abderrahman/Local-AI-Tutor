import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/generate/power_policy.dart';
import 'generate_controllers.dart';

/// Pauses generation on low battery (Android). Watched by the home shell for
/// the app's lifetime.
final powerPolicyProvider = Provider<PowerPolicy?>((ref) {
  if (!Platform.isAndroid) return null;
  final battery = Battery();
  final policy = PowerPolicy(
    runner: ref.watch(generationRunnerProvider),
    readBattery: () async {
      final state = await battery.batteryState;
      // "Connected, not charging" (a hot battery, for one) doesn't count:
      // the battery isn't filling, and some phones report it unplugged.
      return (
        level: await battery.batteryLevel,
        charging: state == BatteryState.charging || state == BatteryState.full,
      );
    },
  )..start(batteryChanges: battery.onBatteryStateChanged);
  ref.onDispose(policy.dispose);
  return policy;
});

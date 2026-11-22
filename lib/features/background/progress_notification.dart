import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The background-work notification, with a progress bar. Android only; the
/// native side is in MainActivity.kt. Every call says whether it was shown, so
/// callers can fall back to the plain service notification.
abstract final class ProgressNotification {
  static const _channel = MethodChannel('local_ai_tutor/notifications');

  /// Updates the notification of the running foreground service. [percent] is
  /// 0 to 100; with [bar] and no percent the bar is indeterminate.
  static Future<bool> show({
    required String title,
    required String text,
    bool bar = false,
    int? percent,
  }) => _call('progress', {
    'title': title,
    'text': text,
    'bar': bar,
    'percent': percent,
  });

  /// A one-off notice that outlives the service: "Model ready".
  static Future<bool> done({required String title, required String text}) =>
      _call('done', {'title': title, 'text': text});

  static Future<bool> _call(String method, Map<String, Object?> args) async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>(method, args) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (error) {
      debugPrint('Notification: $error');
      return false;
    }
  }
}

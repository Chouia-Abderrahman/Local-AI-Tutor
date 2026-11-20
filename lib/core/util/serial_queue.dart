import 'dart:async';

/// Runs async tasks one at a time, in the order they were added.
///
/// A failing task does not block the tasks queued after it; its error is
/// delivered to the caller of [run].
class SerialQueue {
  Future<void> _tail = Future<void>.value();

  Future<T> run<T>(Future<T> Function() task) {
    final completer = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        completer.complete(await task());
      } catch (error, stack) {
        completer.completeError(error, stack);
      }
    });
    return completer.future;
  }
}

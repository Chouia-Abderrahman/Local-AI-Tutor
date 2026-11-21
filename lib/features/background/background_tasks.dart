import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Foreground work the user is waiting for, such as an answer being written
/// or a fact being checked. While any runs, the app keeps running when the
/// user leaves it (see keep_alive.dart).
@immutable
class BackgroundTask {
  const BackgroundTask(this.title, {this.detail});

  final String title;
  final String? detail;
}

class BackgroundTasks extends Notifier<Map<int, BackgroundTask>> {
  int _next = 0;

  @override
  Map<int, BackgroundTask> build() => const {};

  /// Runs [body] as a task named [title].
  Future<T> run<T>(
    String title,
    Future<T> Function() body, {
    String? detail,
  }) async {
    final id = _next++;
    state = {...state, id: BackgroundTask(title, detail: detail)};
    try {
      return await body();
    } finally {
      if (ref.mounted) state = {...state}..remove(id);
    }
  }
}

final backgroundTasksProvider =
    NotifierProvider<BackgroundTasks, Map<int, BackgroundTask>>(
      BackgroundTasks.new,
    );

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/core/device/device_memory.dart';
import 'package:pdf_study_assistant/core/llm/model_catalog.dart';
import 'package:pdf_study_assistant/core/util/serial_queue.dart';

const _gib = 1024 * 1024 * 1024;

void main() {
  group('SerialQueue', () {
    test('runs tasks one at a time in order', () async {
      final queue = SerialQueue();
      final log = <String>[];
      Future<void> task(String name, int ms) => queue.run(() async {
        log.add('start $name');
        await Future<void>.delayed(Duration(milliseconds: ms));
        log.add('end $name');
      });
      await Future.wait([task('a', 20), task('b', 1), task('c', 5)]);
      expect(log, ['start a', 'end a', 'start b', 'end b', 'start c', 'end c']);
    });

    test(
      'a failing task reports its error and does not block the next',
      () async {
        final queue = SerialQueue();
        final failing = queue.run<int>(() async => throw StateError('boom'));
        final next = queue.run(() async => 42);
        await expectLater(failing, throwsStateError);
        expect(await next, 42);
      },
    );
  });

  group('parseMemTotal', () {
    test('reads MemTotal in KiB', () {
      const meminfo = 'MemTotal:        7841236 kB\nMemFree:  100 kB\n';
      expect(parseMemTotal(meminfo), 7841236 * 1024);
    });

    test('returns null without a MemTotal line', () {
      expect(parseMemTotal('MemFree: 100 kB'), isNull);
    });
  });

  group('recommendedModel', () {
    test('8 GB phones get the 4B model', () {
      expect(recommendedModel((7.3 * _gib).round()).id, 'qwen3.5-4b');
    });

    test('6 GB phones get the 2B model', () {
      expect(recommendedModel((5.4 * _gib).round()).id, 'qwen3.5-2b');
    });

    test('small phones and the 2 GB emulator get the 0.8B model', () {
      expect(recommendedModel((3.6 * _gib).round()).id, 'qwen3.5-0.8b');
      expect(recommendedModel(2 * _gib).id, 'qwen3.5-0.8b');
    });

    test('unknown RAM gets the middle model', () {
      expect(recommendedModel(null).id, 'qwen3.5-2b');
    });
  });

  test('formatBytes', () {
    expect(formatBytes(2741000000), '2.7 GB');
    expect(formatBytes(533000000), '533 MB');
  });
}

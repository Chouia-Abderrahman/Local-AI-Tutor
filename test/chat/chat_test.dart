import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/core/chat/chat_service.dart';
import 'package:pdf_study_assistant/core/chat/retrieval.dart';
import 'package:pdf_study_assistant/core/db/database.dart';
import 'package:pdf_study_assistant/core/ingest/importer.dart';
import 'package:pdf_study_assistant/core/llm/llm_engine.dart';

void main() {
  late AppDatabase db;
  late Directory storage;
  late int documentId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    storage = Directory.systemTemp.createTempSync('chat');
    final notes = File('${storage.path}/biology.md')
      ..writeAsStringSync(
        '# Osmosis\n\nOsmosis is the movement of water across a selectively '
        'permeable membrane toward the side with more dissolved solutes. '
        'Animal cells in a hypotonic solution swell and can burst.\n\n'
        '# Energy\n\nMitochondria produce most of the ATP in eukaryotic cells. '
        'Glycolysis splits glucose into two molecules of pyruvate in the '
        'cytoplasm.\n',
      );
    documentId = (await DocumentImporter(
      db: db,
      storageDir: storage,
      extractPdf: (path, {required title, onProgress}) =>
          throw UnimplementedError(),
    ).importFile(notes.path)).documentId;
  });

  tearDown(() async {
    await db.close();
    storage.deleteSync(recursive: true);
  });

  group('retrieval', () {
    test('finds the passage about the question, best first', () async {
      final hits = await Retriever(db).search(documentId, 'What makes ATP?');
      expect(hits.first.headingPath, 'Energy');
      expect(hits.first.text, contains('Mitochondria'));
      final osmosis = await Retriever(
        db,
      ).search(documentId, 'Why do animal cells burst in osmotic stress?');
      expect(osmosis.first.headingPath, 'Osmosis');
    });

    test('a question without content words finds nothing', () async {
      expect(await Retriever(db).search(documentId, 'what is it?'), isEmpty);
      expect(ftsQuery('the of and'), isNull);
    });
  });

  test('grounding marks sentences the excerpts do not support', () async {
    final excerpts = await Retriever(db).search(documentId, 'ATP mitochondria');
    final checked = checkGrounding(
      'Mitochondria produce most of the ATP [1]. '
      'Chloroplasts in plant leaves capture sunlight energy for photosynthesis.',
      excerpts,
    );
    expect(checked.map((s) => s.supported), [true, false]);
    expect(citedNumbers('As [1] and [3] say.'), {1, 3});
    expect(mostlyUnsupported(checked), isTrue, reason: '1 of 2 unsupported');
  });

  test('an invented citation number makes a sentence unsupported', () async {
    final excerpts = await Retriever(db).search(documentId, 'ATP mitochondria');
    // Seen on the 0.8B model: a made-up answer citing an excerpt that
    // was never given.
    final checked = checkGrounding(
      'The microscope was invented in 1784 by a famous scientist [5].',
      excerpts,
    );
    expect(checked.single.supported, isFalse);
    expect(mostlyUnsupported(checked), isTrue);
    final good = checkGrounding(
      'Mitochondria produce most of the ATP [1].',
      excerpts,
    );
    expect(mostlyUnsupported(good), isFalse);
  });

  test('"not covered" replies are recognized', () {
    expect(
      saysNotFound('The document does not seem to cover photosynthesis.'),
      isTrue,
    );
    expect(saysNotFound("I couldn't find that in the excerpts."), isTrue);
    expect(saysNotFound('Mitochondria make ATP [1].'), isFalse);
  });

  test('the prompt numbers excerpts and keeps only recent history', () async {
    final excerpts = await Retriever(db).search(documentId, 'ATP');
    final history = [
      for (var i = 0; i < 6; i++)
        ChatMessage(
          id: i,
          threadId: 1,
          role: i.isEven ? 'user' : 'assistant',
          content: 'turn $i',
          usedWeb: false,
          createdAt: DateTime(2026),
        ),
    ];
    final messages = chatMessages(
      question: 'Where is ATP made?',
      excerpts: excerpts,
      history: history,
      mode: ChatMode.ask,
      language: 'en',
    );
    expect(messages.first.role, LlmRole.system);
    expect(messages.first.text, contains('[1] Energy, p. 1:'));
    expect(messages.first.text, contains('Write in English'));
    expect(messages.map((m) => m.text).toList().sublist(1, 5), [
      'turn 2',
      'turn 3',
      'turn 4',
      'turn 5',
    ]);
    expect(messages.last.text, 'Where is ATP made?');
  });

  test('saving an answer as a card quotes the supporting sentence', () async {
    final repo = ChatRepository(db);
    final excerpts = await Retriever(db).search(documentId, 'ATP mitochondria');
    final citations = [
      for (final (i, e) in excerpts.indexed) Citation.fromExcerpt(i + 1, e),
    ];
    final factId = await repo.saveAsCard(
      question: 'Where is most ATP made?',
      answer: 'Most ATP is made by the mitochondria [1].',
      citations: citations,
    );
    expect(factId, isNotNull);
    final fact = await (db.select(
      db.facts,
    )..where((f) => f.id.equals(factId!))).getSingle();
    expect(
      fact.quote,
      'Mitochondria produce most of the ATP in eukaryotic cells.',
    );
    final question = await (db.select(
      db.questions,
    )..where((q) => q.factId.equals(factId!))).getSingle();
    expect(question.type, 'flashcard');
    expect(question.prompt, 'Where is most ATP made?');
    expect(question.answer, 'Most ATP is made by the mitochondria.');

    // An answer the passages don't support can't become a card.
    expect(
      await repo.saveAsCard(
        question: 'What do chloroplasts do?',
        answer: 'Chloroplasts capture sunlight for photosynthesis.',
        citations: citations,
      ),
      isNull,
    );
  });

  test('threads are per document and can be cleared', () async {
    final repo = ChatRepository(db);
    final thread = await repo.threadFor(documentId);
    expect(await repo.threadFor(documentId), thread);
    await repo.add(thread, 'user', 'hi');
    final meta = const ReplyMeta(
      citations: [],
      unsupported: ['x'],
      notFound: true,
    ).toJson();
    await repo.add(thread, 'assistant', 'hello', meta: meta);
    final messages = await repo.messages(thread);
    expect(messages.map((m) => m.role), ['user', 'assistant']);
    expect(ReplyMeta.fromJson(messages.last.citationsJson).notFound, isTrue);
    await repo.clear(thread);
    expect(await repo.messages(thread), isEmpty);
  });
}
